<?php

namespace App\Http\Controllers;

use App\Models\PaymentOut;
use App\Models\PurchaseInvoice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaymentOutController extends Controller
{
    public function index(Request $request)
    {
        $payments = PaymentOut::with(['party', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('payment_date', 'desc')
            ->paginate(20);

        return response()->json($payments);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'party_id' => 'required|exists:parties,id',
            'purchase_invoice_id' => 'nullable|exists:purchase_invoices,id',
            'payment_number' => 'required|unique:payment_outs',
            'payment_date' => 'required|date',
            'amount' => 'required|numeric|min:0.01',
            'payment_method' => 'required|in:cash,bank_transfer,cheque,card,upi,other',
            'reference_number' => 'nullable|string',
            'notes' => 'nullable|string',
            'status' => 'required|in:pending,completed,failed,cancelled',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $payment = PaymentOut::create([
                ...$validated,
                'organization_id' => $request->header('X-Organization-Id'),
            ]);

            if ($validated['purchase_invoice_id']) {
                $invoice = PurchaseInvoice::find($validated['purchase_invoice_id']);
                $invoice->paid_amount += $validated['amount'];
                $invoice->balance_amount = $invoice->total_amount - $invoice->paid_amount;
                
                if ($invoice->balance_amount <= 0) {
                    $invoice->status = 'paid';
                } elseif ($invoice->paid_amount > 0) {
                    $invoice->status = 'partial';
                }
                
                $invoice->save();
            }

            return response()->json($payment->load(['party', 'purchaseInvoice']), 201);
        });
    }

    public function show($id, Request $request)
    {
        $payment = PaymentOut::with(['party', 'purchaseInvoice'])
            ->where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        return response()->json($payment);
    }

    public function destroy($id, Request $request)
    {
        $payment = PaymentOut::where('organization_id', $request->header('X-Organization-Id'))
            ->findOrFail($id);

        $payment->delete();

        return response()->json(['message' => 'Payment deleted successfully']);
    }

    public function getNextPaymentNumber(Request $request)
    {
        $lastPayment = PaymentOut::where('organization_id', $request->header('X-Organization-Id'))
            ->orderBy('id', 'desc')
            ->first();

        $nextNumber = $lastPayment 
            ? 'PO-' . str_pad((int)substr($lastPayment->payment_number, 3) + 1, 6, '0', STR_PAD_LEFT)
            : 'PO-000001';

        return response()->json(['next_number' => $nextNumber]);
    }
}
