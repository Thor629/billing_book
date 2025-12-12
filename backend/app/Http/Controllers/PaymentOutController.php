<?php

namespace App\Http\Controllers;

use App\Models\PaymentOut;
use App\Models\PurchaseInvoice;
use App\Models\BankAccount;
use App\Models\BankTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaymentOutController extends Controller
{
    public function index(Request $request)
    {
        $payments = PaymentOut::with(['party', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('payment_date', 'desc')
            ->paginate(20);

        return response()->json($payments);
    }

    public function store(Request $request)
    {
        \Log::info('Payment Out Store Request:', [
            'body' => $request->all(),
            'headers' => [
                'X-Organization-Id' => $request->header('X-Organization-Id'),
            ],
        ]);

        try {
            $validated = $request->validate([
                'party_id' => 'required|exists:parties,id',
                'purchase_invoice_id' => 'nullable|exists:purchase_invoices,id',
                'payment_number' => 'required|unique:payment_outs',
                'payment_date' => 'required|date',
                'amount' => 'required|numeric|min:0.01',
                'payment_method' => 'required|in:cash,bank_transfer,cheque,card,upi,other',
                'bank_account_id' => 'nullable|exists:bank_accounts,id',
                'reference_number' => 'nullable|string',
                'notes' => 'nullable|string',
                'status' => 'required|in:pending,completed,failed,cancelled',
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            \Log::error('Payment Out Validation Failed:', [
                'errors' => $e->errors(),
            ]);
            throw $e;
        }

        return DB::transaction(function () use ($validated, $request) {
            $organizationId = (int)$request->header('X-Organization-Id');
            
            $payment = PaymentOut::create([
                ...$validated,
                'organization_id' => $organizationId,
            ]);

            if (isset($validated['purchase_invoice_id']) && $validated['purchase_invoice_id']) {
                $invoice = PurchaseInvoice::find($validated['purchase_invoice_id']);
                if ($invoice) {
                    $invoice->paid_amount += $validated['amount'];
                    $invoice->balance_amount = $invoice->total_amount - $invoice->paid_amount;
                    
                    if ($invoice->balance_amount <= 0) {
                        $invoice->status = 'paid';
                    } elseif ($invoice->paid_amount > 0) {
                        $invoice->status = 'partial';
                    }
                    
                    $invoice->save();
                }
            }

            // Update bank account balance and create transaction
            $this->updateBankAccountBalance($request, $organizationId, $payment, $validated);

            return response()->json($payment->load(['party', 'purchaseInvoice']), 201);
        });
    }

    /**
     * Update bank account balance and create transaction for payment out
     */
    private function updateBankAccountBalance(Request $request, $organizationId, $payment, $validated)
    {
        $amount = $validated['amount'];
        $paymentMethod = $validated['payment_method'];
        $description = "Payment Out: {$payment->payment_number}";
        
        if (isset($validated['notes'])) {
            $description .= " - {$validated['notes']}";
        }

        if ($paymentMethod === 'cash') {
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

            // Decrease cash balance (payment out)
            $cashAccount->decrement('current_balance', $amount);

            // Create transaction record
            BankTransaction::create([
                'user_id' => $request->user()->id,
                'organization_id' => $organizationId,
                'account_id' => $cashAccount->id,
                'transaction_type' => 'payment_out',
                'amount' => $amount,
                'transaction_date' => $validated['payment_date'],
                'description' => $description,
            ]);
        } else {
            // For non-cash payments, update the specified bank account
            if (isset($validated['bank_account_id']) && $validated['bank_account_id']) {
                $bankAccount = BankAccount::where('id', $validated['bank_account_id'])
                    ->where('organization_id', $organizationId)
                    ->first();

                if ($bankAccount) {
                    // Decrease bank balance (payment out)
                    $bankAccount->decrement('current_balance', $amount);

                    // Create transaction record
                    BankTransaction::create([
                        'user_id' => $request->user()->id,
                        'organization_id' => $organizationId,
                        'account_id' => $bankAccount->id,
                        'transaction_type' => 'payment_out',
                        'amount' => $amount,
                        'transaction_date' => $validated['payment_date'],
                        'description' => $description,
                    ]);
                }
            }
        }
    }

    public function show($id, Request $request)
    {
        $payment = PaymentOut::with(['party', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($payment);
    }

    public function update($id, Request $request)
    {
        \Log::info('Payment Out Update Request:', [
            'id' => $id,
            'body' => $request->all(),
        ]);

        $payment = PaymentOut::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        try {
            $validated = $request->validate([
                'party_id' => 'required|exists:parties,id',
                'purchase_invoice_id' => 'nullable|exists:purchase_invoices,id',
                'payment_number' => 'required|unique:payment_outs,payment_number,' . $id,
                'payment_date' => 'required|date',
                'amount' => 'required|numeric|min:0.01',
                'payment_method' => 'required|in:cash,bank_transfer,cheque,card,upi,other',
                'bank_account_id' => 'nullable|exists:bank_accounts,id',
                'reference_number' => 'nullable|string',
                'notes' => 'nullable|string',
                'status' => 'required|in:pending,completed,failed,cancelled',
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            \Log::error('Payment Out Update Validation Failed:', [
                'errors' => $e->errors(),
            ]);
            throw $e;
        }

        return DB::transaction(function () use ($payment, $validated, $request) {
            $oldAmount = $payment->amount;
            $newAmount = $validated['amount'];
            $oldPaymentMethod = $payment->payment_method;
            $newPaymentMethod = $validated['payment_method'];
            $organizationId = $payment->organization_id;
            
            // Find and reverse old bank transaction
            $oldTransaction = BankTransaction::where('description', 'like', "%Payment Out: {$payment->payment_number}%")
                ->where('organization_id', $organizationId)
                ->first();

            if ($oldTransaction) {
                $oldAccount = BankAccount::find($oldTransaction->account_id);
                if ($oldAccount) {
                    // Reverse old transaction (add back the old amount since it was deducted)
                    $oldAccount->increment('current_balance', $oldAmount);
                }
                $oldTransaction->delete();
            }
            
            // Update payment
            $payment->update($validated);

            // If amount changed and linked to invoice, update invoice
            if ($oldAmount != $newAmount && isset($validated['purchase_invoice_id']) && $validated['purchase_invoice_id']) {
                $invoice = PurchaseInvoice::find($validated['purchase_invoice_id']);
                if ($invoice) {
                    $invoice->paid_amount = $invoice->paid_amount - $oldAmount + $newAmount;
                    $invoice->balance_amount = $invoice->total_amount - $invoice->paid_amount;
                    
                    if ($invoice->balance_amount <= 0) {
                        $invoice->status = 'paid';
                    } elseif ($invoice->paid_amount > 0) {
                        $invoice->status = 'partial';
                    } else {
                        $invoice->status = 'unpaid';
                    }
                    
                    $invoice->save();
                }
            }

            // Create new bank transaction with updated values
            $description = "Payment Out: {$payment->payment_number}";
            if (isset($validated['notes'])) {
                $description .= " - {$validated['notes']}";
            }

            if ($newPaymentMethod === 'cash') {
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

                $cashAccount->decrement('current_balance', $newAmount);

                BankTransaction::create([
                    'user_id' => $request->user()->id,
                    'organization_id' => $organizationId,
                    'account_id' => $cashAccount->id,
                    'transaction_type' => 'payment_out',
                    'amount' => $newAmount,
                    'transaction_date' => $validated['payment_date'],
                    'description' => $description,
                ]);
            } else {
                if (isset($validated['bank_account_id']) && $validated['bank_account_id']) {
                    $bankAccount = BankAccount::where('id', $validated['bank_account_id'])
                        ->where('organization_id', $organizationId)
                        ->first();

                    if ($bankAccount) {
                        $bankAccount->decrement('current_balance', $newAmount);

                        BankTransaction::create([
                            'user_id' => $request->user()->id,
                            'organization_id' => $organizationId,
                            'account_id' => $bankAccount->id,
                            'transaction_type' => 'payment_out',
                            'amount' => $newAmount,
                            'transaction_date' => $validated['payment_date'],
                            'description' => $description,
                        ]);
                    }
                }
            }

            return response()->json([
                'message' => 'Payment updated successfully with bank balance adjustment',
                'payment' => $payment->load(['party', 'purchaseInvoice'])
            ], 200);
        });
    }

    public function destroy($id, Request $request)
    {
        $payment = PaymentOut::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $payment->delete();

        return response()->json(['message' => 'Payment deleted successfully']);
    }

    public function getNextPaymentNumber(Request $request)
    {
        $organizationId = $request->header('X-Organization-Id');
        
        \Log::info('Getting next payment number for org: ' . $organizationId);
        
        // Get all payment numbers for this organization
        $payments = PaymentOut::where('organization_id', $organizationId)
            ->whereNotNull('payment_number')
            ->pluck('payment_number')
            ->toArray();

        \Log::info('Found payments: ' . json_encode($payments));

        // Extract numeric parts and find the maximum
        $maxNumber = 0;
        foreach ($payments as $paymentNumber) {
            // Extract number from format like "PO-000001"
            if (preg_match('/PO-(\d+)/', $paymentNumber, $matches)) {
                $number = (int)$matches[1];
                if ($number > $maxNumber) {
                    $maxNumber = $number;
                }
            }
        }

        \Log::info('Max number found: ' . $maxNumber);

        // Generate next number
        $nextNumber = 'PO-' . str_pad($maxNumber + 1, 6, '0', STR_PAD_LEFT);

        \Log::info('Next payment number: ' . $nextNumber);

        return response()->json(['next_number' => $nextNumber]);
    }
}
