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

        $query = SalesInvoice::with(['party', 'organization', 'user'])
            ->where('organization_id', $organizationId);

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
            'total_sales' => SalesInvoice::where('organization_id', $organizationId)
                ->sum('total_amount'),
            'paid' => SalesInvoice::where('organization_id', $organizationId)
                ->where('payment_status', 'paid')
                ->sum('total_amount'),
            'unpaid' => SalesInvoice::where('organization_id', $organizationId)
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
            'organization_id' => 'required|exists:organizations,id',
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
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Validate stock availability
        foreach ($request->items as $itemData) {
            $item = \App\Models\Item::find($itemData['item_id']);
            if ($item && $item->stock_qty < $itemData['quantity']) {
                return response()->json([
                    'message' => "Insufficient stock for item: {$item->item_name}. Available: {$item->stock_qty}, Required: {$itemData['quantity']}"
                ], 422);
            }
        }

        try {
            DB::beginTransaction();

            $organizationId = $request->organization_id;
            
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

            // Get bank details if bank_account_id is provided
            $bankDetails = null;
            if ($request->bank_account_id) {
                $bankAccount = \App\Models\BankAccount::find($request->bank_account_id);
                if ($bankAccount) {
                    $bankDetails = json_encode([
                        'account_name' => $bankAccount->account_name,
                        'bank_account_no' => $bankAccount->bank_account_no,
                        'ifsc_code' => $bankAccount->ifsc_code,
                        'bank_name' => $bankAccount->bank_name,
                        'branch_name' => $bankAccount->branch_name,
                        'account_holder_name' => $bankAccount->account_holder_name,
                        'upi_id' => $bankAccount->upi_id,
                    ]);
                }
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
                'bank_details' => $bankDetails ?? $request->bank_details,
                'show_bank_details' => $request->show_bank_details ?? true,
                'auto_round_off' => $request->auto_round_off ?? false,
            ]);

            // Create invoice items and reduce stock
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

                // Reduce stock quantity
                $item = \App\Models\Item::find($itemData['item_id']);
                if ($item) {
                    $item->stock_qty = max(0, $item->stock_qty - $quantity);
                    $item->save();
                }
            }

            // Create bank transaction if payment is received
            if ($amountReceived > 0) {
                $accountId = $request->bank_account_id;
                
                // If no bank account selected (Cash payment), find or create default Cash account
                if (!$accountId) {
                    $cashAccount = \App\Models\BankAccount::firstOrCreate(
                        [
                            'organization_id' => $organizationId,
                            'account_name' => 'Cash',
                            'account_type' => 'cash',
                        ],
                        [
                            'user_id' => $request->user()->id,
                            'current_balance' => 0,
                            'opening_balance' => 0,
                            'opening_balance_date' => now(),
                            'is_default' => false,
                        ]
                    );
                    $accountId = $cashAccount->id;
                }

                \App\Models\BankTransaction::create([
                    'account_id' => $accountId,
                    'organization_id' => $organizationId,
                    'user_id' => $request->user()->id,
                    'transaction_type' => 'add',
                    'amount' => $amountReceived,
                    'transaction_date' => $request->invoice_date,
                    'description' => 'Payment received for Sales Invoice ' . $request->invoice_prefix . $request->invoice_number . ' - ' . ($request->payment_mode ?? 'Cash'),
                ]);

                // Update bank account balance
                $bankAccount = \App\Models\BankAccount::find($accountId);
                if ($bankAccount) {
                    $bankAccount->current_balance += $amountReceived;
                    $bankAccount->save();
                }
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
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            DB::beginTransaction();

            $oldAmountReceived = $invoice->amount_received;
            $organizationId = $invoice->organization_id;

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

                // Find and reverse old bank transaction if exists
                if ($oldAmountReceived > 0) {
                    $oldTransaction = \App\Models\BankTransaction::where('description', 'like', '%' . $invoice->invoice_prefix . $invoice->invoice_number . '%')
                        ->where('organization_id', $organizationId)
                        ->where('transaction_type', 'add')
                        ->first();

                    if ($oldTransaction) {
                        $oldAccount = \App\Models\BankAccount::find($oldTransaction->account_id);
                        if ($oldAccount) {
                            // Reverse old transaction (subtract the old amount)
                            $oldAccount->decrement('current_balance', $oldAmountReceived);
                        }
                        $oldTransaction->delete();
                    }
                }

                // Create new bank transaction if amount received
                if ($amountReceived > 0) {
                    $accountId = $request->bank_account_id;
                    
                    if (!$accountId) {
                        $cashAccount = \App\Models\BankAccount::firstOrCreate(
                            [
                                'organization_id' => $organizationId,
                                'account_name' => 'Cash',
                                'account_type' => 'cash',
                            ],
                            [
                                'user_id' => $request->user()->id,
                                'current_balance' => 0,
                                'opening_balance' => 0,
                                'opening_balance_date' => now(),
                                'is_default' => false,
                            ]
                        );
                        $accountId = $cashAccount->id;
                    }

                    \App\Models\BankTransaction::create([
                        'account_id' => $accountId,
                        'organization_id' => $organizationId,
                        'user_id' => $request->user()->id,
                        'transaction_type' => 'add',
                        'amount' => $amountReceived,
                        'transaction_date' => $invoice->invoice_date,
                        'description' => 'Payment received for Sales Invoice ' . $invoice->invoice_prefix . $invoice->invoice_number . ' - ' . ($request->payment_mode ?? 'Cash'),
                    ]);

                    $bankAccount = \App\Models\BankAccount::find($accountId);
                    if ($bankAccount) {
                        $bankAccount->increment('current_balance', $amountReceived);
                    }
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
                'message' => 'Sales invoice updated successfully with bank balance adjustment',
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
            DB::beginTransaction();

            $invoice = SalesInvoice::with('items')->findOrFail($id);

            // Restore stock quantities before deleting
            foreach ($invoice->items as $invoiceItem) {
                $item = \App\Models\Item::find($invoiceItem->item_id);
                if ($item) {
                    $item->stock_qty += $invoiceItem->quantity;
                    $item->save();
                }
            }

            // Delete related bank transaction if exists
            if ($invoice->amount_received > 0) {
                \App\Models\BankTransaction::where('description', 'like', '%' . $invoice->invoice_prefix . $invoice->invoice_number . '%')
                    ->where('organization_id', $invoice->organization_id)
                    ->delete();
            }

            $invoice->delete();

            DB::commit();

            return response()->json([
                'message' => 'Sales invoice deleted successfully'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to delete sales invoice',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextInvoiceNumber(Request $request)
    {
        $prefix = $request->prefix ?? 'INV';
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
