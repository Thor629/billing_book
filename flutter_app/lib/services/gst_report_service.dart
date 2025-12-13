import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_config.dart';
import 'auth_service.dart';

class GstReportService {
  final AuthService _authService = AuthService();

  // Helper function to convert dynamic to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<Map<String, dynamic>> getGstSummary(
    int organizationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/gst-reports/summary').replace(
        queryParameters: {
          'organization_id': organizationId.toString(),
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load GST summary');
    }
  }

  Future<Map<String, dynamic>> getGstByRate(
    int organizationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/gst-reports/by-rate').replace(
          queryParameters: {
            'organization_id': organizationId.toString(),
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print(
          'GST By Rate Error: Status ${response.statusCode}, Body: ${response.body}',
        );
        return {'sales_by_rate': [], 'purchase_by_rate': []};
      }
    } catch (e) {
      return {'sales_by_rate': [], 'purchase_by_rate': []};
    }
  }

  Future<List<dynamic>> getGstTransactions(
    int organizationId,
    DateTime startDate,
    DateTime endDate, {
    String type = 'all',
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/gst-reports/transactions').replace(
          queryParameters: {
            'organization_id': organizationId.toString(),
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'type': type,
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print(
          'GST Transactions Error: Status ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Uint8List> generateGstReportPdf({
    required Map<String, dynamic> summary,
    required List<dynamic> salesByRate,
    required List<dynamic> purchaseByRate,
    required List<dynamic> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required String organizationName,
  }) async {
    final pdf = pw.Document();

    final sales = summary['sales'];
    final purchases = summary['purchases'];
    final netLiability = _toDouble(summary['net_gst_liability']);

    // Add Summary Page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Text(
            'GST REPORT',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(organizationName, style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),

          // Summary Section
          pw.Text(
            'SUMMARY',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          // Summary Cards
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Output GST (Sales)',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Rs. ${_toDouble(sales['gst_amount']).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Input GST (Purchase)',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Rs. ${_toDouble(purchases['gst_amount']).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Net Liability
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              color: PdfColors.grey100,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Net GST Liability',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Rs. ${netLiability.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: netLiability >= 0 ? PdfColors.red : PdfColors.green,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Detailed Breakdown
          pw.Text(
            'DETAILED BREAKDOWN',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Description',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Amount',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              _buildPdfTableRow(
                  'Sales Taxable Amount', _toDouble(sales['taxable_amount'])),
              _buildPdfTableRow('Sales GST', _toDouble(sales['gst_amount'])),
              _buildPdfTableRow('Total Sales', _toDouble(sales['total_amount']),
                  isBold: true),
              _buildPdfTableRow('Purchase Taxable Amount',
                  _toDouble(purchases['taxable_amount'])),
              _buildPdfTableRow(
                  'Purchase GST', _toDouble(purchases['gst_amount'])),
              _buildPdfTableRow(
                  'Total Purchase', _toDouble(purchases['total_amount']),
                  isBold: true),
            ],
          ),
        ],
      ),
    );

    // Add GST by Rate Page
    if (salesByRate.isNotEmpty || purchaseByRate.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Text(
              'GST BY RATE',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),

            // Sales by Rate
            if (salesByRate.isNotEmpty) ...[
              pw.Text(
                'Sales GST by Rate',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPdfHeaderCell('GST Rate'),
                      _buildPdfHeaderCell('Taxable Amount'),
                      _buildPdfHeaderCell('GST Amount'),
                      _buildPdfHeaderCell('Invoice Count'),
                    ],
                  ),
                  ...salesByRate.map(
                    (item) => pw.TableRow(
                      children: [
                        _buildPdfCell('${item['gst_rate']}%'),
                        _buildPdfCell(
                          'Rs. ${_toDouble(item['taxable_amount']).toStringAsFixed(2)}',
                          align: pw.TextAlign.right,
                        ),
                        _buildPdfCell(
                          'Rs. ${_toDouble(item['gst_amount']).toStringAsFixed(2)}',
                          align: pw.TextAlign.right,
                        ),
                        _buildPdfCell(
                          item['invoice_count'].toString(),
                          align: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
            ],

            // Purchase by Rate
            if (purchaseByRate.isNotEmpty) ...[
              pw.Text(
                'Purchase GST by Rate',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPdfHeaderCell('GST Rate'),
                      _buildPdfHeaderCell('Taxable Amount'),
                      _buildPdfHeaderCell('GST Amount'),
                      _buildPdfHeaderCell('Invoice Count'),
                    ],
                  ),
                  ...purchaseByRate.map(
                    (item) => pw.TableRow(
                      children: [
                        _buildPdfCell('${item['gst_rate']}%'),
                        _buildPdfCell(
                          'Rs. ${_toDouble(item['taxable_amount']).toStringAsFixed(2)}',
                          align: pw.TextAlign.right,
                        ),
                        _buildPdfCell(
                          'Rs. ${_toDouble(item['gst_amount']).toStringAsFixed(2)}',
                          align: pw.TextAlign.right,
                        ),
                        _buildPdfCell(
                          item['invoice_count'].toString(),
                          align: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    // Add Transactions Page
    if (transactions.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Text(
              'TRANSACTIONS',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(1.5),
                6: const pw.FlexColumnWidth(1.5),
                7: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildPdfHeaderCell('Date'),
                    _buildPdfHeaderCell('Type'),
                    _buildPdfHeaderCell('Invoice No'),
                    _buildPdfHeaderCell('Party Name'),
                    _buildPdfHeaderCell('GSTIN'),
                    _buildPdfHeaderCell('Taxable Amt'),
                    _buildPdfHeaderCell('GST Amt'),
                    _buildPdfHeaderCell('Total'),
                  ],
                ),
                ...transactions.take(50).map(
                      (txn) => pw.TableRow(
                        children: [
                          _buildPdfCell(
                            DateFormat('dd MMM yy')
                                .format(DateTime.parse(txn['invoice_date'])),
                          ),
                          _buildPdfCell(txn['type']),
                          _buildPdfCell(txn['invoice_number']),
                          _buildPdfCell(txn['party_name']),
                          _buildPdfCell(txn['gstin'] ?? '-'),
                          _buildPdfCell(
                            'Rs. ${_toDouble(txn['taxable_amount']).toStringAsFixed(2)}',
                            align: pw.TextAlign.right,
                          ),
                          _buildPdfCell(
                            'Rs. ${_toDouble(txn['gst_amount']).toStringAsFixed(2)}',
                            align: pw.TextAlign.right,
                          ),
                          _buildPdfCell(
                            'Rs. ${_toDouble(txn['total_amount']).toStringAsFixed(2)}',
                            align: pw.TextAlign.right,
                          ),
                        ],
                      ),
                    ),
              ],
            ),
            if (transactions.length > 50)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Text(
                  'Note: Showing first 50 transactions only',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return pdf.save();
  }

  pw.TableRow _buildPdfTableRow(String label, double amount,
      {bool isBold = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPdfCell(String text, {pw.TextAlign? align}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
        textAlign: align ?? pw.TextAlign.left,
      ),
    );
  }

  Future<Uint8List> generateGstReportExcel({
    required Map<String, dynamic> summary,
    required List<dynamic> salesByRate,
    required List<dynamic> purchaseByRate,
    required List<dynamic> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required String organizationName,
  }) async {
    final excel = Excel.createExcel();

    final sales = summary['sales'];
    final purchases = summary['purchases'];
    final netLiability = _toDouble(summary['net_gst_liability']);

    // Remove default sheet
    excel.delete('Sheet1');

    // Create Summary Sheet
    final summarySheet = excel['Summary'];

    // Header
    summarySheet.cell(CellIndex.indexByString('A1')).value =
        TextCellValue('GST REPORT');
    summarySheet.cell(CellIndex.indexByString('A2')).value =
        TextCellValue(organizationName);
    summarySheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
        'Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}');

    // Summary Section
    summarySheet.cell(CellIndex.indexByString('A5')).value =
        TextCellValue('SUMMARY');
    summarySheet.cell(CellIndex.indexByString('A6')).value =
        TextCellValue('Output GST (Sales)');
    summarySheet.cell(CellIndex.indexByString('B6')).value =
        DoubleCellValue(_toDouble(sales['gst_amount']));
    summarySheet.cell(CellIndex.indexByString('A7')).value =
        TextCellValue('Input GST (Purchase)');
    summarySheet.cell(CellIndex.indexByString('B7')).value =
        DoubleCellValue(_toDouble(purchases['gst_amount']));
    summarySheet.cell(CellIndex.indexByString('A8')).value =
        TextCellValue('Net GST Liability');
    summarySheet.cell(CellIndex.indexByString('B8')).value =
        DoubleCellValue(netLiability);

    // Detailed Breakdown
    summarySheet.cell(CellIndex.indexByString('A10')).value =
        TextCellValue('DETAILED BREAKDOWN');
    summarySheet.cell(CellIndex.indexByString('A11')).value =
        TextCellValue('Description');
    summarySheet.cell(CellIndex.indexByString('B11')).value =
        TextCellValue('Amount');

    summarySheet.cell(CellIndex.indexByString('A12')).value =
        TextCellValue('Sales Taxable Amount');
    summarySheet.cell(CellIndex.indexByString('B12')).value =
        DoubleCellValue(_toDouble(sales['taxable_amount']));
    summarySheet.cell(CellIndex.indexByString('A13')).value =
        TextCellValue('Sales GST');
    summarySheet.cell(CellIndex.indexByString('B13')).value =
        DoubleCellValue(_toDouble(sales['gst_amount']));
    summarySheet.cell(CellIndex.indexByString('A14')).value =
        TextCellValue('Total Sales');
    summarySheet.cell(CellIndex.indexByString('B14')).value =
        DoubleCellValue(_toDouble(sales['total_amount']));
    summarySheet.cell(CellIndex.indexByString('A15')).value =
        TextCellValue('Purchase Taxable Amount');
    summarySheet.cell(CellIndex.indexByString('B15')).value =
        DoubleCellValue(_toDouble(purchases['taxable_amount']));
    summarySheet.cell(CellIndex.indexByString('A16')).value =
        TextCellValue('Purchase GST');
    summarySheet.cell(CellIndex.indexByString('B16')).value =
        DoubleCellValue(_toDouble(purchases['gst_amount']));
    summarySheet.cell(CellIndex.indexByString('A17')).value =
        TextCellValue('Total Purchase');
    summarySheet.cell(CellIndex.indexByString('B17')).value =
        DoubleCellValue(_toDouble(purchases['total_amount']));

    // Sales by Rate Sheet
    if (salesByRate.isNotEmpty) {
      final salesRateSheet = excel['Sales by Rate'];
      salesRateSheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('GST Rate');
      salesRateSheet.cell(CellIndex.indexByString('B1')).value =
          TextCellValue('Taxable Amount');
      salesRateSheet.cell(CellIndex.indexByString('C1')).value =
          TextCellValue('GST Amount');
      salesRateSheet.cell(CellIndex.indexByString('D1')).value =
          TextCellValue('Invoice Count');

      int row = 2;
      for (var item in salesByRate) {
        salesRateSheet.cell(CellIndex.indexByString('A$row')).value =
            TextCellValue('${item['gst_rate']}%');
        salesRateSheet.cell(CellIndex.indexByString('B$row')).value =
            DoubleCellValue(_toDouble(item['taxable_amount']));
        salesRateSheet.cell(CellIndex.indexByString('C$row')).value =
            DoubleCellValue(_toDouble(item['gst_amount']));
        salesRateSheet.cell(CellIndex.indexByString('D$row')).value =
            IntCellValue(item['invoice_count'] as int);
        row++;
      }
    }

    // Purchase by Rate Sheet
    if (purchaseByRate.isNotEmpty) {
      final purchaseRateSheet = excel['Purchase by Rate'];
      purchaseRateSheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('GST Rate');
      purchaseRateSheet.cell(CellIndex.indexByString('B1')).value =
          TextCellValue('Taxable Amount');
      purchaseRateSheet.cell(CellIndex.indexByString('C1')).value =
          TextCellValue('GST Amount');
      purchaseRateSheet.cell(CellIndex.indexByString('D1')).value =
          TextCellValue('Invoice Count');

      int row = 2;
      for (var item in purchaseByRate) {
        purchaseRateSheet.cell(CellIndex.indexByString('A$row')).value =
            TextCellValue('${item['gst_rate']}%');
        purchaseRateSheet.cell(CellIndex.indexByString('B$row')).value =
            DoubleCellValue(_toDouble(item['taxable_amount']));
        purchaseRateSheet.cell(CellIndex.indexByString('C$row')).value =
            DoubleCellValue(_toDouble(item['gst_amount']));
        purchaseRateSheet.cell(CellIndex.indexByString('D$row')).value =
            IntCellValue(item['invoice_count'] as int);
        row++;
      }
    }

    // Transactions Sheet
    if (transactions.isNotEmpty) {
      final transSheet = excel['Transactions'];
      transSheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('Date');
      transSheet.cell(CellIndex.indexByString('B1')).value =
          TextCellValue('Type');
      transSheet.cell(CellIndex.indexByString('C1')).value =
          TextCellValue('Invoice No');
      transSheet.cell(CellIndex.indexByString('D1')).value =
          TextCellValue('Party Name');
      transSheet.cell(CellIndex.indexByString('E1')).value =
          TextCellValue('GSTIN');
      transSheet.cell(CellIndex.indexByString('F1')).value =
          TextCellValue('Taxable Amount');
      transSheet.cell(CellIndex.indexByString('G1')).value =
          TextCellValue('GST Amount');
      transSheet.cell(CellIndex.indexByString('H1')).value =
          TextCellValue('Total');

      int row = 2;
      for (var txn in transactions) {
        transSheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
            DateFormat('dd MMM yyyy')
                .format(DateTime.parse(txn['invoice_date'])));
        transSheet.cell(CellIndex.indexByString('B$row')).value =
            TextCellValue(txn['type']);
        transSheet.cell(CellIndex.indexByString('C$row')).value =
            TextCellValue(txn['invoice_number']);
        transSheet.cell(CellIndex.indexByString('D$row')).value =
            TextCellValue(txn['party_name']);
        transSheet.cell(CellIndex.indexByString('E$row')).value =
            TextCellValue(txn['gstin'] ?? '-');
        transSheet.cell(CellIndex.indexByString('F$row')).value =
            DoubleCellValue(_toDouble(txn['taxable_amount']));
        transSheet.cell(CellIndex.indexByString('G$row')).value =
            DoubleCellValue(_toDouble(txn['gst_amount']));
        transSheet.cell(CellIndex.indexByString('H$row')).value =
            DoubleCellValue(_toDouble(txn['total_amount']));
        row++;
      }
    }

    return Uint8List.fromList(excel.encode()!);
  }
}
