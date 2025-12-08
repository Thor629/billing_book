<?php

namespace App\Http\Controllers;

use App\Models\DeliveryChallan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DeliveryChallanController extends Controller
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

        $query = DeliveryChallan::with(['party', 'items'])
            ->where('organization_id', $organizationId);

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('challan_number', 'like', "%{$search}%")
                  ->orWhereHas('party', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $challans = $query->orderBy('challan_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        return response()->json($challans);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'organization_id' => 'required|exists:organizations,id',
            'party_id' => 'required|exists:parties,id',
            'challan_number' => 'required|string|max:50',
            'challan_date' => 'required|date',
            'subtotal' => 'required|numeric|min:0',
            'tax_amount' => 'required|numeric|min:0',
            'total_amount' => 'required|numeric|min:0',
            'notes' => 'nullable|string',
            'terms_conditions' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.item_name' => 'required|string',
            'items.*.hsn_sac' => 'nullable|string',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.price' => 'required|numeric|min:0',
            'items.*.discount_percent' => 'required|numeric|min:0|max:100',
            'items.*.tax_percent' => 'required|numeric|min:0|max:100',
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
            
            // Check duplicate challan number
            $exists = DeliveryChallan::where('organization_id', $organizationId)
                ->where('challan_number', $request->challan_number)
                ->exists();
                
            if ($exists) {
                return response()->json(['message' => 'Challan number already exists'], 422);
            }

            DB::beginTransaction();

            // Create delivery challan
            $challan = DeliveryChallan::create([
                'organization_id' => $organizationId,
                'user_id' => $request->user()->id,
                'party_id' => $request->party_id,
                'challan_number' => $request->challan_number,
                'challan_date' => $request->challan_date,
                'subtotal' => $request->subtotal,
                'tax_amount' => $request->tax_amount,
                'total_amount' => $request->total_amount,
                'notes' => $request->notes,
                'terms_conditions' => $request->terms_conditions,
            ]);

            // Create challan items
            foreach ($request->items as $item) {
                $challan->items()->create([
                    'item_id' => $item['item_id'],
                    'item_name' => $item['item_name'],
                    'hsn_sac' => $item['hsn_sac'] ?? null,
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                    'discount_percent' => $item['discount_percent'],
                    'tax_percent' => $item['tax_percent'],
                    'amount' => $item['amount'],
                ]);
            }

            DB::commit();

            return response()->json([
                'message' => 'Delivery challan created successfully',
                'challan' => $challan->load(['party', 'items']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create delivery challan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $challan = DeliveryChallan::with(['party', 'items', 'user'])
            ->findOrFail($id);

        return response()->json($challan);
    }

    public function destroy($id)
    {
        try {
            $challan = DeliveryChallan::findOrFail($id);
            $challan->delete();

            return response()->json(['message' => 'Delivery challan deleted successfully']);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete delivery challan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextChallanNumber(Request $request)
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

        $lastChallan = DeliveryChallan::where('organization_id', $organizationId)
            ->orderBy('challan_number', 'desc')
            ->first();

        $nextNumber = $lastChallan ? ((int)$lastChallan->challan_number + 1) : 1;

        return response()->json(['next_number' => $nextNumber]);
    }
}
