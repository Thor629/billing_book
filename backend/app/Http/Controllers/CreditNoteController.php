<?php

namespace App\Http\Controllers;

use App\Models\CreditNote;
use App\Models\CreditNoteItem;
use App\Models\BankAccount;
use App\Models\BankTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CreditNoteController extends Controller
{
    public function index(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json(['message' => 'Organization ID is required'], 400);
        }

        $hasAccess = $request->user()->organizations()->where('organizations.id', $organizationId)->exists();
        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied to this organization'], 403);
        }

        $query = CreditNote::with(['party', 'salesInvoice', 'items.item'])->where('organization_id', $organizationId);

        if ($request->has('date_filter')) {
            $days = match($request->date_filter) {
                'Last 7 Days' => 7,
                'Last 30 Days' => 30,
                'Last 365 Days' => 365,
                default => 365
            };
            $query->where('credit_note_date', '>=', now()->subDays($days));
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('credit_note_number', 'like', "%{$search}%")
                  ->orWhere('invoice_number', 'like', "%{$search}%")
                  ->orWhereHas('party', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $creditNotes = $query->orderBy('credit_note_date', 'desc')->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);

        return response()->json(['credit_notes' => $creditNotes]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'organization_id' => 'required|exists:organizations,id',
            'party_id' => 'required|exists:parties,id',
            'credit_note_number' => 'required|string|max:50',
            'credit_note_date' => 'required|date',
            'invoice_number' => 'nullable|string|max:50',
            'sales_invoice_id' => 'nullable|exists:sales_invoices,id',
            'subtotal' => 'required|numeric|min:0',
            'discount' => 'nullable|numeric|min:0',
            'tax' => 'nullable|numeric|min:0',
            'total_amount' => 'required|numeric|min:0',
            'payment_mode' => 'nullable|string|max:50',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'amount_received' => 'nullable|numeric|min:0',
            'status' => 'required|in:draft,issued,applied',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
            'terms_conditions' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.hsn_sac' => 'nullable|string|max:50',
            'items.*.item_code' => 'nullable|string|max:50',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.price' => 'required|numeric|min:0',
            'items.*.discount' => 'nullable|numeric|min:0',
            'items.*.tax_rate' => 'nullable|numeric|min:0',
            'items.*.tax_amount' => 'nullable|numeric|min:0',
            'items.*.total' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $organizationId = $request->organization_id;
            
            $hasAccess = $request->user()->organizations()->where('organizations.id', $organizationId)->exists();
            if (!$hasAccess) {
                return response()->json(['message' => 'Access denied to this organization'], 403);
            }

            $exists = CreditNote::where('organization_id', $organizationId)->where('credit_note_number', $request->credit_note_number)->exists();
            if ($exists) {
                return response()->json(['message' => 'Credit note number already exists'], 422);
            }

            DB::beginTransaction();

            $creditNote = CreditNote::create([
                'organization_id' => $organizationId,
                'party_id' => $request->party_id,
                'user_id' => $request->user()->id,
                'sales_invoice_id' => $request->sales_invoice_id,
                'credit_note_number' => $request->credit_note_number,
                'credit_note_date' => $request->credit_note_date,
                'invoice_number' => $request->invoice_number,
                'subtotal' => $request->subtotal,
                'discount' => $request->discount ?? 0,
                'tax' => $request->tax ?? 0,
                'total_amount' => $request->total_amount,
                'payment_mode' => $request->payment_mode ?? null,
                'bank_account_id' => $request->bank_account_id ?? null,
                'amount_received' => $request->amount_received ?? 0,
                'status' => $request->status,
                'reason' => $request->reason,
                'notes' => $request->notes,
                'terms_conditions' => $request->terms_conditions,
            ]);

            foreach ($request->items as $item) {
                CreditNoteItem::create([
                    'credit_note_id' => $creditNote->id,
                    'item_id' => $item['item_id'],
                    'hsn_sac' => $item['hsn_sac'] ?? null,
                    'item_code' => $item['item_code'] ?? null,
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                    'discount' => $item['discount'] ?? 0,
                    'tax_rate' => $item['tax_rate'] ?? 0,
                    'tax_amount' => $item['tax_amount'] ?? 0,
                    'total' => $item['total'],
                ]);
            }

            // Process payment if amount received
            if (isset($request->amount_received) && $request->amount_received > 0) {
                $this->processPayment($request, $organizationId, $creditNote);
            }

            DB::commit();

            return response()->json([
                'message' => 'Credit note created successfully',
                'credit_note' => $creditNote->load(['party', 'items.item']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to create credit note', 'error' => $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        $creditNote = CreditNote::with(['party', 'salesInvoice', 'items.item', 'organization'])->findOrFail($id);
        return response()->json($creditNote);
    }

    public function update(Request $request, $id)
    {
        $creditNote = CreditNote::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'party_id' => 'sometimes|exists:parties,id',
            'credit_note_date' => 'sometimes|date',
            'invoice_number' => 'nullable|string|max:50',
            'sales_invoice_id' => 'nullable|exists:sales_invoices,id',
            'subtotal' => 'sometimes|numeric|min:0',
            'discount' => 'nullable|numeric|min:0',
            'tax' => 'nullable|numeric|min:0',
            'total_amount' => 'sometimes|numeric|min:0',
            'status' => 'sometimes|in:draft,issued,applied',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
            'terms_conditions' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $creditNote->update($request->only([
                'party_id', 'credit_note_date', 'invoice_number', 'sales_invoice_id',
                'subtotal', 'discount', 'tax', 'total_amount', 'status', 'reason', 'notes', 'terms_conditions',
            ]));

            return response()->json([
                'message' => 'Credit note updated successfully',
                'credit_note' => $creditNote->load(['party', 'items.item']),
            ]);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Failed to update credit note', 'error' => $e->getMessage()], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $creditNote = CreditNote::findOrFail($id);
            $creditNote->delete();
            return response()->json(['message' => 'Credit note deleted successfully']);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Failed to delete credit note', 'error' => $e->getMessage()], 500);
        }
    }

    public function getNextNumber(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json(['message' => 'Organization ID is required'], 400);
        }

        $hasAccess = $request->user()->organizations()->where('organizations.id', $organizationId)->exists();
        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied to this organization'], 403);
        }

        $lastCreditNote = CreditNote::where('organization_id', $organizationId)->orderBy('credit_note_number', 'desc')->first();
        $nextNumber = $lastCreditNote ? ((int)$lastCreditNote->credit_note_number + 1) : 1;

        return response()->json(['next_number' => $nextNumber]);
    }

    /**
     * Process payment and update bank account balance
     */
    private function processPayment(Request $request, $organizationId, $creditNote)
    {
        try {
            $amount = $request->amount_received;
            $paymentMode = strtolower($request->payment_mode ?? 'cash');
            $description = "Credit Note Payment: {$creditNote->credit_note_number}";
            
            if (isset($request->notes) && $request->notes) {
                $description .= " - {$request->notes}";
            }

            \Log::info('Processing credit note payment', [
                'amount' => $amount,
                'payment_mode' => $paymentMode,
                'organization_id' => $organizationId,
                'credit_note_id' => $creditNote->id,
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

                // Increase cash balance (payment received from customer)
                $cashAccount->increment('current_balance', $amount);

                \Log::info('Cash balance updated', ['new_balance' => $cashAccount->fresh()->current_balance]);

                // Create transaction record
                $transaction = BankTransaction::create([
                    'user_id' => $request->user()->id,
                    'organization_id' => $organizationId,
                    'account_id' => $cashAccount->id,
                    'transaction_type' => 'credit_note',
                    'amount' => $amount,
                    'transaction_date' => $request->credit_note_date,
                    'description' => $description,
                ]);

                \Log::info('Transaction created', ['transaction_id' => $transaction->id]);
            } else {
                // For non-cash payments, update the specified bank account
                \Log::info('Processing bank payment', ['bank_account_id' => $request->bank_account_id]);

                if (isset($request->bank_account_id) && $request->bank_account_id) {
                    $bankAccount = BankAccount::where('id', $request->bank_account_id)
                        ->where('organization_id', $organizationId)
                        ->first();

                    if ($bankAccount) {
                        \Log::info('Bank account found', ['account_id' => $bankAccount->id, 'current_balance' => $bankAccount->current_balance]);

                        // Increase bank balance (payment received from customer)
                        $bankAccount->increment('current_balance', $amount);

                        \Log::info('Bank balance updated', ['new_balance' => $bankAccount->fresh()->current_balance]);

                        // Create transaction record
                        $transaction = BankTransaction::create([
                            'user_id' => $request->user()->id,
                            'organization_id' => $organizationId,
                            'account_id' => $bankAccount->id,
                            'transaction_type' => 'credit_note',
                            'amount' => $amount,
                            'transaction_date' => $request->credit_note_date,
                            'description' => $description,
                        ]);

                        \Log::info('Bank transaction created', ['transaction_id' => $transaction->id]);
                    } else {
                        \Log::warning('Bank account not found', ['bank_account_id' => $request->bank_account_id]);
                    }
                } else {
                    \Log::warning('No bank account ID provided for non-cash payment');
                }
            }
        } catch (\Exception $e) {
            \Log::error('Error processing credit note payment', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            throw $e;
        }
    }
}
