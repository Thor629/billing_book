<?php

namespace App\Http\Controllers;

use App\Models\SalesInvoice;
use App\Models\SalesInvoiceItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SalesInvoiceController extends Controller
{
    public function index(Request $request)
    {
        $query = SalesInvoice::with(['party', 'organization', 'user'])
            ->where('organization_id', $request->user()->currentOrganization->id ?? null);

        // Filter by date range
        if ($request->has('date_filter')) {
            $days = match($request->date_filter) {
                'Last 7 Days' => 7,
                'Last 30 Days' => 30,
                'Last 365 Days' => 365,
                default => 365
            };
            $query->where('invoice_date', '>=', now()->subDays($days));
        }

        // Filter by payment status
        if ($request->has('payment_status')) {
            $query->where('payment_status', $request->payment_status);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('invoice_number', 'like', "%{$search}%")
                  ->orWhereHas('party', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $invoices = $query->orderBy('invoice_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        // Calculate summary
        $summary = [
            'total_sales' => SalesInvoice::where('organization_id', $request->user()->currentOrganization->id ?? null)
                ->sum('total_amount'),
            'paid' => SalesInvoice::where('organization_id', $request->user()->currentOrganization->id ?? null)
                ->where('payment_status', 'paid')
                ->sum('total_amount'),
            'unpaid' => SalesInvoice::where('organization_id', $request->user()->currentOrganization->id ?? null)
                ->whereIn('payment_status', ['unpaid', 'partial'])
                ->sum('balance_amount'),
        ];

        return response()->json([
            'invoices' => $invoices,
            'summary' => $summary,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'party_id' => 'required|exists:parties,id',
            'invoice_prefix' => 'required|string|max:10',
            'invoice_number' => 'required|string|max:50',
            'invoice_date' => 'required|date',
            'payment_terms' => 'required|integer|min:0',
            'due_date' => 'required|date|after_or_equal:invoice_date',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.quantity' => 'required|numeric|min:0.001',
            'items.*.price_per_unit' => 'required|numeric|min:0',
            'items.*.discount_percent' => 'nullable|numeric|min:0|max:100',
            'items.*.tax_percent' => 'nullable|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            DB::beginTransaction();

            $organizationId = $request->user()->currentOrganization->id ?? null;
            
            // Check for duplicate invoice number
            $exists = SalesInvoice::where('organization_id', $organizationId)
                ->where('invoice_prefix', $request->invoice_prefix)
                ->where('invoice_number', $request->invoice_number)
                ->exists();
                
            if ($exists) {
                return response()->json([
                    'message' => 'Invoice number already exists'
                ], 422);
            }

            // Calculate totals
            $subtotal = 0;
            $totalTax = 0;
            $totalDiscount = 0;

            foreach ($request->items as $item) {
                $quantity = $item['quantity'];
                $pricePerUnit = $item['price_per_unit'];
                $discountPercent = $item['discount_percent'] ?? 0;
                $taxPercent = $item['tax_percent'] ?? 0;

                $lineSubtotal = $quantity * $pricePerUnit;
                $discountAmount = $lineSubtotal * ($discountPercent / 100);
                $taxableAmount = $lineSubtotal - $discountAmount;
                $taxAmount = $taxableAmount * ($taxPercent / 100);

                $subtotal += $lineSubtotal;
                $totalDiscount += $discountAmount;
                $totalTax += $taxAmount;
            }

            $additionalCharges = $request->additional_charges ?? 0;
            $roundOff = $request->round_off ?? 0;
            $totalAmount = $subtotal - $totalDiscount + $totalTax + $additionalCharges + $roundOff;
            $amountReceived = $request->amount_received ?? 0;
            $balanceAmount = $totalAmount - $amountReceived;

            $paymentStatus = 'unpaid';
            if ($amountReceived >= $totalAmount) {
                $paymentStatus = 'paid';
                $balanceAmount = 0;
            } elseif ($amountReceived > 0) {
                $paymentStatus = 'partial';
            }

            // Create invoice
            $invoice = SalesInvoice::create([
                'organization_id' => $organizationId,
                'party_id' => $request->party_id,
                'user_id' => $request->user()->id,
                'invoice_prefix' => $request->invoice_prefix,
                'invoice_number' => $request->invoice_number,
                'invoice_date' => $request->invoice_date,
                'payment_terms' => $request->payment_terms,
                'due_date' => $request->due_date,
                'subtotal' => $subtotal,
                'discount_amount' => $totalDiscount,
                'tax_amount' => $totalTax,
                'additional_charges' => $additionalCharges,
                'round_off' => $roundOff,
                'total_amount' => $totalAmount,
                'amount_received' => $amountReceived,
                'balance_amount' => $balanceAmount,
                'payment_mode' => $request->payment_mode,
                'payment_status' => $paymentStatus,
                'notes' => $request->notes,
                'terms_conditions' => $request->terms_conditions,
                'bank_details' => $request->bank_details,
                'show_bank_details' => $request->show_bank_details ?? true,
                'auto_round_off' => $request->auto_round_off ?? false,
            ]);

            // Create invoice items
            foreach ($request->items as $itemData) {
                $quantity = $itemData['quantity'];
                $pricePerUnit = $itemData['price_per_unit'];
                $discountPercent = $itemData['discount_percent'] ?? 0;
                $taxPercent = $itemData['tax_percent'] ?? 0;

                $lineSubtotal = $quantity * $pricePerUnit;
                $discountAmount = $lineSubtotal * ($discountPercent / 100);
                $taxableAmount = $lineSubtotal - $discountAmount;
                $taxAmount = $taxableAmount * ($taxPercent / 100);
                $lineTotal = $taxableAmount + $taxAmount;

                SalesInvoiceItem::create([
                    'sales_invoice_id' => $invoice->id,
                    'item_id' => $itemData['item_id'],
                    'item_name' => $itemData['item_name'],
                    'hsn_sac' => $itemData['hsn_sac'] ?? null,
                    'item_code' => $itemData['item_code'] ?? null,
                    'mrp' => $itemData['mrp'] ?? null,
                    'quantity' => $quantity,
                    'unit' => $itemData['unit'] ?? 'pcs',
                    'price_per_unit' => $pricePerUnit,
                    'discount_percent' => $discountPercent,
                    'discount_amount' => $discountAmount,
                    'tax_percent' => $taxPercent,
                    'tax_amount' => $taxAmount,
                    'line_total' => $lineTotal,
                ]);
            }

            DB::commit();

            return response()->json([
                'message' => 'Sales invoice created successfully',
                'invoice' => $invoice->load(['party', 'items', 'organization']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create sales invoice',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $invoice = SalesInvoice::with(['party', 'items.item', 'organization', 'user'])
            ->findOrFail($id);

        return response()->json($invoice);
    }

    public function update(Request $request, $id)
    {
        $invoice = SalesInvoice::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'party_id' => 'sometimes|exists:parties,id',
            'invoice_date' => 'sometimes|date',
            'payment_terms' => 'sometimes|integer|min:0',
            'due_date' => 'sometimes|date',
            'amount_received' => 'sometimes|numeric|min:0',
            'payment_mode' => 'sometimes|string',
            'payment_status' => 'sometimes|in:paid,unpaid,partial',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            DB::beginTransaction();

            // Update payment if amount_received is provided
            if ($request->has('amount_received')) {
                $amountReceived = $request->amount_received;
                $balanceAmount = $invoice->total_amount - $amountReceived;

                $paymentStatus = 'unpaid';
                if ($amountReceived >= $invoice->total_amount) {
                    $paymentStatus = 'paid';
                    $balanceAmount = 0;
                } elseif ($amountReceived > 0) {
                    $paymentStatus = 'partial';
                }

                $invoice->update([
                    'amount_received' => $amountReceived,
                    'balance_amount' => $balanceAmount,
                    'payment_status' => $paymentStatus,
                    'payment_mode' => $request->payment_mode ?? $invoice->payment_mode,
                ]);
            } else {
                $invoice->update($request->only([
                    'party_id',
                    'invoice_date',
                    'payment_terms',
                    'due_date',
                    'notes',
                    'terms_conditions',
                    'bank_details',
                    'show_bank_details',
                ]));
            }

            DB::commit();

            return response()->json([
                'message' => 'Sales invoice updated successfully',
                'invoice' => $invoice->load(['party', 'items', 'organization']),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to update sales invoice',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $invoice = SalesInvoice::findOrFail($id);
            $invoice->delete();

            return response()->json([
                'message' => 'Sales invoice deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete sales invoice',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextInvoiceNumber(Request $request)
    {
        $prefix = $request->prefix ?? 'INV';
        $organizationId = $request->user()->currentOrganization->id ?? null;

        $lastInvoice = SalesInvoice::where('organization_id', $organizationId)
            ->where('invoice_prefix', $prefix)
            ->orderBy('invoice_number', 'desc')
            ->first();

        $nextNumber = $lastInvoice ? ((int)$lastInvoice->invoice_number + 1) : 1;

        return response()->json([
            'next_number' => $nextNumber,
            'formatted' => $prefix . $nextNumber,
        ]);
    }
}
