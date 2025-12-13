import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/organization_provider.dart';
import '../../services/gst_report_service.dart';
import '../../widgets/unified_data_table.dart';

class GstReportScreen extends StatefulWidget {
  const GstReportScreen({super.key});

  @override
  State<GstReportScreen> createState() => _GstReportScreenState();
}

class _GstReportScreenState extends State<GstReportScreen> {
  final GstReportService _gstService = GstReportService();

  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  Map<String, dynamic>? _summary;
  List<dynamic> _salesByRate = [];
  List<dynamic> _purchaseByRate = [];
  List<dynamic> _transactions = [];
  String _selectedTab = 'summary';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isLoading = true);

    try {
      final summary = await _gstService.getGstSummary(
        orgProvider.selectedOrganization!.id,
        _startDate,
        _endDate,
      );

      Map<String, dynamic> byRate = {};
      List<dynamic> transactions = [];

      try {
        byRate = await _gstService.getGstByRate(
          orgProvider.selectedOrganization!.id,
          _startDate,
          _endDate,
        );
      } catch (e) {
        debugPrint('Error loading GST by rate: $e');
        byRate = {'sales_by_rate': [], 'purchase_by_rate': []};
      }

      try {
        transactions = await _gstService.getGstTransactions(
          orgProvider.selectedOrganization!.id,
          _startDate,
          _endDate,
        );
      } catch (e) {
        debugPrint('Error loading GST transactions: $e');
        transactions = [];
      }

      setState(() {
        _summary = summary;
        _salesByRate = byRate['sales_by_rate'] ?? [];
        _purchaseByRate = byRate['purchase_by_rate'] ?? [];
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading GST summary: $e');
      setState(() {
        _summary = {
          'sales': {
            'taxable_amount': 0.0,
            'gst_amount': 0.0,
            'total_amount': 0.0
          },
          'purchases': {
            'taxable_amount': 0.0,
            'gst_amount': 0.0,
            'total_amount': 0.0
          },
          'net_gst_liability': 0.0,
        };
        _salesByRate = [];
        _purchaseByRate = [];
        _transactions = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'GST Report loaded with default values. Create some invoices to see data.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Column(
        children: [
          _buildHeader(),
          _buildDateFilter(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Text(
            'GST Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _exportToPdf,
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF217346),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _shareOnWhatsApp,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    debugPrint('Export PDF clicked');

    if (_summary == null) {
      debugPrint('No summary data available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    debugPrint('Starting PDF generation...');

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      debugPrint('Organization: ${orgProvider.selectedOrganization?.name}');
      debugPrint(
          'Calling generateGstReportPdf with ${_transactions.length} transactions');

      // Generate PDF bytes (works on all platforms including Web)
      final pdfBytes = await _gstService.generateGstReportPdf(
        summary: _summary!,
        salesByRate: _salesByRate,
        purchaseByRate: _purchaseByRate,
        transactions: _transactions,
        startDate: _startDate,
        endDate: _endDate,
        organizationName:
            orgProvider.selectedOrganization?.name ?? 'Organization',
      );

      debugPrint('PDF bytes generated: ${pdfBytes.length} bytes');

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      debugPrint('Opening PDF preview...');
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
      );

      debugPrint('PDF preview opened successfully');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      debugPrint('PDF Generation Error: $e');
      debugPrint('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToExcel() async {
    debugPrint('Export Excel clicked');

    if (_summary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    debugPrint('Starting Excel generation...');

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating Excel...'),
                ],
              ),
            ),
          ),
        ),
      );

      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      debugPrint('Calling generateGstReportExcel...');

      final excelBytes = await _gstService.generateGstReportExcel(
        summary: _summary!,
        salesByRate: _salesByRate,
        purchaseByRate: _purchaseByRate,
        transactions: _transactions,
        startDate: _startDate,
        endDate: _endDate,
        organizationName:
            orgProvider.selectedOrganization?.name ?? 'Organization',
      );

      debugPrint('Excel bytes generated: ${excelBytes.length} bytes');

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Download Excel file
      await Printing.sharePdf(
        bytes: excelBytes,
        filename:
            'GST_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx',
      );

      debugPrint('Excel shared successfully');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      debugPrint('Excel Generation Error: $e');
      debugPrint('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating Excel: $e'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareOnWhatsApp() async {
    if (_summary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to share')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing to share...'),
                ],
              ),
            ),
          ),
        ),
      );

      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      // Generate PDF bytes (works on all platforms including Web)
      final pdfBytes = await _gstService.generateGstReportPdf(
        summary: _summary!,
        salesByRate: _salesByRate,
        purchaseByRate: _purchaseByRate,
        transactions: _transactions,
        startDate: _startDate,
        endDate: _endDate,
        organizationName:
            orgProvider.selectedOrganization?.name ?? 'Organization',
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show share options
      await _showShareOptions(pdfBytes);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing share: $e')),
      );
    }
  }

  Future<void> _showShareOptions(Uint8List pdfBytes) async {
    final sales = _summary!['sales'];
    final purchases = _summary!['purchases'];
    final netLiability = _toDouble(_summary!['net_gst_liability']);

    final message = '''
📊 *GST Report*
${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}

💰 *Summary*
Output GST (Sales): ₹${_toDouble(sales['gst_amount']).toStringAsFixed(2)}
Input GST (Purchase): ₹${_toDouble(purchases['gst_amount']).toStringAsFixed(2)}
Net GST Liability: ₹${netLiability.toStringAsFixed(2)}

📄 Detailed report attached.
''';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share GST Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat, color: Color(0xFF25D366)),
              ),
              title: const Text('Share on WhatsApp'),
              subtitle: const Text('Share PDF via WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                await _shareViaWhatsApp(pdfBytes, message);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.share, color: Colors.blue),
              ),
              title: const Text('Share via Other Apps'),
              subtitle: const Text('Email, Messages, etc.'),
              onTap: () async {
                Navigator.pop(context);
                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename:
                      'GST_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.message, color: Colors.grey),
              ),
              title: const Text('Share Text Only'),
              subtitle: const Text('Share summary without PDF'),
              onTap: () async {
                Navigator.pop(context);
                await Share.share(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareViaWhatsApp(Uint8List pdfBytes, String message) async {
    try {
      // Share PDF via printing package
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'GST_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

      // Try WhatsApp URL for text message
      try {
        final whatsappUrl =
            Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl);
        }
      } catch (e) {
        // WhatsApp URL failed, but PDF was already shared
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    }
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildDateButton('Start Date', _startDate, (date) {
            setState(() => _startDate = date);
            _loadData();
          }),
          const SizedBox(width: 16),
          _buildDateButton('End Date', _endDate, (date) {
            setState(() => _endDate = date);
            _loadData();
          }),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
      String label, DateTime date, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildTab('Summary', 'summary'),
          _buildTab('By GST Rate', 'by_rate'),
          _buildTab('Transactions', 'transactions'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _selectedTab == value;
    return InkWell(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFFFF9800) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'summary':
        return _buildSummaryTab();
      case 'by_rate':
        return _buildByRateTab();
      case 'transactions':
        return _buildTransactionsTab();
      default:
        return const SizedBox();
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildSummaryTab() {
    if (_summary == null) return const Center(child: Text('No data'));

    final sales = _summary!['sales'];
    final purchases = _summary!['purchases'];
    final netLiability = _toDouble(_summary!['net_gst_liability']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildSummaryCard(
                'Output GST (Sales)',
                _toDouble(sales['gst_amount']),
                Colors.green,
                Icons.arrow_upward,
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildSummaryCard(
                'Input GST (Purchase)',
                _toDouble(purchases['gst_amount']),
                Colors.blue,
                Icons.arrow_downward,
              )),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Net GST Liability',
            netLiability,
            netLiability >= 0 ? Colors.red : Colors.green,
            Icons.account_balance,
          ),
          const SizedBox(height: 24),
          _buildDetailedSummary(sales, purchases),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSummary(
      Map<String, dynamic> sales, Map<String, dynamic> purchases) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Sales Taxable Amount', _toDouble(sales['taxable_amount'])),
          _buildDetailRow('Sales GST', _toDouble(sales['gst_amount'])),
          _buildDetailRow('Total Sales', _toDouble(sales['total_amount']),
              isBold: true),
          const Divider(height: 32),
          _buildDetailRow('Purchase Taxable Amount',
              _toDouble(purchases['taxable_amount'])),
          _buildDetailRow('Purchase GST', _toDouble(purchases['gst_amount'])),
          _buildDetailRow(
              'Total Purchase', _toDouble(purchases['total_amount']),
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildByRateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRateTable('Sales GST by Rate', _salesByRate),
          const SizedBox(height: 24),
          _buildRateTable('Purchase GST by Rate', _purchaseByRate),
        ],
      ),
    );
  }

  Widget _buildRateTable(String title, List<dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          UnifiedDataTable(
            columns: const [
              DataColumn(label: TableHeader('GST Rate')),
              DataColumn(label: TableHeader('Taxable Amount')),
              DataColumn(label: TableHeader('GST Amount')),
              DataColumn(label: TableHeader('Invoice Count')),
            ],
            rows: data.map((item) {
              return DataRow(cells: [
                DataCell(TableCellText('${item['gst_rate']}%')),
                DataCell(
                    TableAmount(amount: _toDouble(item['taxable_amount']))),
                DataCell(TableAmount(amount: _toDouble(item['gst_amount']))),
                DataCell(TableCellText(item['invoice_count'].toString())),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: UnifiedDataTable(
        columns: const [
          DataColumn(label: TableHeader('Date')),
          DataColumn(label: TableHeader('Type')),
          DataColumn(label: TableHeader('Invoice No')),
          DataColumn(label: TableHeader('Party Name')),
          DataColumn(label: TableHeader('GSTIN')),
          DataColumn(label: TableHeader('Taxable Amount')),
          DataColumn(label: TableHeader('GST Amount')),
          DataColumn(label: TableHeader('Total')),
        ],
        rows: _transactions.map((txn) {
          return DataRow(cells: [
            DataCell(TableCellText(
              DateFormat('dd MMM yyyy')
                  .format(DateTime.parse(txn['invoice_date'])),
            )),
            DataCell(TableStatusBadge(txn['type'])),
            DataCell(TableCellText(txn['invoice_number'])),
            DataCell(TableCellText(txn['party_name'])),
            DataCell(TableCellText(txn['gstin'] ?? '-')),
            DataCell(TableAmount(amount: _toDouble(txn['taxable_amount']))),
            DataCell(TableAmount(amount: _toDouble(txn['gst_amount']))),
            DataCell(TableAmount(amount: _toDouble(txn['total_amount']))),
          ]);
        }).toList(),
      ),
    );
  }
}
