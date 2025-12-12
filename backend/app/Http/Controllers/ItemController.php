<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    public function index(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json(['message' => 'Organization ID is required'], 400);
        }

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $organizationId)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $items = Item::with(['partyPrices.party', 'customFields'])
            ->where('organization_id', $organizationId)
            ->orderBy('item_name')->get();

        return response()->json(['data' => $items], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'organization_id' => 'required|exists:organizations,id',
            'item_name' => 'required|string|max:255',
            'item_code' => 'required|string|max:255|unique:items',
            'barcode' => 'nullable|string|max:255',
            'selling_price' => 'nullable|numeric|min:0',
            'selling_price_with_tax' => 'nullable|boolean',
            'purchase_price' => 'nullable|numeric|min:0',
            'purchase_price_with_tax' => 'nullable|boolean',
            'mrp' => 'nullable|numeric|min:0',
            'stock_qty' => 'nullable|integer|min:0',
            'opening_stock' => 'nullable|numeric|min:0',
            'opening_stock_date' => 'nullable|date',
            'unit' => 'nullable|string|max:255',
            'alternative_unit' => 'nullable|string|max:255',
            'alternative_unit_conversion' => 'nullable|numeric|min:0',
            'low_stock_alert' => 'nullable|integer|min:0',
            'enable_low_stock_warning' => 'nullable|boolean',
            'category' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'hsn_code' => 'nullable|string|max:255',
            'gst_rate' => 'nullable|numeric|min:0|max:100',
            'image_url' => 'nullable|string|max:500',
            'party_prices' => 'nullable|array',
            'party_prices.*.party_id' => 'required|exists:parties,id',
            'party_prices.*.selling_price' => 'required|numeric|min:0',
            'party_prices.*.purchase_price' => 'nullable|numeric|min:0',
            'party_prices.*.price_with_tax' => 'nullable|boolean',
            'custom_fields' => 'nullable|array',
            'custom_fields.*.field_name' => 'required|string|max:255',
            'custom_fields.*.field_value' => 'nullable|string',
            'custom_fields.*.field_type' => 'nullable|string|in:text,number,date,dropdown',
        ]);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $validated['organization_id'])->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        // Extract party prices and custom fields
        $partyPrices = $validated['party_prices'] ?? [];
        $customFields = $validated['custom_fields'] ?? [];
        unset($validated['party_prices'], $validated['custom_fields']);

        // If stock_qty is not provided but opening_stock is, use opening_stock as initial stock_qty
        if (!isset($validated['stock_qty']) && isset($validated['opening_stock'])) {
            $validated['stock_qty'] = (int) $validated['opening_stock'];
        }

        $item = Item::create($validated);

        // Create party prices
        foreach ($partyPrices as $partyPrice) {
            $item->partyPrices()->create($partyPrice);
        }

        // Create custom fields
        foreach ($customFields as $customField) {
            $item->customFields()->create($customField);
        }

        $item->load(['partyPrices.party', 'customFields']);

        return response()->json([
            'item' => $item,
            'message' => 'Item created successfully'
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $item = Item::with(['partyPrices.party', 'customFields'])->findOrFail($id);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $item->organization_id)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        return response()->json(['item' => $item], 200);
    }

    public function update(Request $request, $id)
    {
        $item = Item::with(['partyPrices', 'customFields'])->findOrFail($id);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $item->organization_id)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $validated = $request->validate([
            'item_name' => 'sometimes|required|string|max:255',
            'item_code' => 'sometimes|required|string|max:255|unique:items,item_code,' . $id,
            'barcode' => 'nullable|string|max:255',
            'selling_price' => 'nullable|numeric|min:0',
            'selling_price_with_tax' => 'nullable|boolean',
            'purchase_price' => 'nullable|numeric|min:0',
            'purchase_price_with_tax' => 'nullable|boolean',
            'mrp' => 'nullable|numeric|min:0',
            'stock_qty' => 'nullable|integer|min:0',
            'opening_stock' => 'nullable|numeric|min:0',
            'opening_stock_date' => 'nullable|date',
            'unit' => 'nullable|string|max:255',
            'alternative_unit' => 'nullable|string|max:255',
            'alternative_unit_conversion' => 'nullable|numeric|min:0',
            'low_stock_alert' => 'nullable|integer|min:0',
            'enable_low_stock_warning' => 'nullable|boolean',
            'category' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'hsn_code' => 'nullable|string|max:255',
            'gst_rate' => 'nullable|numeric|min:0|max:100',
            'image_url' => 'nullable|string|max:500',
            'is_active' => 'sometimes|boolean',
            'party_prices' => 'nullable|array',
            'party_prices.*.party_id' => 'required|exists:parties,id',
            'party_prices.*.selling_price' => 'required|numeric|min:0',
            'party_prices.*.purchase_price' => 'nullable|numeric|min:0',
            'party_prices.*.price_with_tax' => 'nullable|boolean',
            'custom_fields' => 'nullable|array',
            'custom_fields.*.field_name' => 'required|string|max:255',
            'custom_fields.*.field_value' => 'nullable|string',
            'custom_fields.*.field_type' => 'nullable|string|in:text,number,date,dropdown',
        ]);

        // Extract party prices and custom fields
        $partyPrices = $validated['party_prices'] ?? null;
        $customFields = $validated['custom_fields'] ?? null;
        unset($validated['party_prices'], $validated['custom_fields']);

        // If opening_stock is being updated and stock_qty is not provided, update stock_qty
        if (isset($validated['opening_stock']) && !isset($validated['stock_qty'])) {
            $validated['stock_qty'] = (int) $validated['opening_stock'];
        }

        $item->update($validated);

        // Update party prices if provided
        if ($partyPrices !== null) {
            $item->partyPrices()->delete();
            foreach ($partyPrices as $partyPrice) {
                $item->partyPrices()->create($partyPrice);
            }
        }

        // Update custom fields if provided
        if ($customFields !== null) {
            $item->customFields()->delete();
            foreach ($customFields as $customField) {
                $item->customFields()->create($customField);
            }
        }

        $item->load(['partyPrices.party', 'customFields']);

        return response()->json([
            'item' => $item,
            'message' => 'Item updated successfully'
        ], 200);
    }

    public function destroy(Request $request, $id)
    {
        $item = Item::findOrFail($id);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $item->organization_id)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $item->delete();

        return response()->json(['message' => 'Item deleted successfully'], 200);
    }
}
