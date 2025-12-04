<?php

namespace App\Http\Controllers;

use App\Models\PurchaseReturn;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseReturnController extends Controller
{
    public function index(Request $request)
    {
        $returns = PurchaseReturn::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('return_date', 'desc')
            ->paginate(20);

        return response()->json($returns);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'party_id' => 'required|exists:parties,id',
            'purchase_invoice_id' => 'nullable|exists:purchase_invoices,id',
            'return_number' => 'required|unique:purchase_returns',
            'return_date' => 'required|date',
            'status' => 'required|in:draft,pending,approved,rejected',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'required|exists:items,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.rate' => 'required|numeric|min:0',
            'items.*.tax_rate' => 'nullable|numeric|min:0|max:100',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $subtotal = 0;
            $taxAmount = 0;

            foreach ($validated['items'] as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = $itemSubtotal * (($item['tax_rate'] ?? 0) / 100);
                $subtotal += $itemSubtotal;
                $taxAmount += $itemTax;
            }

            $return = PurchaseReturn::create([
                'organization_id' => $request->header('X-Organization-Id'),
                'party_id' => $validated['party_id'],
                'purchase_invoice_id' => $validated['purchase_invoice_id'] ?? null,
                'return_number' => $validated['return_number'],
                'return_date' => $validated['return_date'],
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'total_amount' => $subtotal + $taxAmount,
                'status' => $validated['status'],
                'reason' => $validated['reason'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            foreach ($validated['items'] as $item) {
                $itemSubtotal = $item['quantity'] * $item['rate'];
                $itemTax = $itemSubtotal * (($item['tax_rate'] ?? 0) / 100);

                $return->items()->create([
                    'item_id' => $item['item_id'],
                    'description' => $item['description'] ?? null,
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'] ?? 'pcs',
                    'rate' => $item['rate'],
                    'tax_rate' => $item['tax_rate'] ?? 0,
                    'amount' => $itemSubtotal + $itemTax,
                ]);
            }

            return response()->json($return->load(['party', 'items.item']), 201);
        });
    }

    public function show($id, Request $request)
    {
        $return = PurchaseReturn::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($return);
    }

    public function destroy($id, Request $request)
    {
        $return = PurchaseReturn::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $return->delete();

        return response()->json(['message' => 'Purchase return deleted successfully']);
    }

    public function getNextReturnNumber(Request $request)
    {
        $lastReturn = PurchaseReturn::where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('id', 'desc')
            ->first();

        $nextNumber = $lastReturn 
            ? 'PR-' . str_pad((int)substr($lastReturn->return_number, 3) + 1, 6, '0', STR_PAD_LEFT)
            : 'PR-000001';

        return response()->json(['next_number' => $nextNumber]);
    }
}
