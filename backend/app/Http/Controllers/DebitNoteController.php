<?php

namespace App\Http\Controllers;

use App\Models\DebitNote;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DebitNoteController extends Controller
{
    public function index(Request $request)
    {
        $notes = DebitNote::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('debit_note_date', 'desc')
            ->paginate(20);

        return response()->json($notes);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'party_id' => 'required|exists:parties,id',
            'purchase_invoice_id' => 'nullable|exists:purchase_invoices,id',
            'debit_note_number' => 'required|unique:debit_notes',
            'debit_note_date' => 'required|date',
            'status' => 'required|in:draft,issued,cancelled',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.item_id' => 'nullable|exists:items,id',
            'items.*.description' => 'required|string',
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

            $debitNote = DebitNote::create([
                'organization_id' => $request->header('X-Organization-Id'),
                'party_id' => $validated['party_id'],
                'purchase_invoice_id' => $validated['purchase_invoice_id'] ?? null,
                'debit_note_number' => $validated['debit_note_number'],
                'debit_note_date' => $validated['debit_note_date'],
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

                $debitNote->items()->create([
                    'item_id' => $item['item_id'] ?? null,
                    'description' => $item['description'],
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'] ?? 'pcs',
                    'rate' => $item['rate'],
                    'tax_rate' => $item['tax_rate'] ?? 0,
                    'amount' => $itemSubtotal + $itemTax,
                ]);
            }

            return response()->json($debitNote->load(['party', 'items.item']), 201);
        });
    }

    public function show($id, Request $request)
    {
        $debitNote = DebitNote::with(['party', 'items.item', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($debitNote);
    }

    public function destroy($id, Request $request)
    {
        $debitNote = DebitNote::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $debitNote->delete();

        return response()->json(['message' => 'Debit note deleted successfully']);
    }

    public function getNextNumber(Request $request)
    {
        $lastNote = DebitNote::where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('id', 'desc')
            ->first();

        $nextNumber = $lastNote 
            ? 'DN-' . str_pad((int)substr($lastNote->debit_note_number, 3) + 1, 6, '0', STR_PAD_LEFT)
            : 'DN-000001';

        return response()->json(['next_number' => $nextNumber]);
    }
}
