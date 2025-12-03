<?php

namespace App\Http\Controllers;

use App\Models\PaymentIn;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PaymentInController extends Controller
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

        $query = PaymentIn::with(['party', 'organization', 'user'])
            ->where('organization_id', $organizationId);

        // Filter by date range
        if ($request->has('date_filter')) {
            $days = match($request->date_filter) {
                'Last 7 Days' => 7,
                'Last 30 Days' => 30,
                'Last 365 Days' => 365,
                default => 365
            };
            $query->where('payment_date', '>=', now()->subDays($days));
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('payment_number', 'like', "%{$search}%")
                  ->orWhereHas('party', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $payments = $query->orderBy('payment_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        // Calculate summary
        $summary = [
            'total_received' => PaymentIn::where('organization_id', $organizationId)
                ->sum('amount'),
            'total_count' => PaymentIn::where('organization_id', $organizationId)
                ->count(),
        ];

        return response()->json([
            'payments' => $payments,
            'summary' => $summary,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'organization_id' => 'required|exists:organizations,id',
            'party_id' => 'required|exists:parties,id',
            'payment_number' => 'required|string|max:50',
            'payment_date' => 'required|date',
            'amount' => 'required|numeric|min:0.01',
            'payment_mode' => 'required|string|max:50',
            'notes' => 'nullable|string',
            'reference_number' => 'nullable|string|max:100',
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
            
            // Check for duplicate payment number
            $exists = PaymentIn::where('organization_id', $organizationId)
                ->where('payment_number', $request->payment_number)
                ->exists();
                
            if ($exists) {
                return response()->json([
                    'message' => 'Payment number already exists'
                ], 422);
            }

            // Create payment
            $payment = PaymentIn::create([
                'organization_id' => $organizationId,
                'party_id' => $request->party_id,
                'user_id' => $request->user()->id,
                'payment_number' => $request->payment_number,
                'payment_date' => $request->payment_date,
                'amount' => $request->amount,
                'payment_mode' => $request->payment_mode,
                'notes' => $request->notes,
                'reference_number' => $request->reference_number,
            ]);

            return response()->json([
                'message' => 'Payment recorded successfully',
                'payment' => $payment->load(['party', 'organization']),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to record payment',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $payment = PaymentIn::with(['party', 'organization', 'user'])
            ->findOrFail($id);

        return response()->json($payment);
    }

    public function update(Request $request, $id)
    {
        $payment = PaymentIn::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'party_id' => 'sometimes|exists:parties,id',
            'payment_date' => 'sometimes|date',
            'amount' => 'sometimes|numeric|min:0.01',
            'payment_mode' => 'sometimes|string|max:50',
            'notes' => 'nullable|string',
            'reference_number' => 'nullable|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $payment->update($request->only([
                'party_id',
                'payment_date',
                'amount',
                'payment_mode',
                'notes',
                'reference_number',
            ]));

            return response()->json([
                'message' => 'Payment updated successfully',
                'payment' => $payment->load(['party', 'organization']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to update payment',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $payment = PaymentIn::findOrFail($id);
            $payment->delete();

            return response()->json([
                'message' => 'Payment deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete payment',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextPaymentNumber(Request $request)
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

        $lastPayment = PaymentIn::where('organization_id', $organizationId)
            ->orderBy('payment_number', 'desc')
            ->first();

        $nextNumber = $lastPayment ? ((int)$lastPayment->payment_number + 1) : 1;

        return response()->json([
            'next_number' => $nextNumber,
        ]);
    }
}
