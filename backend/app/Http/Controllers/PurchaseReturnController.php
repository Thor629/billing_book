<?php

namespace App\Http\Controllers;

use App\Models\PurchaseReturn;
use App\Models\Item;
use App\Models\BankAccount;
use App\Models\BankTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseReturnController extends Controller
{
    public function index(Request $request)
    {
        $returns = PurchaseReturn::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('return_date', 'desc')
            ->paginate(20);

        return response()->json($returns);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'party_id' => 'required|exists:parties,id',
            'purchase_invoice_id' => 'nullable|exists:purchase_invoices,id',
            'return_number' => 'required|unique:purchase_returns',
            'return_date' => 'required|date',
            'status' => 'required|in:draft,pending,approved,rejected',
            'payment_mode' => 'nullable|string|max:50',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'amount_received' => 'nullable|numeric|min:0',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.rate' => 'required|numeric|min:0',
            'items.*.tax_rate' => 'nullable|numeric|min:0|max:100',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $subtotal = 0;
            $taxAmount = 0;

            foreach ($validated['items'] as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = $itemSubtotal * (($item['tax_rate'] ?? 0) / 100);
                $subtotal += $itemSubtotal;
                $taxAmount += $itemTax;
            }

            $return = PurchaseReturn::create([
                'organization_id' => $request->header('X-Organization-Id'),
                'party_id' => $validated['party_id'],
                'purchase_invoice_id' => $validated['purchase_invoice_id'] ?? null,
                'return_number' => $validated['return_number'],
                'return_date' => $validated['return_date'],
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'total_amount' => $subtotal + $taxAmount,
                'payment_mode' => $validated['payment_mode'] ?? null,
                'bank_account_id' => $validated['bank_account_id'] ?? null,
                'amount_received' => $validated['amount_received'] ?? 0,
                'status' => $validated['status'],
                'reason' => $validated['reason'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            foreach ($validated['items'] as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = $itemSubtotal * (($item['tax_rate'] ?? 0) / 100);

                $return->items()->create([
                    'item_id' => $item['item_id'],
                    'description' => $item['description'] ?? null,
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'] ?? 'pcs',
                    'rate' => $item['rate'],
                    'tax_rate' => $item['tax_rate'] ?? 0,
                    'amount' => $itemSubtotal + $itemTax,
                ]);

                // Decrease stock (items returned to supplier)
                $inventoryItem = Item::find($item['item_id']);
                if ($inventoryItem) {
                    $inventoryItem->decrement('stock_qty', $item['quantity']);
                }
            }

            // Process refund if amount received
            if (isset($validated['amount_received']) && $validated['amount_received'] > 0) {
                $this->processRefund($request, $request->header('X-Organization-Id'), $return, $validated);
            }

            return response()->json($return->load(['party', 'items.item']), 201);
        });
    }

    public function show($id, Request $request)
    {
        $return = PurchaseReturn::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($return);
    }

    public function destroy($id, Request $request)
    {
        $return = PurchaseReturn::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $return->delete();

        return response()->json(['message' => 'Purchase return deleted successfully']);
    }

    public function getNextReturnNumber(Request $request)
    {
        $lastReturn = PurchaseReturn::where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('id', 'desc')
            ->first();

        $nextNumber = $lastReturn 
            ? 'PR-' . str_pad((int)substr($lastReturn->return_number, 3) + 1, 6, '0', STR_PAD_LEFT)
            : 'PR-000001';

        return response()->json(['next_number' => $nextNumber]);
    }

    /**
     * Process refund and update bank account balance
     */
    private function processRefund(Request $request, $organizationId, $return, $validated)
    {
        $amount = $validated['amount_received'];
        $paymentMode = $validated['payment_mode'] ?? 'cash';
        $description = "Purchase Return Refund: {$return->return_number}";
        
        if (isset($validated['notes'])) {
            $description .= " - {$validated['notes']}";
        }

        if ($paymentMode === 'cash') {
            // Find or create "Cash in Hand" account
            $cashAccount = BankAccount::firstOrCreate(
                [
                    'organization_id' => $organizationId,
                    'account_name' => 'Cash in Hand',
                    'account_type' => 'cash',
                ],
                [
                    'user_id' => $request->user()->id,
                    'opening_balance' => 0,
                    'current_balance' => 0,
                    'as_of_date' => now(),
                ]
            );

            // Increase cash balance (refund received from supplier)
            $cashAccount->increment('current_balance', $amount);

            // Create transaction record
            BankTransaction::create([
                'user_id' => $request->user()->id,
                'organization_id' => $organizationId,
                'account_id' => $cashAccount->id,
                'transaction_type' => 'purchase_return',
                'amount' => $amount,
                'transaction_date' => $validated['return_date'],
                'description' => $description,
            ]);
        } else {
            // For non-cash refunds, update the specified bank account
            if (isset($validated['bank_account_id']) && $validated['bank_account_id']) {
                $bankAccount = BankAccount::where('id', $validated['bank_account_id'])
                    ->where('organization_id', $organizationId)
                    ->first();

                if ($bankAccount) {
                    // Increase bank balance (refund received from supplier)
                    $bankAccount->increment('current_balance', $amount);

                    // Create transaction record
                    BankTransaction::create([
                        'user_id' => $request->user()->id,
                        'organization_id' => $organizationId,
                        'account_id' => $bankAccount->id,
                        'transaction_type' => 'purchase_return',
                        'amount' => $amount,
                        'transaction_date' => $validated['return_date'],
                        'description' => $description,
                    ]);
                }
            }
        }
    }
}
