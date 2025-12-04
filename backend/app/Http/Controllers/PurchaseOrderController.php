<?php

namespace App\Http\Controllers;

use App\Models\PurchaseOrder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseOrderController extends Controller
{
    public function index(Request $request)
    {
        $query = PurchaseOrder::with(['party', 'items.item'])
            ->where('organization_id', $request->header('X-Organization-Id'));

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('party_id')) {
            $query->where('party_id', $request->party_id);
        }

        $orders = $query->orderBy('order_date', 'desc')->paginate(20);

        return response()->json($orders);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'party_id' => 'required|exists:parties,id',
            'order_number' => 'required|unique:purchase_orders',
            'order_date' => 'required|date',
            'expected_delivery_date' => 'nullable|date',
            'status' => 'required|in:draft,sent,confirmed,received,cancelled',
            'notes' => 'nullable|string',
            'terms' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.rate' => 'required|numeric|min:0',
            'items.*.tax_rate' => 'nullable|numeric|min:0|max:100',
            'items.*.discount_rate' => 'nullable|numeric|min:0|max:100',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $subtotal = 0;
            $taxAmount = 0;
            $discountAmount = 0;

            foreach ($validated['items'] as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemDiscount = $itemSubtotal * (($item['discount_rate'] ?? 0) / 100);
                $itemTaxable = $itemSubtotal - $itemDiscount;
                $itemTax = $itemTaxable * (($item['tax_rate'] ?? 0) / 100);

                $subtotal += $itemSubtotal;
                $discountAmount += $itemDiscount;
                $taxAmount += $itemTax;
            }

            $totalAmount = $subtotal - $discountAmount + $taxAmount;

            $order = PurchaseOrder::create([
                'organization_id' => $request->header('X-Organization-Id'),
                'party_id' => $validated['party_id'],
                'order_number' => $validated['order_number'],
                'order_date' => $validated['order_date'],
                'expected_delivery_date' => $validated['expected_delivery_date'] ?? null,
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'discount_amount' => $discountAmount,
                'total_amount' => $totalAmount,
                'status' => $validated['status'],
                'notes' => $validated['notes'] ?? null,
                'terms' => $validated['terms'] ?? null,
            ]);

            foreach ($validated['items'] as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemDiscount = $itemSubtotal * (($item['discount_rate'] ?? 0) / 100);
                $itemTaxable = $itemSubtotal - $itemDiscount;
                $itemTax = $itemTaxable * (($item['tax_rate'] ?? 0) / 100);
                $itemAmount = $itemTaxable + $itemTax;

                $order->items()->create([
                    'item_id' => $item['item_id'],
                    'description' => $item['description'] ?? null,
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'] ?? 'pcs',
                    'rate' => $item['rate'],
                    'tax_rate' => $item['tax_rate'] ?? 0,
                    'discount_rate' => $item['discount_rate'] ?? 0,
                    'amount' => $itemAmount,
                ]);
            }

            return response()->json($order->load(['party', 'items.item']), 201);
        });
    }

    public function show($id, Request $request)
    {
        $order = PurchaseOrder::with(['party', 'items.item'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($order);
    }

    public function update(Request $request, $id)
    {
        $order = PurchaseOrder::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $validated = $request->validate([
            'party_id' => 'sometimes|exists:parties,id',
            'order_date' => 'sometimes|date',
            'expected_delivery_date' => 'nullable|date',
            'status' => 'sometimes|in:draft,sent,confirmed,received,cancelled',
            'notes' => 'nullable|string',
            'terms' => 'nullable|string',
        ]);

        $order->update($validated);

        return response()->json($order->load(['party', 'items.item']));
    }

    public function destroy($id, Request $request)
    {
        $order = PurchaseOrder::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $order->delete();

        return response()->json(['message' => 'Purchase order deleted successfully']);
    }

    public function getNextOrderNumber(Request $request)
    {
        $lastOrder = PurchaseOrder::where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('id', 'desc')
            ->first();

        $nextNumber = $lastOrder 
            ? 'PO-' . str_pad((int)substr($lastOrder->order_number, 3) + 1, 6, '0', STR_PAD_LEFT)
            : 'PO-000001';

        return response()->json(['next_number' => $nextNumber]);
    }
}
