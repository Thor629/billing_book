import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
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
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Export functionality
            },
          ),
        ],
      ),
    );
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

  Widget _buildSummaryTab() {
    if (_summary == null) return const Center(child: Text('No data'));

    final sales = _summary!['sales'];
    final purchases = _summary!['purchases'];
    final netLiability = _summary!['net_gst_liability'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildSummaryCard(
                'Output GST (Sales)',
                sales['gst_amount'],
                Colors.green,
                Icons.arrow_upward,
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildSummaryCard(
                'Input GST (Purchase)',
                purchases['gst_amount'],
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
                  color: color.withOpacity(0.1),
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
          _buildDetailRow('Sales Taxable Amount', sales['taxable_amount']),
          _buildDetailRow('Sales GST', sales['gst_amount']),
          _buildDetailRow('Total Sales', sales['total_amount'], isBold: true),
          const Divider(height: 32),
          _buildDetailRow(
              'Purchase Taxable Amount', purchases['taxable_amount']),
          _buildDetailRow('Purchase GST', purchases['gst_amount']),
          _buildDetailRow('Total Purchase', purchases['total_amount'],
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
                    TableAmount(amount: item['taxable_amount'].toDouble())),
                DataCell(TableAmount(amount: item['gst_amount'].toDouble())),
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
            DataCell(TableAmount(amount: txn['taxable_amount'].toDouble())),
            DataCell(TableAmount(amount: txn['gst_amount'].toDouble())),
            DataCell(TableAmount(amount: txn['total_amount'].toDouble())),
          ]);
        }).toList(),
      ),
    );
  }
}
