<?php

namespace App\Http\Controllers;

use App\Models\Quotation;
use App\Models\QuotationItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class QuotationController extends Controller
{
    public function index(Request $request)
    {
        $query = Quotation::with(['party', 'organization', 'user'])
            ->where('organization_id', $request->user()->currentOrganization->id ?? null);

        // Filter by date range
        if ($request->has('date_filter')) {
            $days = match($request->date_filter) {
                'Last 7 Days' => 7,
                'Last 30 Days' => 30,
                'Last 365 Days' => 365,
                default => 365
            };
            $query->where('quotation_date', '>=', now()->subDays($days));
        }

        // Filter by status
        if ($request->has('status_filter') && $request->status_filter !== 'all') {
            $query->where('status', $request->status_filter);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('quotation_number', 'like', "%{$search}%")
                  ->orWhereHas('party', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $quotations = $query->orderBy('quotation_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        // Calculate summary
        $summary = [
            'total_quotations' => Quotation::where('organization_id', $request->user()->currentOrganization->id ?? null)
                ->count(),
            'open' => Quotation::where('organization_id', $request->user()->currentOrganization->id ?? null)
                ->where('status', 'open')
                ->count(),
            'accepted' => Quotation::where('organization_id', $request->user()->currentOrganization->id ?? null)
                ->where('status', 'accepted')
                ->count(),
            'total_amount' => Quotation::where('organization_id', $request->user()->currentOrganization->id ?? null)
                ->sum('total_amount'),
        ];

        return response()->json([
            'quotations' => $quotations,
            'summary' => $summary,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'party_id' => 'required|exists:parties,id',
            'quotation_number' => 'required|string|max:50',
            'quotation_date' => 'required|date',
            'valid_for' => 'required|integer|min:1',
            'validity_date' => 'required|date|after_or_equal:quotation_date',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.quantity' => 'required|numeric|min:0.001',
            'items.*.price_per_unit' => 'required|numeric|min:0',
            'items.*.discount_percent' => 'nullable|numeric|min:0|max:100',
            'items.*.tax_percent' => 'nullable|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            DB::beginTransaction();

            $organizationId = $request->user()->currentOrganization->id ?? null;
            
            // Check for duplicate quotation number
            $exists = Quotation::where('organization_id', $organizationId)
                ->where('quotation_number', $request->quotation_number)
                ->exists();
                
            if ($exists) {
                return response()->json([
                    'message' => 'Quotation number already exists'
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

            // Create quotation
            $quotation = Quotation::create([
                'organization_id' => $organizationId,
                'party_id' => $request->party_id,
                'user_id' => $request->user()->id,
                'quotation_number' => $request->quotation_number,
                'quotation_date' => $request->quotation_date,
                'valid_for' => $request->valid_for,
                'validity_date' => $request->validity_date,
                'subtotal' => $subtotal,
                'discount_amount' => $totalDiscount,
                'tax_amount' => $totalTax,
                'additional_charges' => $additionalCharges,
                'round_off' => $roundOff,
                'total_amount' => $totalAmount,
                'status' => 'open',
                'notes' => $request->notes,
                'terms_conditions' => $request->terms_conditions,
                'bank_details' => $request->bank_details,
                'show_bank_details' => $request->show_bank_details ?? true,
                'auto_round_off' => $request->auto_round_off ?? false,
            ]);

            // Create quotation items
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

                QuotationItem::create([
                    'quotation_id' => $quotation->id,
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
            }

            DB::commit();

            return response()->json([
                'message' => 'Quotation created successfully',
                'quotation' => $quotation->load(['party', 'items', 'organization']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create quotation',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $quotation = Quotation::with(['party', 'items.item', 'organization', 'user'])
            ->findOrFail($id);

        return response()->json($quotation);
    }

    public function update(Request $request, $id)
    {
        $quotation = Quotation::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'party_id' => 'sometimes|exists:parties,id',
            'quotation_date' => 'sometimes|date',
            'valid_for' => 'sometimes|integer|min:1',
            'validity_date' => 'sometimes|date',
            'status' => 'sometimes|in:open,accepted,rejected,expired,converted',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $quotation->update($request->only([
                'party_id',
                'quotation_date',
                'valid_for',
                'validity_date',
                'status',
                'notes',
                'terms_conditions',
                'bank_details',
                'show_bank_details',
            ]));

            return response()->json([
                'message' => 'Quotation updated successfully',
                'quotation' => $quotation->load(['party', 'items', 'organization']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to update quotation',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $quotation = Quotation::findOrFail($id);
            $quotation->delete();

            return response()->json([
                'message' => 'Quotation deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete quotation',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getNextQuotationNumber(Request $request)
    {
        $organizationId = $request->user()->currentOrganization->id ?? null;

        $lastQuotation = Quotation::where('organization_id', $organizationId)
            ->orderBy('quotation_number', 'desc')
            ->first();

        $nextNumber = $lastQuotation ? ((int)$lastQuotation->quotation_number + 1) : 1;

        return response()->json([
            'next_number' => $nextNumber,
        ]);
    }
}
