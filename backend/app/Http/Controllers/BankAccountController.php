<?php

namespace App\Http\Controllers;

use App\Models\BankAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class BankAccountController extends Controller
{
    public function index(Request $request)
    {
        $query = BankAccount::where('user_id', Auth::id());

        if ($request->has('organization_id')) {
            $query->where('organization_id', $request->organization_id);
        }

        $accounts = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'accounts' => $accounts
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'account_name' => 'required|string|max:255',
            'opening_balance' => 'required|numeric|min:0',
            'as_of_date' => 'required|date',
            'bank_account_no' => 'nullable|string|max:255',
            'ifsc_code' => 'nullable|string|max:255',
            'account_holder_name' => 'nullable|string|max:255',
            'upi_id' => 'nullable|string|max:255',
            'bank_name' => 'nullable|string|max:255',
            'branch_name' => 'nullable|string|max:255',
            'account_type' => 'required|in:bank,cash',
            'organization_id' => 'nullable|exists:organizations,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $account = BankAccount::create([
            'user_id' => Auth::id(),
            'organization_id' => $request->organization_id,
            'account_name' => $request->account_name,
            'opening_balance' => $request->opening_balance,
            'as_of_date' => $request->as_of_date,
            'bank_account_no' => $request->bank_account_no,
            'ifsc_code' => $request->ifsc_code,
            'account_holder_name' => $request->account_holder_name,
            'upi_id' => $request->upi_id,
            'bank_name' => $request->bank_name,
            'branch_name' => $request->branch_name,
            'current_balance' => $request->opening_balance,
            'account_type' => $request->account_type,
        ]);

        return response()->json($account, 201);
    }

    public function show($id)
    {
        $account = BankAccount::where('user_id', Auth::id())
            ->findOrFail($id);

        return response()->json($account);
    }

    public function update(Request $request, $id)
    {
        $account = BankAccount::where('user_id', Auth::id())
            ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'account_name' => 'sometimes|required|string|max:255',
            'opening_balance' => 'sometimes|required|numeric|min:0',
            'as_of_date' => 'sometimes|required|date',
            'bank_account_no' => 'nullable|string|max:255',
            'ifsc_code' => 'nullable|string|max:255',
            'account_holder_name' => 'nullable|string|max:255',
            'upi_id' => 'nullable|string|max:255',
            'bank_name' => 'nullable|string|max:255',
            'branch_name' => 'nullable|string|max:255',
            'account_type' => 'sometimes|required|in:bank,cash',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $account->update($request->all());

        return response()->json($account);
    }

    public function destroy($id)
    {
        $account = BankAccount::where('user_id', Auth::id())
            ->findOrFail($id);

        $account->delete();

        return response()->json(['message' => 'Account deleted successfully']);
    }
}
