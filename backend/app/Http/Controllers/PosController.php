<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PosController extends Controller
{
    /**
     * Search items for POS billing
     * Search by name, code, or barcode
     */
    public function searchItems(Request $request)
    {
        $request->validate([
            'organization_id' => 'required|integer',
            'search' => 'required|string|min:1',
        ]);

        $organizationId = $request->organization_id;
        $search = $request->search;

        // Search items by name, code, or barcode
        $items = Item::where('organization_id', $organizationId)
            ->where(function ($query) use ($search) {
                $query->where('item_name', 'LIKE', "%{$search}%")
                    ->orWhere('item_code', 'LIKE', "%{$search}%")
                    ->orWhere('barcode', 'LIKE', "%{$search}%");
            })
            ->where('is_active', 1)
            ->select([
                'id',
                'item_name',
                'item_code',
                'barcode',
                'selling_price',
                'purchase_price',
                'mrp',
                'gst_rate',
                'hsn_code',
                'unit',
                'stock_qty',
                'low_stock_alert',
            ])
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $items,
        ]);
    }

    /**
     * Get item by exact barcode (for barcode scanner)
     */
    public function getItemByBarcode(Request $request)
    {
        $request->validate([
            'organization_id' => 'required|integer',
            'barcode' => 'required|string',
        ]);

        $item = Item::where('organization_id', $request->organization_id)
            ->where('barcode', $request->barcode)
            ->where('is_active', 1)
            ->first();

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Item not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $item,
        ]);
    }

    /**
     * Get item by ID
     */
    public function getItem(Request $request, $id)
    {
        $request->validate([
            'organization_id' => 'required|integer',
        ]);

        $item = Item::where('organization_id', $request->organization_id)
            ->where('id', $id)
            ->where('is_active', 1)
            ->first();

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Item not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $item,
        ]);
    }

    /**
     * Save POS bill (create sales invoice)
     */
    public function saveBill(Request $request)
    {
        $request->validate([
            'organization_id' => 'required|integer',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|integer',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.selling_price' => 'required|numeric|min:0',
            'items.*.gst_rate' => 'required|numeric|min:0',
            'discount' => 'nullable|numeric|min:0',
            'additional_charge' => 'nullable|numeric|min:0',
            'payment_method' => 'required|string|in:cash,card,upi,cheque',
            'received_amount' => 'required|numeric|min:0',
            'customer_id' => 'nullable|integer',
            'is_cash_sale' => 'boolean',
        ]);

        DB::beginTransaction();
        try {
            // Calculate totals
            $subTotal = 0;
            $totalTax = 0;
            
            foreach ($request->items as $item) {
                $itemTotal = $item['quantity'] * $item['selling_price'];
                $itemTax = ($itemTotal * $item['gst_rate']) / 100;
                $subTotal += $itemTotal;
                $totalTax += $itemTax;
            }

            $discount = $request->discount ?? 0;
            $additionalCharge = $request->additional_charge ?? 0;
            $totalAmount = $subTotal + $totalTax - $discount + $additionalCharge;

            // Generate invoice number
            $lastInvoice = DB::table('sales_invoices')
                ->where('organization_id', $request->organization_id)
                ->where('invoice_prefix', 'POS-')
                ->orderBy('id', 'desc')
                ->first();
            
            $nextNumber = $lastInvoice ? (intval($lastInvoice->invoice_number) + 1) : 1;
            $invoiceNumber = str_pad($nextNumber, 6, '0', STR_PAD_LEFT);

            // Create sales invoice
            $invoiceId = DB::table('sales_invoices')->insertGetId([
                'organization_id' => $request->organization_id,
                'invoice_prefix' => 'POS-',
                'invoice_number' => $invoiceNumber,
                'invoice_date' => now(),
                'party_id' => $request->customer_id,
                'user_id' => auth()->id(),
                'payment_terms' => 0,
                'due_date' => now(),
                'subtotal' => $subTotal,
                'discount_amount' => $discount,
                'additional_charges' => $additionalCharge,
                'tax_amount' => $totalTax,
                'round_off' => 0,
                'total_amount' => $totalAmount,
                'amount_received' => $request->received_amount,
                'balance_amount' => 0,
                'payment_mode' => $request->payment_method,
                'payment_status' => 'paid',
                'show_bank_details' => false,
                'auto_round_off' => false,
                'invoice_status' => 'final',
                'is_einvoice_generated' => false,
                'is_reconciled' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Create invoice items
            foreach ($request->items as $item) {
                // Get item details
                $itemDetails = DB::table('items')
                    ->where('id', $item['item_id'])
                    ->first();

                $itemTotal = $item['quantity'] * $item['selling_price'];
                $itemTax = ($itemTotal * $item['gst_rate']) / 100;

                DB::table('sales_invoice_items')->insert([
                    'sales_invoice_id' => $invoiceId,
                    'item_id' => $item['item_id'],
                    'item_name' => $itemDetails->item_name ?? 'Unknown Item',
                    'hsn_sac' => $itemDetails->hsn_code ?? null,
                    'item_code' => $itemDetails->item_code ?? null,
                    'mrp' => $itemDetails->mrp ?? 0,
                    'quantity' => $item['quantity'],
                    'unit' => $itemDetails->unit ?? 'PCS',
                    'price_per_unit' => $item['selling_price'],
                    'discount_percent' => 0,
                    'discount_amount' => 0,
                    'tax_percent' => $item['gst_rate'],
                    'tax_amount' => $itemTax,
                    'line_total' => $itemTotal + $itemTax,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                // Update stock
                DB::table('items')
                    ->where('id', $item['item_id'])
                    ->decrement('stock_qty', $item['quantity']);
            }

            // Create payment record
            DB::table('payments')->insert([
                'organization_id' => $request->organization_id,
                'invoice_id' => $invoiceId,
                'invoice_type' => 'sales',
                'payment_date' => now(),
                'amount' => $request->received_amount,
                'payment_method' => $request->payment_method,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Update Cash/Bank balance based on payment method
            $accountType = ($request->payment_method === 'cash') ? 'cash' : 'bank';
            
            // Find or create the account
            $account = DB::table('bank_accounts')
                ->where('organization_id', $request->organization_id)
                ->where('account_type', $accountType)
                ->first();

            if ($account) {
                // Create bank transaction (add money)
                DB::table('bank_transactions')->insert([
                    'user_id' => auth()->id(),
                    'organization_id' => $request->organization_id,
                    'account_id' => $account->id,
                    'transaction_type' => 'add',
                    'amount' => $request->received_amount,
                    'transaction_date' => now(),
                    'description' => 'POS Sale - Invoice: POS-' . $invoiceNumber,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                // Update account balance
                DB::table('bank_accounts')
                    ->where('id', $account->id)
                    ->increment('current_balance', $request->received_amount);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Bill saved successfully',
                'data' => [
                    'invoice_id' => $invoiceId,
                    'invoice_number' => 'POS-' . $invoiceNumber,
                    'total_amount' => $totalAmount,
                ],
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to save bill: ' . $e->getMessage(),
            ], 500);
        }
    }
}
