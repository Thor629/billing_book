<?php

namespace App\Http\Controllers;

use App\Models\Expense;
use App\Models\BankAccount;
use App\Models\BankTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExpenseController extends Controller
{
    public function index(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json(['message' => 'Organization ID is required'], 400);
        }

        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $organizationId)
            ->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $query = Expense::with(['party', 'items', 'bankAccount'])
            ->where('organization_id', $organizationId);

        // Date filter
        if ($request->has('date_filter')) {
            $days = match($request->date_filter) {
                'Last 7 Days' => 7,
                'Last 30 Days' => 30,
                'Last 90 Days' => 90,
                'Last 365 Days' => 365,
                default => 365
            };
            $query->where('expense_date', '>=', now()->subDays($days));
        }

        // Category filter
        if ($request->has('category') && $request->category !== 'All Expenses Categories') {
            $query->where('category', $request->category);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('expense_number', 'like', "%{$search}%")
                  ->orWhere('category', 'like', "%{$search}%")
                  ->orWhereHas('party', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $expenses = $query->orderBy('expense_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        $summary = [
            'total_expenses' => Expense::where('organization_id', $organizationId)->sum('total_amount'),
            'total_count' => Expense::where('organization_id', $organizationId)->count(),
        ];

        return response()->json([
            'expenses' => $expenses,
            'summary' => $summary,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'organization_id' => 'required|exists:organizations,id',
            'expense_number' => 'required|string|max:50',
            'expense_date' => 'required|date',
            'category' => 'required|string|max:100',
            'payment_mode' => 'required|string|max:50',
            'total_amount' => 'required|numeric|min:0',
            'with_gst' => 'boolean',
            'party_id' => 'nullable|exists:parties,id',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'notes' => 'nullable|string',
            'original_invoice_number' => 'nullable|string|max:100',
            'items' => 'required|array|min:1',
            'items.*.item_name' => 'required|string',
            'items.*.description' => 'nullable|string',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.rate' => 'required|numeric|min:0',
            'items.*.amount' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $organizationId = $request->organization_id;
            
            $hasAccess = $request->user()
                ->organizations()
                ->where('organizations.id', $organizationId)
                ->exists();

            if (!$hasAccess) {
                return response()->json(['message' => 'Access denied'], 403);
            }
            
            // Check duplicate expense number
            $exists = Expense::where('organization_id', $organizationId)
                ->where('expense_number', $request->expense_number)
                ->exists();
                
            if ($exists) {
                return response()->json(['message' => 'Expense number already exists'], 422);
            }

            DB::beginTransaction();

            // Create expense
            $expense = Expense::create([
                'organization_id' => $organizationId,
                'user_id' => $request->user()->id,
                'party_id' => $request->party_id,
                'expense_number' => $request->expense_number,
                'expense_date' => $request->expense_date,
                'category' => $request->category,
                'payment_mode' => $request->payment_mode,
                'bank_account_id' => $request->bank_account_id,
                'total_amount' => $request->total_amount,
                'with_gst' => $request->with_gst ?? false,
                'notes' => $request->notes,
                'original_invoice_number' => $request->original_invoice_number,
            ]);

            // Create expense items
            foreach ($request->items as $item) {
                $expense->items()->create([
                    'item_name' => $item['item_name'],
                    'description' => $item['description'] ?? null,
                    'quantity' => $item['quantity'],
                    'rate' => $item['rate'],
                    'amount' => $item['amount'],
                ]);
            }

            // Update bank account balance and create transaction (deduct expense)
            $this->updateBankAccountBalance($request, $organizationId, $expense);

            DB::commit();

            return response()->json([
                'message' => 'Expense created successfully',
                'expense' => $expense->load(['party', 'items', 'bankAccount']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create expense',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $expense = Expense::with(['party', 'items', 'bankAccount', 'user'])
            ->findOrFail($id);

        return response()->json($expense);
    }

    public function destroy($id)
    {
        try {
            $expense = Expense::findOrFail($id);
            $expense->delete();

            return response()->json(['message' => 'Expense deleted successfully']);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete expense',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextExpenseNumber(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json(['message' => 'Organization ID is required'], 400);
        }

        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $organizationId)
            ->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $lastExpense = Expense::where('organization_id', $organizationId)
            ->orderBy('expense_number', 'desc')
            ->first();

        $nextNumber = $lastExpense ? ((int)$lastExpense->expense_number + 1) : 1;

        return response()->json(['next_number' => $nextNumber]);
    }

    public function getCategories()
    {
        $categories = [
            'Advertising & Marketing',
            'Automobile Expense',
            'Bank Charges & Fees',
            'Consultant Expense',
            'Credit Card Charges',
            'Depreciation Expense',
            'IT & Internet Expenses',
            'Janitorial Expense',
            'Lodging',
            'Meals & Entertainment',
            'Office Supplies',
            'Other Expenses',
            'Postage',
            'Printing & Stationery',
            'Rent Expense',
            'Repairs & Maintenance',
            'Salary Expense',
            'Telephone Expense',
            'Travel Expense',
            'Utility Expense',
        ];

        return response()->json(['categories' => $categories]);
    }

    private function updateBankAccountBalance(Request $request, $organizationId, $expense)
    {
        $amount = $request->total_amount;
        $paymentMode = $request->payment_mode;
        $description = "Expense: {$expense->expense_number} - {$expense->category}";
        
        if ($request->notes) {
            $description .= " ({$request->notes})";
        }

        if ($paymentMode === 'Cash') {
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

            // Decrease cash balance (expense)
            $cashAccount->decrement('current_balance', $amount);

            // Create transaction record
            BankTransaction::create([
                'user_id' => $request->user()->id,
                'organization_id' => $organizationId,
                'account_id' => $cashAccount->id,
                'transaction_type' => 'expense',
                'amount' => $amount,
                'transaction_date' => $request->expense_date,
                'description' => $description,
            ]);
        } else {
            if ($request->has('bank_account_id') && $request->bank_account_id) {
                $bankAccount = BankAccount::where('id', $request->bank_account_id)
                    ->where('organization_id', $organizationId)
                    ->first();

                if ($bankAccount) {
                    // Decrease bank balance (expense)
                    $bankAccount->decrement('current_balance', $amount);

                    // Create transaction record
                    BankTransaction::create([
                        'user_id' => $request->user()->id,
                        'organization_id' => $organizationId,
                        'account_id' => $bankAccount->id,
                        'transaction_type' => 'expense',
                        'amount' => $amount,
                        'transaction_date' => $request->expense_date,
                        'description' => $description,
                    ]);
                }
            }
        }
    }
}
