<?php

namespace App\Http\Controllers;

use App\Models\BankAccount;
use App\Models\BankTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BankTransactionController extends Controller
{
    public function index(Request $request)
    {
        $query = BankTransaction::where('user_id', Auth::id());

        if ($request->has('organization_id')) {
            $query->where('organization_id', $request->organization_id);
        }

        if ($request->has('account_id')) {
            $query->where('account_id', $request->account_id);
        }

        if ($request->has('start_date')) {
            $query->where('transaction_date', '>=', $request->start_date);
        }

        if ($request->has('end_date')) {
            $query->where('transaction_date', '<=', $request->end_date);
        }

        $transactions = $query->with(['account', 'relatedAccount'])
            ->orderBy('transaction_date', 'desc')
            ->get();

        // Mask external account numbers for display
        $transactions->transform(function ($transaction) {
            if ($transaction->is_external_transfer && $transaction->external_account_number) {
                $accountNumber = $transaction->external_account_number;
                $length = strlen($accountNumber);
                if ($length > 4) {
                    $transaction->external_account_number_masked = str_repeat('*', $length - 4) . substr($accountNumber, -4);
                } else {
                    $transaction->external_account_number_masked = $accountNumber;
                }
            }
            return $transaction;
        });

        return response()->json($transactions);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'account_id' => 'required|exists:bank_accounts,id',
            'transaction_type' => 'required|in:add,reduce',
            'amount' => 'required|numeric|min:0.01',
            'transaction_date' => 'required|date',
            'description' => 'nullable|string',
            'organization_id' => 'nullable|exists:organizations,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Verify account belongs to user
        $account = BankAccount::where('id', $request->account_id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        // Check if reducing and sufficient balance
        if ($request->transaction_type === 'reduce' && $account->current_balance < $request->amount) {
            return response()->json(['error' => 'Insufficient balance'], 400);
        }

        DB::beginTransaction();
        try {
            $transaction = BankTransaction::create([
                'user_id' => Auth::id(),
                'organization_id' => $request->organization_id,
                'account_id' => $request->account_id,
                'transaction_type' => $request->transaction_type,
                'amount' => $request->amount,
                'transaction_date' => $request->transaction_date,
                'description' => $request->description,
            ]);

            // Update account balance
            if ($request->transaction_type === 'add') {
                $account->current_balance += $request->amount;
            } else {
                $account->current_balance -= $request->amount;
            }
            $account->save();

            DB::commit();

            return response()->json($transaction, 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'Transaction failed'], 500);
        }
    }

    public function transfer(Request $request)
    {
        $isExternal = $request->boolean('is_external_transfer', false);
        
        // Base validation rules
        $rules = [
            'from_account_id' => 'required|exists:bank_accounts,id',
            'amount' => 'required|numeric|min:0.01',
            'transaction_date' => 'required|date',
            'description' => 'nullable|string',
            'is_external_transfer' => 'boolean',
        ];
        
        // Add conditional validation based on transfer type
        if ($isExternal) {
            $rules['external_account_holder'] = 'required|string|max:255';
            $rules['external_account_number'] = 'required|string|max:50';
            $rules['external_bank_name'] = 'required|string|max:255';
            $rules['external_ifsc_code'] = 'required|string|size:11|regex:/^[A-Z]{4}0[A-Z0-9]{6}$/';
        } else {
            $rules['to_account_id'] = 'required|exists:bank_accounts,id|different:from_account_id';
        }

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Verify from account belongs to user
        $fromAccount = BankAccount::where('id', $request->from_account_id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        // Check sufficient balance
        if ($fromAccount->current_balance < $request->amount) {
            return response()->json([
                'error' => 'Insufficient balance',
                'available_balance' => $fromAccount->current_balance
            ], 400);
        }

        DB::beginTransaction();
        try {
            if ($isExternal) {
                // Handle external transfer
                $transferOut = BankTransaction::create([
                    'user_id' => Auth::id(),
                    'organization_id' => $fromAccount->organization_id,
                    'account_id' => $request->from_account_id,
                    'transaction_type' => 'transfer_out',
                    'amount' => $request->amount,
                    'transaction_date' => $request->transaction_date,
                    'description' => $request->description,
                    'is_external_transfer' => true,
                    'external_account_holder' => $request->external_account_holder,
                    'external_account_number' => $request->external_account_number,
                    'external_bank_name' => $request->external_bank_name,
                    'external_ifsc_code' => $request->external_ifsc_code,
                ]);

                // Update only from account balance
                $fromAccount->current_balance -= $request->amount;
                $fromAccount->save();

                DB::commit();

                return response()->json([
                    'transfer_out' => $transferOut,
                ], 201);
            } else {
                // Handle internal transfer
                $toAccount = BankAccount::where('id', $request->to_account_id)
                    ->where('user_id', Auth::id())
                    ->firstOrFail();

                // Create transfer out transaction
                $transferOut = BankTransaction::create([
                    'user_id' => Auth::id(),
                    'organization_id' => $fromAccount->organization_id,
                    'account_id' => $request->from_account_id,
                    'transaction_type' => 'transfer_out',
                    'amount' => $request->amount,
                    'transaction_date' => $request->transaction_date,
                    'description' => $request->description,
                    'related_account_id' => $request->to_account_id,
                    'is_external_transfer' => false,
                ]);

                // Create transfer in transaction
                $transferIn = BankTransaction::create([
                    'user_id' => Auth::id(),
                    'organization_id' => $toAccount->organization_id,
                    'account_id' => $request->to_account_id,
                    'transaction_type' => 'transfer_in',
                    'amount' => $request->amount,
                    'transaction_date' => $request->transaction_date,
                    'description' => $request->description,
                    'related_account_id' => $request->from_account_id,
                    'related_transaction_id' => $transferOut->id,
                    'is_external_transfer' => false,
                ]);

                // Link transactions
                $transferOut->related_transaction_id = $transferIn->id;
                $transferOut->save();

                // Update balances
                $fromAccount->current_balance -= $request->amount;
                $fromAccount->save();

                $toAccount->current_balance += $request->amount;
                $toAccount->save();

                DB::commit();

                return response()->json([
                    'transfer_out' => $transferOut,
                    'transfer_in' => $transferIn,
                ], 201);
            }
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'Transfer failed: ' . $e->getMessage()], 500);
        }
    }
}
