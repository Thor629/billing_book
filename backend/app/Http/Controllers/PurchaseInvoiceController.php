<?php

namespace App\Http\Controllers;

use App\Models\PurchaseInvoice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseInvoiceController extends Controller
{
    public function index(Request $request)
    {
        $query = PurchaseInvoice::with(['party', 'items.item'])
            ->where('organization_id', $request->header('X-Organization-Id'));

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('party_id')) {
            $query->where('party_id', $request->party_id);
        }

        $invoices = $query->orderBy('invoice_date', 'desc')->paginate(20);

        return response()->json($invoices);
    }

    public function store(Request $request)
    {
        // Log the incoming request for debugging
        \Log::info('Purchase Invoice Store Request:', [
            'body' => $request->all(),
            'user_id' => $request->user()->id,
        ]);

        $validated = $request->validate([
            'organization_id' => 'required|exists:organizations,id',
            'party_id' => 'required|exists:parties,id',
            'invoice_number' => 'required|string',
            'invoice_date' => 'required|date',
            'payment_terms' => 'required|integer|min:0',
            'due_date' => 'required|date',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.quantity' => 'required|numeric|min:0.001',
            'items.*.price_per_unit' => 'required|numeric|min:0',
            'items.*.discount_percent' => 'nullable|numeric|min:0|max:100',
            'items.*.tax_percent' => 'nullable|numeric|min:0|max:100',
            'discount_amount' => 'nullable|numeric|min:0',
            'additional_charges' => 'nullable|numeric|min:0',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'amount_paid' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
            'terms_conditions' => 'nullable|string',
        ]);

        \Log::info('Validated data:', $validated);

        try {
            DB::beginTransaction();

            $organizationId = $validated['organization_id'];
            
            \Log::info('Organization ID extracted:', ['organization_id' => $organizationId]);
            
            // Verify user has access to this organization
            $hasAccess = $request->user()
                ->organizations()
                ->where('organizations.id', $organizationId)
                ->exists();

            if (!$hasAccess) {
                DB::rollBack();
                return response()->json([
                    'message' => 'Access denied to this organization',
                ], 403);
            }

            // Check for duplicate invoice number
            $exists = PurchaseInvoice::where('organization_id', $organizationId)
                ->where('invoice_number', $validated['invoice_number'])
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

            foreach ($validated['items'] as $item) {
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

            $additionalCharges = $validated['additional_charges'] ?? 0;
            $overallDiscount = $validated['discount_amount'] ?? 0;
            $totalAmount = $subtotal - $overallDiscount + $totalTax + $additionalCharges;
            $amountPaid = $validated['amount_paid'] ?? 0;
            $balanceAmount = $totalAmount - $amountPaid;

            $paymentStatus = 'unpaid';
            if ($amountPaid >= $totalAmount) {
                $paymentStatus = 'paid';
                $balanceAmount = 0;
            } elseif ($amountPaid > 0) {
                $paymentStatus = 'partial';
            }

            // Debug logging
            \Log::info('Creating purchase invoice with data:', [
                'organization_id' => $organizationId,
                'party_id' => $validated['party_id'],
                'user_id' => $request->user()->id,
            ]);

            // Create invoice
            $invoice = PurchaseInvoice::create([
                'organization_id' => (int)$organizationId,
                'party_id' => (int)$validated['party_id'],
                'user_id' => (int)$request->user()->id,
                'invoice_number' => $validated['invoice_number'],
                'invoice_date' => $validated['invoice_date'],
                'payment_terms' => (int)$validated['payment_terms'],
                'due_date' => $validated['due_date'],
                'subtotal' => (float)$subtotal,
                'discount_amount' => (float)($overallDiscount + $totalDiscount),
                'tax_amount' => (float)$totalTax,
                'additional_charges' => (float)$additionalCharges,
                'total_amount' => (float)$totalAmount,
                'paid_amount' => (float)$amountPaid,
                'balance_amount' => (float)$balanceAmount,
                'payment_status' => $paymentStatus,
                'notes' => $validated['notes'] ?? null,
                'terms' => $validated['terms_conditions'] ?? null,
                'bank_account_id' => isset($validated['bank_account_id']) ? (int)$validated['bank_account_id'] : null,
            ]);

            // Create invoice items and increase stock
            foreach ($validated['items'] as $itemData) {
                $quantity = $itemData['quantity'];
                $pricePerUnit = $itemData['price_per_unit'];
                $discountPercent = $itemData['discount_percent'] ?? 0;
                $taxPercent = $itemData['tax_percent'] ?? 0;

                $lineSubtotal = $quantity * $pricePerUnit;
                $discountAmount = $lineSubtotal * ($discountPercent / 100);
                $taxableAmount = $lineSubtotal - $discountAmount;
                $taxAmount = $taxableAmount * ($taxPercent / 100);
                $lineTotal = $taxableAmount + $taxAmount;

                $invoice->items()->create([
                    'item_id' => $itemData['item_id'],
                    'quantity' => $quantity,
                    'unit' => $itemData['unit'] ?? 'pcs',
                    'rate' => $pricePerUnit,
                    'tax_rate' => $taxPercent,
                    'discount_rate' => $discountPercent,
                    'amount' => $lineTotal,
                ]);

                // Increase stock quantity (opposite of sales invoice)
                $item = \App\Models\Item::find($itemData['item_id']);
                if ($item) {
                    $item->stock_qty += $quantity;
                    $item->save();
                }
            }

            // Create bank transaction if payment is made
            if ($amountPaid > 0 && isset($validated['bank_account_id'])) {
                \App\Models\BankTransaction::create([
                    'account_id' => $validated['bank_account_id'],
                    'organization_id' => $organizationId,
                    'user_id' => $request->user()->id,
                    'transaction_type' => 'reduce', // Money going out for purchase payment
                    'amount' => $amountPaid,
                    'transaction_date' => $validated['invoice_date'],
                    'description' => 'Payment for Purchase Invoice ' . $validated['invoice_number'],
                ]);

                // Update bank account balance
                $bankAccount = \App\Models\BankAccount::find($validated['bank_account_id']);
                if ($bankAccount) {
                    $bankAccount->current_balance -= $amountPaid;
                    $bankAccount->save();
                }
            }

            DB::commit();

            return response()->json([
                'message' => 'Purchase invoice created successfully',
                'invoice' => $invoice->load(['party', 'items.item']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Purchase Invoice Creation Error: ' . $e->getMessage());
            \Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'message' => 'Failed to create purchase invoice',
                'error' => $e->getMessage(),
                'trace' => config('app.debug') ? $e->getTraceAsString() : null,
            ], 500);
        }
    }

    public function show($id, Request $request)
    {
        $invoice = PurchaseInvoice::with(['party', 'items.item', 'payments'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($invoice);
    }

    public function update(Request $request, $id)
    {
        $invoice = PurchaseInvoice::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $validated = $request->validate([
            'party_id' => 'sometimes|exists:parties,id',
            'invoice_date' => 'sometimes|date',
            'due_date' => 'nullable|date',
            'status' => 'sometimes|in:draft,pending,paid,partial,overdue,cancelled',
            'notes' => 'nullable|string',
            'terms' => 'nullable|string',
        ]);

        $invoice->update($validated);

        return response()->json($invoice->load(['party', 'items.item']));
    }

    public function destroy($id, Request $request)
    {
        try {
            DB::beginTransaction();

            $invoice = PurchaseInvoice::with('items')
                ->where('organization_id', $request->header('X-Organization-Id'))
                ->findOrFail($id);

            // Decrease stock quantities before deleting (reverse the purchase)
            foreach ($invoice->items as $invoiceItem) {
                $item = \App\Models\Item::find($invoiceItem->item_id);
                if ($item) {
                    $item->stock_qty = max(0, $item->stock_qty - $invoiceItem->quantity);
                    $item->save();
                }
            }

            // Delete related bank transaction if exists
            if ($invoice->paid_amount > 0) {
                \App\Models\BankTransaction::where('description', 'like', '%' . $invoice->invoice_number . '%')
                    ->where('organization_id', $invoice->organization_id)
                    ->delete();
            }

            $invoice->delete();

            DB::commit();

            return response()->json(['message' => 'Purchase invoice deleted successfully']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to delete purchase invoice',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextInvoiceNumber(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json([
                'message' => 'Organization ID is required',
            ], 400);
        }

        // Verify user has access to this organization
        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $organizationId)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'message' => 'Access denied to this organization',
            ], 403);
        }

        $lastInvoice = PurchaseInvoice::where('organization_id', $organizationId)
            ->orderBy('invoice_number', 'desc')
            ->first();

        $nextNumber = $lastInvoice 
            ? ((int)$lastInvoice->invoice_number + 1)
            : 1;

        return response()->json([
            'next_number' => $nextNumber,
            'formatted' => 'PI-' . $nextNumber,
        ]);
    }
}
