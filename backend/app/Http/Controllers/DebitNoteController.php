<?php

namespace App\Http\Controllers;

use App\Models\DebitNote;
use App\Models\BankAccount;
use App\Models\BankTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DebitNoteController extends Controller
{
    public function index(Request $request)
    {
        $notes = DebitNote::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('debit_note_date', 'desc')
            ->paginate(20);

        return response()->json($notes);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'party_id' => 'required|exists:parties,id',
            'purchase_invoice_id' => 'nullable|exists:purchase_invoices,id',
            'debit_note_number' => 'required|unique:debit_notes',
            'debit_note_date' => 'required|date',
            'payment_mode' => 'nullable|string|max:50',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'amount_paid' => 'nullable|numeric|min:0',
            'status' => 'required|in:draft,issued,cancelled',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'nullable|exists:items,id',
            'items.*.description' => 'required|string',
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

            $debitNote = DebitNote::create([
                'organization_id' => $request->header('X-Organization-Id'),
                'party_id' => $validated['party_id'],
                'purchase_invoice_id' => $validated['purchase_invoice_id'] ?? null,
                'debit_note_number' => $validated['debit_note_number'],
                'debit_note_date' => $validated['debit_note_date'],
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'total_amount' => $subtotal + $taxAmount,
                'payment_mode' => $validated['payment_mode'] ?? null,
                'bank_account_id' => $validated['bank_account_id'] ?? null,
                'amount_paid' => $validated['amount_paid'] ?? 0,
                'status' => $validated['status'],
                'reason' => $validated['reason'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            foreach ($validated['items'] as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = $itemSubtotal * (($item['tax_rate'] ?? 0) / 100);

                $debitNote->items()->create([
                    'item_id' => $item['item_id'] ?? null,
                    'description' => $item['description'],
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'] ?? 'pcs',
                    'rate' => $item['rate'],
                    'tax_rate' => $item['tax_rate'] ?? 0,
                    'amount' => $itemSubtotal + $itemTax,
                ]);
            }

            // Process payment if amount paid
            if (isset($validated['amount_paid']) && $validated['amount_paid'] > 0) {
                $this->processPayment($request, $request->header('X-Organization-Id'), $debitNote, $validated);
            }

            return response()->json($debitNote->load(['party', 'items.item']), 201);
        });
    }

    public function show($id, Request $request)
    {
        $debitNote = DebitNote::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($debitNote);
    }

    public function update(Request $request, $id)
    {
        $debitNote = DebitNote::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $validated = $request->validate([
            'party_id' => 'sometimes|exists:parties,id',
            'debit_note_date' => 'sometimes|date',
            'amount_paid' => 'nullable|numeric|min:0',
            'payment_mode' => 'nullable|string|max:50',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'status' => 'sometimes|in:draft,issued,cancelled',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        try {
            DB::beginTransaction();

            $oldAmountPaid = $debitNote->amount_paid;
            $organizationId = $debitNote->organization_id;

            // If amount paid is being updated
            if ($request->has('amount_paid')) {
                $newAmountPaid = $request->amount_paid;

                // Find and reverse old bank transaction
                if ($oldAmountPaid > 0) {
                    $oldTransaction = BankTransaction::where('description', 'like', "%Debit Note Payment: {$debitNote->debit_note_number}%")
                        ->where('organization_id', $organizationId)
                        ->first();

                    if ($oldTransaction) {
                        $oldAccount = BankAccount::find($oldTransaction->account_id);
                        if ($oldAccount) {
                            // Reverse old transaction (add back the old amount since it was deducted)
                            $oldAccount->increment('current_balance', $oldAmountPaid);
                        }
                        $oldTransaction->delete();
                    }
                }

                // Create new bank transaction if amount paid
                if ($newAmountPaid > 0) {
                    $paymentMode = $request->has('payment_mode') ? strtolower($request->payment_mode) : strtolower($debitNote->payment_mode ?? 'cash');
                    $description = "Debit Note Payment: {$debitNote->debit_note_number}";
                    
                    if ($request->notes) {
                        $description .= " - {$request->notes}";
                    }

                    if ($paymentMode === 'cash') {
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

                        $cashAccount->decrement('current_balance', $newAmountPaid);

                        BankTransaction::create([
                            'user_id' => $request->user()->id,
                            'organization_id' => $organizationId,
                            'account_id' => $cashAccount->id,
                            'transaction_type' => 'debit_note',
                            'amount' => $newAmountPaid,
                            'transaction_date' => $debitNote->debit_note_date,
                            'description' => $description,
                        ]);
                    } else {
                        $bankAccountId = $request->has('bank_account_id') ? $request->bank_account_id : $debitNote->bank_account_id;
                        
                        if ($bankAccountId) {
                            $bankAccount = BankAccount::where('id', $bankAccountId)
                                ->where('organization_id', $organizationId)
                                ->first();

                            if ($bankAccount) {
                                $bankAccount->decrement('current_balance', $newAmountPaid);

                                BankTransaction::create([
                                    'user_id' => $request->user()->id,
                                    'organization_id' => $organizationId,
                                    'account_id' => $bankAccount->id,
                                    'transaction_type' => 'debit_note',
                                    'amount' => $newAmountPaid,
                                    'transaction_date' => $debitNote->debit_note_date,
                                    'description' => $description,
                                ]);
                            }
                        }
                    }
                }
            }

            $debitNote->update($validated);

            DB::commit();

            return response()->json([
                'message' => 'Debit note updated successfully with bank balance adjustment',
                'debit_note' => $debitNote->load(['party', 'items.item'])
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to update debit note',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id, Request $request)
    {
        $debitNote = DebitNote::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $debitNote->delete();

        return response()->json(['message' => 'Debit note deleted successfully']);
    }

    public function getNextNumber(Request $request)
    {
        $lastNote = DebitNote::where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('id', 'desc')
            ->first();

        $nextNumber = $lastNote 
            ? 'DN-' . str_pad((int)substr($lastNote->debit_note_number, 3) + 1, 6, '0', STR_PAD_LEFT)
            : 'DN-000001';

        return response()->json(['next_number' => $nextNumber]);
    }

    /**
     * Process payment and update bank account balance (DECREASE for debit note)
     */
    private function processPayment(Request $request, $organizationId, $debitNote, $validated)
    {
        try {
            $amount = $validated['amount_paid'];
            $paymentMode = strtolower($validated['payment_mode'] ?? 'cash');
            $description = "Debit Note Payment: {$debitNote->debit_note_number}";
            
            if (isset($validated['notes']) && $validated['notes']) {
                $description .= " - {$validated['notes']}";
            }

            \Log::info('Processing debit note payment', [
                'amount' => $amount,
                'payment_mode' => $paymentMode,
                'organization_id' => $organizationId,
                'debit_note_id' => $debitNote->id,
            ]);

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

                \Log::info('Cash account found/created', ['account_id' => $cashAccount->id, 'current_balance' => $cashAccount->current_balance]);

                // DECREASE cash balance (payment made to supplier)
                $cashAccount->decrement('current_balance', $amount);

                \Log::info('Cash balance updated', ['new_balance' => $cashAccount->fresh()->current_balance]);

                // Create transaction record
                $transaction = BankTransaction::create([
                    'user_id' => $request->user()->id,
                    'organization_id' => $organizationId,
                    'account_id' => $cashAccount->id,
                    'transaction_type' => 'debit_note',
                    'amount' => $amount,
                    'transaction_date' => $validated['debit_note_date'],
                    'description' => $description,
                ]);

                \Log::info('Transaction created', ['transaction_id' => $transaction->id]);
            } else {
                // For non-cash payments, update the specified bank account
                \Log::info('Processing bank payment', ['bank_account_id' => $validated['bank_account_id'] ?? null]);

                if (isset($validated['bank_account_id']) && $validated['bank_account_id']) {
                    $bankAccount = BankAccount::where('id', $validated['bank_account_id'])
                        ->where('organization_id', $organizationId)
                        ->first();

                    if ($bankAccount) {
                        \Log::info('Bank account found', ['account_id' => $bankAccount->id, 'current_balance' => $bankAccount->current_balance]);

                        // DECREASE bank balance (payment made to supplier)
                        $bankAccount->decrement('current_balance', $amount);

                        \Log::info('Bank balance updated', ['new_balance' => $bankAccount->fresh()->current_balance]);

                        // Create transaction record
                        $transaction = BankTransaction::create([
                            'user_id' => $request->user()->id,
                            'organization_id' => $organizationId,
                            'account_id' => $bankAccount->id,
                            'transaction_type' => 'debit_note',
                            'amount' => $amount,
                            'transaction_date' => $validated['debit_note_date'],
                            'description' => $description,
                        ]);

                        \Log::info('Bank transaction created', ['transaction_id' => $transaction->id]);
                    } else {
                        \Log::warning('Bank account not found', ['bank_account_id' => $validated['bank_account_id']]);
                    }
                } else {
                    \Log::warning('No bank account ID provided for non-cash payment');
                }
            }
        } catch (\Exception $e) {
            \Log::error('Error processing debit note payment', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            throw $e;
        }
    }
}
