<?php

namespace App\Http\Controllers;

use App\Models\SalesReturn;
use App\Models\SalesReturnItem;
use App\Models\Item;
use App\Models\BankAccount;
use App\Models\BankTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SalesReturnController extends Controller
{
    public function index(Request $request)
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

        $query = SalesReturn::with(['party', 'salesInvoice', 'items.item'])
            ->where('organization_id', $organizationId);

        // Filter by date range
        if ($request->has('date_filter')) {
            $days = match($request->date_filter) {
                'Last 7 Days' => 7,
                'Last 30 Days' => 30,
                'Last 365 Days' => 365,
                default => 365
            };
            $query->where('return_date', '>=', now()->subDays($days));
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('return_number', 'like', "%{$search}%")
                  ->orWhere('invoice_number', 'like', "%{$search}%")
                  ->orWhereHas('party', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $returns = $query->orderBy('return_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        return response()->json([
            'returns' => $returns,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'organization_id' => 'required|exists:organizations,id',
            'party_id' => 'required|exists:parties,id',
            'return_number' => 'required|string|max:50',
            'return_date' => 'required|date',
            'invoice_number' => 'nullable|string|max:50',
            'sales_invoice_id' => 'nullable|exists:sales_invoices,id',
            'subtotal' => 'required|numeric|min:0',
            'discount' => 'nullable|numeric|min:0',
            'tax' => 'nullable|numeric|min:0',
            'total_amount' => 'required|numeric|min:0',
            'amount_paid' => 'nullable|numeric|min:0',
            'payment_mode' => 'nullable|string|max:50',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'status' => 'required|in:unpaid,refunded',
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

            // Check for duplicate return number
            $exists = SalesReturn::where('organization_id', $organizationId)
                ->where('return_number', $request->return_number)
                ->exists();
                
            if ($exists) {
                return response()->json([
                    'message' => 'Return number already exists'
                ], 422);
            }

            DB::beginTransaction();

            // Create sales return
            $salesReturn = SalesReturn::create([
                'organization_id' => $organizationId,
                'party_id' => $request->party_id,
                'user_id' => $request->user()->id,
                'sales_invoice_id' => $request->sales_invoice_id,
                'return_number' => $request->return_number,
                'return_date' => $request->return_date,
                'invoice_number' => $request->invoice_number,
                'subtotal' => $request->subtotal,
                'discount' => $request->discount ?? 0,
                'tax' => $request->tax ?? 0,
                'total_amount' => $request->total_amount,
                'amount_paid' => $request->amount_paid ?? 0,
                'payment_mode' => $request->payment_mode,
                'status' => $request->status,
                'notes' => $request->notes,
                'terms_conditions' => $request->terms_conditions,
            ]);

            // Create sales return items and update stock
            foreach ($request->items as $item) {
                SalesReturnItem::create([
                    'sales_return_id' => $salesReturn->id,
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

                // Increase stock (items returned to inventory)
                $inventoryItem = Item::find($item['item_id']);
                if ($inventoryItem) {
                    $inventoryItem->increment('stock_qty', $item['quantity']);
                }
            }

            // Process refund if status is refunded
            if ($request->status === 'refunded' && $request->amount_paid > 0) {
                $this->processRefund($request, $organizationId, $salesReturn);
            }

            DB::commit();

            return response()->json([
                'message' => 'Sales return created successfully',
                'return' => $salesReturn->load(['party', 'items.item']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create sales return',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $salesReturn = SalesReturn::with(['party', 'salesInvoice', 'items.item', 'organization'])
            ->findOrFail($id);

        return response()->json($salesReturn);
    }

    public function update(Request $request, $id)
    {
        $salesReturn = SalesReturn::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'party_id' => 'sometimes|exists:parties,id',
            'return_date' => 'sometimes|date',
            'invoice_number' => 'nullable|string|max:50',
            'sales_invoice_id' => 'nullable|exists:sales_invoices,id',
            'subtotal' => 'sometimes|numeric|min:0',
            'discount' => 'nullable|numeric|min:0',
            'tax' => 'nullable|numeric|min:0',
            'total_amount' => 'sometimes|numeric|min:0',
            'amount_paid' => 'nullable|numeric|min:0',
            'payment_mode' => 'nullable|string|max:50',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'status' => 'sometimes|in:unpaid,refunded',
            'notes' => 'nullable|string',
            'terms_conditions' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            DB::beginTransaction();

            $oldAmountPaid = $salesReturn->amount_paid;
            $oldStatus = $salesReturn->status;
            $organizationId = $salesReturn->organization_id;

            // If amount paid or status changed
            if ($request->has('amount_paid') || $request->has('status')) {
                $newAmountPaid = $request->has('amount_paid') ? $request->amount_paid : $oldAmountPaid;
                $newStatus = $request->has('status') ? $request->status : $oldStatus;

                // Find and reverse old bank transaction if exists
                if ($oldStatus === 'refunded' && $oldAmountPaid > 0) {
                    $oldTransaction = BankTransaction::where('description', 'like', "%Sales Return Refund: {$salesReturn->return_number}%")
                        ->where('organization_id', $organizationId)
                        ->first();

                    if ($oldTransaction) {
                        $oldAccount = BankAccount::find($oldTransaction->account_id);
                        if ($oldAccount) {
                            // Reverse old transaction (add back the refunded amount)
                            $oldAccount->increment('current_balance', $oldAmountPaid);
                        }
                        $oldTransaction->delete();
                    }
                }

                // Create new bank transaction if status is refunded
                if ($newStatus === 'refunded' && $newAmountPaid > 0) {
                    $paymentMode = $request->has('payment_mode') ? $request->payment_mode : $salesReturn->payment_mode;
                    $description = "Sales Return Refund: {$salesReturn->return_number}";
                    
                    if ($request->notes) {
                        $description .= " - {$request->notes}";
                    }

                    if (strtolower($paymentMode) === 'cash') {
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
                            'transaction_type' => 'sales_return',
                            'amount' => $newAmountPaid,
                            'transaction_date' => $salesReturn->return_date,
                            'description' => $description,
                        ]);
                    } else {
                        $bankAccountId = $request->has('bank_account_id') ? $request->bank_account_id : null;
                        
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
                                    'transaction_type' => 'sales_return',
                                    'amount' => $newAmountPaid,
                                    'transaction_date' => $salesReturn->return_date,
                                    'description' => $description,
                                ]);
                            }
                        }
                    }
                }
            }

            $salesReturn->update($request->only([
                'party_id',
                'return_date',
                'invoice_number',
                'sales_invoice_id',
                'subtotal',
                'discount',
                'tax',
                'total_amount',
                'amount_paid',
                'payment_mode',
                'status',
                'notes',
                'terms_conditions',
            ]));

            DB::commit();

            return response()->json([
                'message' => 'Sales return updated successfully with bank balance adjustment',
                'return' => $salesReturn->load(['party', 'items.item']),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to update sales return',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $salesReturn = SalesReturn::findOrFail($id);
            $salesReturn->delete();

            return response()->json([
                'message' => 'Sales return deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete sales return',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextReturnNumber(Request $request)
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

        $lastReturn = SalesReturn::where('organization_id', $organizationId)
            ->orderBy('return_number', 'desc')
            ->first();

        $nextNumber = $lastReturn ? ((int)$lastReturn->return_number + 1) : 1;

        return response()->json([
            'next_number' => $nextNumber,
        ]);
    }

    /**
     * Process refund and update bank account balance
     */
    private function processRefund(Request $request, $organizationId, $salesReturn)
    {
        $amount = $request->amount_paid;
        $paymentMode = $request->payment_mode ?? 'cash';
        $description = "Sales Return Refund: {$salesReturn->return_number}";
        
        if ($request->notes) {
            $description .= " - {$request->notes}";
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

            // Decrease cash balance (refund to customer)
            $cashAccount->decrement('current_balance', $amount);

            // Create transaction record
            BankTransaction::create([
                'user_id' => $request->user()->id,
                'organization_id' => $organizationId,
                'account_id' => $cashAccount->id,
                'transaction_type' => 'sales_return',
                'amount' => $amount,
                'transaction_date' => $request->return_date,
                'description' => $description,
            ]);
        } else {
            // For non-cash refunds, update the specified bank account
            if ($request->has('bank_account_id') && $request->bank_account_id) {
                $bankAccount = BankAccount::where('id', $request->bank_account_id)
                    ->where('organization_id', $organizationId)
                    ->first();

                if ($bankAccount) {
                    // Decrease bank balance (refund to customer)
                    $bankAccount->decrement('current_balance', $amount);

                    // Create transaction record
                    BankTransaction::create([
                        'user_id' => $request->user()->id,
                        'organization_id' => $organizationId,
                        'account_id' => $bankAccount->id,
                        'transaction_type' => 'sales_return',
                        'amount' => $amount,
                        'transaction_date' => $request->return_date,
                        'description' => $description,
                    ]);
                }
            }
        }
    }
}
