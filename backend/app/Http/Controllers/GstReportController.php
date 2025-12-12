<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class GstReportController extends Controller
{
    /**
     * Get GST Summary Report
     */
    public function getGstSummary(Request $request)
    {
        $organizationId = $request->input('organization_id');
        $startDate = $request->input('start_date', Carbon::now()->startOfMonth()->toDateString());
        $endDate = $request->input('end_date', Carbon::now()->endOfMonth()->toDateString());

        // Sales GST (Output GST)
        $salesGst = DB::table('sales_invoices')
            ->where('organization_id', $organizationId)
            ->whereBetween('invoice_date', [$startDate, $endDate])
            ->selectRaw('
                SUM(total_amount - tax_amount) as taxable_amount,
                SUM(tax_amount) as gst_amount,
                SUM(total_amount) as total_amount
            ')
            ->first();

        // Purchase GST (Input GST)
        $purchaseGst = DB::table('purchase_invoices')
            ->where('organization_id', $organizationId)
            ->whereBetween('invoice_date', [$startDate, $endDate])
            ->selectRaw('
                SUM(total_amount - tax_amount) as taxable_amount,
                SUM(tax_amount) as gst_amount,
                SUM(total_amount) as total_amount
            ')
            ->first();

        // Calculate net GST liability
        $outputGst = $salesGst->gst_amount ?? 0;
        $inputGst = $purchaseGst->gst_amount ?? 0;
        $netGstLiability = $outputGst - $inputGst;

        return response()->json([
            'success' => true,
            'data' => [
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ],
                'sales' => [
                    'taxable_amount' => $salesGst->taxable_amount ?? 0,
                    'gst_amount' => $outputGst,
                    'total_amount' => $salesGst->total_amount ?? 0,
                ],
                'purchases' => [
                    'taxable_amount' => $purchaseGst->taxable_amount ?? 0,
                    'gst_amount' => $inputGst,
                    'total_amount' => $purchaseGst->total_amount ?? 0,
                ],
                'net_gst_liability' => $netGstLiability,
            ],
        ]);
    }

    /**
     * Get GST Report by Rate
     */
    public function getGstByRate(Request $request)
    {
        $organizationId = $request->input('organization_id');
        $startDate = $request->input('start_date', Carbon::now()->startOfMonth()->toDateString());
        $endDate = $request->input('end_date', Carbon::now()->endOfMonth()->toDateString());

        // Sales by GST Rate
        $salesByRate = DB::table('sales_invoice_items')
            ->join('sales_invoices', 'sales_invoice_items.sales_invoice_id', '=', 'sales_invoices.id')
            ->where('sales_invoices.organization_id', $organizationId)
            ->whereBetween('sales_invoices.invoice_date', [$startDate, $endDate])
            ->selectRaw('
                sales_invoice_items.gst_rate,
                SUM(sales_invoice_items.quantity * sales_invoice_items.price) as taxable_amount,
                SUM(sales_invoice_items.tax_amount) as gst_amount,
                COUNT(DISTINCT sales_invoices.id) as invoice_count
            ')
            ->groupBy('sales_invoice_items.gst_rate')
            ->orderBy('sales_invoice_items.gst_rate')
            ->get();

        // Purchase by GST Rate
        $purchaseByRate = DB::table('purchase_invoice_items')
            ->join('purchase_invoices', 'purchase_invoice_items.purchase_invoice_id', '=', 'purchase_invoices.id')
            ->where('purchase_invoices.organization_id', $organizationId)
            ->whereBetween('purchase_invoices.invoice_date', [$startDate, $endDate])
            ->selectRaw('
                purchase_invoice_items.gst_rate,
                SUM(purchase_invoice_items.quantity * purchase_invoice_items.price) as taxable_amount,
                SUM(purchase_invoice_items.tax_amount) as gst_amount,
                COUNT(DISTINCT purchase_invoices.id) as invoice_count
            ')
            ->groupBy('purchase_invoice_items.gst_rate')
            ->orderBy('purchase_invoice_items.gst_rate')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'sales_by_rate' => $salesByRate,
                'purchase_by_rate' => $purchaseByRate,
            ],
        ]);
    }

    /**
     * Get Detailed GST Transactions
     */
    public function getGstTransactions(Request $request)
    {
        $organizationId = $request->input('organization_id');
        $startDate = $request->input('start_date', Carbon::now()->startOfMonth()->toDateString());
        $endDate = $request->input('end_date', Carbon::now()->endOfMonth()->toDateString());
        $type = $request->input('type', 'all'); // all, sales, purchase

        $transactions = [];

        if ($type === 'all' || $type === 'sales') {
            $sales = DB::table('sales_invoices')
                ->join('parties', 'sales_invoices.party_id', '=', 'parties.id')
                ->where('sales_invoices.organization_id', $organizationId)
                ->whereBetween('sales_invoices.invoice_date', [$startDate, $endDate])
                ->select(
                    'sales_invoices.id',
                    'sales_invoices.invoice_number',
                    'sales_invoices.invoice_date',
                    'parties.name as party_name',
                    'parties.gstin',
                    DB::raw('(sales_invoices.total_amount - sales_invoices.tax_amount) as taxable_amount'),
                    'sales_invoices.tax_amount as gst_amount',
                    'sales_invoices.total_amount',
                    DB::raw("'Sales' as type")
                )
                ->get();

            $transactions = array_merge($transactions, $sales->toArray());
        }

        if ($type === 'all' || $type === 'purchase') {
            $purchases = DB::table('purchase_invoices')
                ->join('parties', 'purchase_invoices.party_id', '=', 'parties.id')
                ->where('purchase_invoices.organization_id', $organizationId)
                ->whereBetween('purchase_invoices.invoice_date', [$startDate, $endDate])
                ->select(
                    'purchase_invoices.id',
                    'purchase_invoices.invoice_number',
                    'purchase_invoices.invoice_date',
                    'parties.name as party_name',
                    'parties.gstin',
                    DB::raw('(purchase_invoices.total_amount - purchase_invoices.tax_amount) as taxable_amount'),
                    'purchase_invoices.tax_amount as gst_amount',
                    'purchase_invoices.total_amount',
                    DB::raw("'Purchase' as type")
                )
                ->get();

            $transactions = array_merge($transactions, $purchases->toArray());
        }

        // Sort by date
        usort($transactions, function ($a, $b) {
            return strtotime($b->invoice_date) - strtotime($a->invoice_date);
        });

        return response()->json([
            'success' => true,
            'data' => $transactions,
        ]);
    }
}
