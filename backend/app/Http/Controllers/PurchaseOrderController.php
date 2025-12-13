<?php

namespace App\Http\Controllers;

use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class PurchaseOrderController extends Controller
{
    public function index(Request $request)
    {
        $organizationId = $request->input('organization_id');
        $status = $request->input('status');

        $query = PurchaseOrder::with(['party', 'items'])
            ->where('organization_id', $organizationId);

        if ($status && $status !== 'all') {
            $query->where('status', $status);
        }

        $orders = $query->orderBy('order_date', 'desc')
            ->orderBy('id', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $orders,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'organization_id' => 'required|integer',
            'party_id' => 'required|integer',
            'order_date' => 'required|date',
            'expected_delivery_date' => 'nullable|date',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|integer',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.rate' => 'required|numeric|min:0',
            'items.*.tax_rate' => 'required|numeric|min:0',
            'discount_amount' => 'nullable|numeric|min:0',
            'additional_charges' => 'nullable|numeric|min:0',
            'auto_round_off' => 'boolean',
            'fully_paid' => 'boolean',
            'bank_account_id' => 'nullable|integer',
        ]);

        DB::beginTransaction();
        try {
            // Generate order number
            $lastOrder = PurchaseOrder::where('organization_id', $request->organization_id)
                ->orderBy('id', 'desc')
                ->first();
            
            $nextNumber = $lastOrder ? (intval(substr($lastOrder->order_number, 3)) + 1) : 1;
            $orderNumber = 'PO-' . str_pad($nextNumber, 6, '0', STR_PAD_LEFT);

            // Calculate totals
            $subtotal = 0;
            $taxAmount = 0;

            foreach ($request->items as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = ($itemSubtotal * $item['tax_rate']) / 100;
                $subtotal += $itemSubtotal;
                $taxAmount += $itemTax;
            }

            $discountAmount = $request->discount_amount ?? 0;
            $additionalCharges = $request->additional_charges ?? 0;
            $totalBeforeRound = $subtotal + $taxAmount - $discountAmount + $additionalCharges;
            
            $roundOff = 0;
            if ($request->auto_round_off) {
                $roundOff = round($totalBeforeRound) - $totalBeforeRound;
            }
            
            $totalAmount = $totalBeforeRound + $roundOff;

            // Create purchase order
            $order = PurchaseOrder::create([
                'organization_id' => $request->organization_id,
                'party_id' => $request->party_id,
                'order_number' => $orderNumber,
                'order_date' => $request->order_date,
                'expected_delivery_date' => $request->expected_delivery_date,
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'discount_amount' => $discountAmount,
                'additional_charges' => $additionalCharges,
                'round_off' => $roundOff,
                'auto_round_off' => $request->auto_round_off ?? false,
                'total_amount' => $totalAmount,
                'fully_paid' => $request->fully_paid ?? false,
                'bank_account_id' => $request->bank_account_id,
                'status' => 'draft',
                'notes' => $request->notes,
                'terms' => $request->terms,
            ]);

            // Create order items
            foreach ($request->items as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = ($itemSubtotal * $item['tax_rate']) / 100;
                $itemAmount = $itemSubtotal + $itemTax;

                PurchaseOrderItem::create([
                    'purchase_order_id' => $order->id,
                    'item_id' => $item['item_id'],
                    'description' => $item['description'] ?? null,
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'] ?? 'pcs',
                    'rate' => $item['rate'],
                    'tax_rate' => $item['tax_rate'],
                    'discount_rate' => $item['discount_rate'] ?? 0,
                    'amount' => $itemAmount,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Purchase order created successfully',
                'data' => $order->load(['party', 'items.item']),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create purchase order: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function show($id)
    {
        $order = PurchaseOrder::with(['party', 'items.item', 'bankAccount'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $order,
        ]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'party_id' => 'required|integer',
            'order_date' => 'required|date',
            'expected_delivery_date' => 'nullable|date',
            'items' => 'required|array|min:1',
            'discount_amount' => 'nullable|numeric|min:0',
            'additional_charges' => 'nullable|numeric|min:0',
            'auto_round_off' => 'boolean',
            'fully_paid' => 'boolean',
            'bank_account_id' => 'nullable|integer',
        ]);

        DB::beginTransaction();
        try {
            $order = PurchaseOrder::findOrFail($id);

            // Calculate totals
            $subtotal = 0;
            $taxAmount = 0;

            foreach ($request->items as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = ($itemSubtotal * $item['tax_rate']) / 100;
                $subtotal += $itemSubtotal;
                $taxAmount += $itemTax;
            }

            $discountAmount = $request->discount_amount ?? 0;
            $additionalCharges = $request->additional_charges ?? 0;
            $totalBeforeRound = $subtotal + $taxAmount - $discountAmount + $additionalCharges;
            
            $roundOff = 0;
            if ($request->auto_round_off) {
                $roundOff = round($totalBeforeRound) - $totalBeforeRound;
            }
            
            $totalAmount = $totalBeforeRound + $roundOff;

            // Update purchase order
            $order->update([
                'party_id' => $request->party_id,
                'order_date' => $request->order_date,
                'expected_delivery_date' => $request->expected_delivery_date,
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'discount_amount' => $discountAmount,
                'additional_charges' => $additionalCharges,
                'round_off' => $roundOff,
                'auto_round_off' => $request->auto_round_off ?? false,
                'total_amount' => $totalAmount,
                'fully_paid' => $request->fully_paid ?? false,
                'bank_account_id' => $request->bank_account_id,
                'notes' => $request->notes,
                'terms' => $request->terms,
            ]);

            // Delete old items and create new ones
            $order->items()->delete();

            foreach ($request->items as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = ($itemSubtotal * $item['tax_rate']) / 100;
                $itemAmount = $itemSubtotal + $itemTax;

                PurchaseOrderItem::create([
                    'purchase_order_id' => $order->id,
                    'item_id' => $item['item_id'],
                    'description' => $item['description'] ?? null,
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'] ?? 'pcs',
                    'rate' => $item['rate'],
                    'tax_rate' => $item['tax_rate'],
                    'discount_rate' => $item['discount_rate'] ?? 0,
                    'amount' => $itemAmount,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Purchase order updated successfully',
                'data' => $order->load(['party', 'items.item']),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to update purchase order: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $order = PurchaseOrder::findOrFail($id);
            $order->delete();

            return response()->json([
                'success' => true,
                'message' => 'Purchase order deleted successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete purchase order: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function convertToInvoice($id)
    {
        try {
            DB::beginTransaction();

            // Get the purchase order with items
            $order = PurchaseOrder::with('items')->findOrFail($id);

            // Check if already converted
            if ($order->converted_to_invoice) {
                return response()->json([
                    'success' => false,
                    'message' => 'This purchase order has already been converted to an invoice',
                ], 400);
            }

            // Generate invoice number
            $lastInvoice = \App\Models\PurchaseInvoice::where('organization_id', $order->organization_id)
                ->orderBy('id', 'desc')
                ->first();

            if ($lastInvoice && $lastInvoice->invoice_number) {
                // Extract number from last invoice (e.g., "PI-000123" -> 123)
                preg_match('/\d+/', $lastInvoice->invoice_number, $matches);
                $lastNumber = isset($matches[0]) ? intval($matches[0]) : 0;
                $newNumber = $lastNumber + 1;
            } else {
                $newNumber = 1;
            }

            $invoiceNumber = 'PI-' . str_pad($newNumber, 6, '0', STR_PAD_LEFT);

            // Prepare invoice data
            $invoiceData = [
                'organization_id' => $order->organization_id,
                'party_id' => $order->party_id,
                'invoice_number' => $invoiceNumber,
                'invoice_date' => now()->format('Y-m-d'),
                'due_date' => now()->addDays(30)->format('Y-m-d'),
                'discount_amount' => $order->discount_amount ?? 0,
                'notes' => $order->notes,
                'terms' => $order->terms,
                'status' => 'pending',
            ];

            // Add optional fields if they exist in the table
            if (Schema::hasColumn('purchase_invoices', 'additional_charges')) {
                $invoiceData['additional_charges'] = $order->additional_charges ?? 0;
            }
            if (Schema::hasColumn('purchase_invoices', 'round_off')) {
                $invoiceData['round_off'] = $order->round_off ?? 0;
            }
            if (Schema::hasColumn('purchase_invoices', 'auto_round_off')) {
                $invoiceData['auto_round_off'] = $order->auto_round_off ?? false;
            }
            if (Schema::hasColumn('purchase_invoices', 'fully_paid')) {
                $invoiceData['fully_paid'] = $order->fully_paid ?? false;
            }
            if (Schema::hasColumn('purchase_invoices', 'bank_account_id')) {
                $invoiceData['bank_account_id'] = $order->bank_account_id;
            }
            if (Schema::hasColumn('purchase_invoices', 'payment_mode')) {
                $invoiceData['payment_mode'] = $order->payment_mode;
            }
            if (Schema::hasColumn('purchase_invoices', 'payment_amount')) {
                $invoiceData['payment_amount'] = $order->payment_amount;
            }

            // Create purchase invoice
            $invoice = \App\Models\PurchaseInvoice::create($invoiceData);

            // Calculate totals
            $subtotal = 0;
            $taxAmount = 0;

            // Copy items from purchase order to purchase invoice
            foreach ($order->items as $orderItem) {
                // Calculate item amount
                $itemSubtotal = $orderItem->quantity * $orderItem->rate;
                $itemTax = ($itemSubtotal * $orderItem->tax_rate) / 100;
                $itemAmount = $itemSubtotal + $itemTax;

                \App\Models\PurchaseInvoiceItem::create([
                    'purchase_invoice_id' => $invoice->id,
                    'item_id' => $orderItem->item_id,
                    'quantity' => $orderItem->quantity,
                    'unit' => $orderItem->unit,
                    'rate' => $orderItem->rate,
                    'tax_rate' => $orderItem->tax_rate,
                    'discount_rate' => $orderItem->discount_rate ?? 0,
                    'amount' => $itemAmount,
                ]);

                $subtotal += $itemSubtotal;
                $taxAmount += $itemTax;

                // Update stock quantity (increase for purchase)
                $item = \App\Models\Item::find($orderItem->item_id);
                if ($item) {
                    $item->stock_qty = ($item->stock_qty ?? 0) + $orderItem->quantity;
                    $item->save();
                }
            }

            // Calculate total amount
            $totalAmount = $subtotal + $taxAmount - ($order->discount_amount ?? 0) + ($order->additional_charges ?? 0) + ($order->round_off ?? 0);

            // Determine payment amount and status
            $paymentAmount = $order->payment_amount ?? ($order->fully_paid ? $totalAmount : 0);
            $paidAmount = $order->fully_paid ? $paymentAmount : 0;
            $balanceAmount = $totalAmount - $paidAmount;
            
            // Determine invoice status
            if ($paidAmount >= $totalAmount) {
                $invoiceStatus = 'paid';
            } elseif ($paidAmount > 0) {
                $invoiceStatus = 'partial';
            } else {
                $invoiceStatus = 'pending';
            }

            // Update invoice with calculated totals
            $invoice->subtotal = $subtotal;
            $invoice->tax_amount = $taxAmount;
            $invoice->total_amount = $totalAmount;
            $invoice->paid_amount = $paidAmount;
            $invoice->balance_amount = $balanceAmount;
            $invoice->status = $invoiceStatus;
            $invoice->save();

            // Update bank account balance if payment was made
            if ($order->bank_account_id && $order->payment_mode && $order->payment_mode !== 'Cash') {
                $bankAccount = \App\Models\BankAccount::find($order->bank_account_id);
                if ($bankAccount) {
                    // Calculate total amount
                    $subtotal = $order->items->sum(function ($item) {
                        return $item->quantity * $item->rate;
                    });
                    $taxAmount = $order->items->sum(function ($item) {
                        return ($item->quantity * $item->rate * $item->tax_rate) / 100;
                    });
                    $totalAmount = $subtotal + $taxAmount - $order->discount_amount + $order->additional_charges + $order->round_off;

                    // Decrease balance for purchase (money out)
                    $paymentAmount = $order->payment_amount ?? $totalAmount;
                    $bankAccount->balance = ($bankAccount->balance ?? 0) - $paymentAmount;
                    $bankAccount->save();

                    // Create bank transaction record
                    \App\Models\BankTransaction::create([
                        'bank_account_id' => $order->bank_account_id,
                        'organization_id' => $order->organization_id,
                        'transaction_type' => 'debit',
                        'amount' => $paymentAmount,
                        'transaction_date' => now()->format('Y-m-d'),
                        'description' => "Purchase Invoice #{$invoice->invoice_number} (Converted from PO #{$order->po_number})",
                        'reference_type' => 'purchase_invoice',
                        'reference_id' => $invoice->id,
                    ]);
                }
            }

            // Mark purchase order as converted
            $order->converted_to_invoice = true;
            $order->purchase_invoice_id = $invoice->id;
            $order->converted_at = now();
            $order->status = 'converted';
            $order->save();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Purchase order converted to invoice successfully',
                'data' => [
                    'invoice_id' => $invoice->id,
                    'invoice_number' => $invoice->invoice_number,
                ],
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to convert purchase order: ' . $e->getMessage(),
            ], 500);
        }
    }
}
