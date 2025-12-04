<?php

namespace App\Http\Controllers;

use App\Models\PurchaseInvoice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseInvoiceController extends Controller
{
    public function index(Request $request)
    {
        $query = PurchaseInvoice::with(['party', 'items.item'])
            ->where('organization_id', $request->header('X-Organization-Id'));

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('party_id')) {
            $query->where('party_id', $request->party_id);
        }

        $invoices = $query->orderBy('invoice_date', 'desc')->paginate(20);

        return response()->json($invoices);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'party_id' => 'required|exists:parties,id',
            'invoice_number' => 'required|unique:purchase_invoices',
            'invoice_date' => 'required|date',
            'due_date' => 'nullable|date',
            'status' => 'required|in:draft,pending,paid,partial,overdue,cancelled',
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

            $invoice = PurchaseInvoice::create([
                'organization_id' => $request->header('X-Organization-Id'),
                'party_id' => $validated['party_id'],
                'invoice_number' => $validated['invoice_number'],
                'invoice_date' => $validated['invoice_date'],
                'due_date' => $validated['due_date'] ?? null,
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'discount_amount' => $discountAmount,
                'total_amount' => $totalAmount,
                'paid_amount' => 0,
                'balance_amount' => $totalAmount,
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

                $invoice->items()->create([
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

            return response()->json($invoice->load(['party', 'items.item']), 201);
        });
    }

    public function show($id, Request $request)
    {
        $invoice = PurchaseInvoice::with(['party', 'items.item', 'payments'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($invoice);
    }

    public function update(Request $request, $id)
    {
        $invoice = PurchaseInvoice::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $validated = $request->validate([
            'party_id' => 'sometimes|exists:parties,id',
            'invoice_date' => 'sometimes|date',
            'due_date' => 'nullable|date',
            'status' => 'sometimes|in:draft,pending,paid,partial,overdue,cancelled',
            'notes' => 'nullable|string',
            'terms' => 'nullable|string',
        ]);

        $invoice->update($validated);

        return response()->json($invoice->load(['party', 'items.item']));
    }

    public function destroy($id, Request $request)
    {
        $invoice = PurchaseInvoice::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $invoice->delete();

        return response()->json(['message' => 'Purchase invoice deleted successfully']);
    }

    public function getNextInvoiceNumber(Request $request)
    {
        $lastInvoice = PurchaseInvoice::where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('id', 'desc')
            ->first();

        $nextNumber = $lastInvoice 
            ? 'PI-' . str_pad((int)substr($lastInvoice->invoice_number, 3) + 1, 6, '0', STR_PAD_LEFT)
            : 'PI-000001';

        return response()->json(['next_number' => $nextNumber]);
    }
}
