import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/sales_return_model.dart';
import '../../services/sales_return_service.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/unified_data_table.dart';
import 'create_sales_return_screen.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  final SalesReturnService _returnService = SalesReturnService();
  String _selectedFilter = 'Last 365 Days';
  bool _isLoading = true;
  List<SalesReturn> _returns = [];

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _returnService.getReturns(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _selectedFilter,
      );
      setState(() {
        _returns = result['returns'] as List<SalesReturn>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading returns: $e')),
        );
      }
    }
  }

  Future<void> _deleteReturn(int id) async {
    try {
      await _returnService.deleteReturn(id);
      _loadReturns();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sales return deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting return: $e')),
        );
      }
    }
  }

  void _viewReturn(SalesReturn salesReturn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sales Return ${salesReturn.returnNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', salesReturn.partyName ?? 'N/A'),
              _buildDetailRow(
                'Date',
                '${salesReturn.returnDate.day.toString().padLeft(2, '0')} ${_getMonthName(salesReturn.returnDate.month)} ${salesReturn.returnDate.year}',
              ),
              _buildDetailRow(
                'Amount',
                '₹${salesReturn.totalAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Amount Paid',
                '₹${salesReturn.amountPaid.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Payment Mode', salesReturn.paymentMode ?? 'N/A'),
              _buildDetailRow('Status', salesReturn.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editReturn(SalesReturn salesReturn) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateSalesReturnScreen(
        returnId: salesReturn.id,
        returnData: {
          'return_number': salesReturn.returnNumber,
          'party_id': salesReturn.partyId,
          'party_name': salesReturn.partyName,
          'invoice_number': salesReturn.invoiceNumber,
          'return_date': salesReturn.returnDate.toIso8601String(),
          'total_amount': salesReturn.totalAmount,
          'amount_paid': salesReturn.amountPaid,
          'payment_mode': salesReturn.paymentMode,
          'status': salesReturn.status,
        },
      ),
    );

    if (result == true) {
      _loadReturns();
    }
  }

  void _showDeleteDialog(SalesReturn salesReturn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sales Return'),
        content: Text(
            'Are you sure you want to delete return #${salesReturn.returnNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReturn(salesReturn.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = Provider.of<OrganizationProvider>(context);

    if (orgProvider.selectedOrganization == null) {
      return const Center(
        child: Text('Please select an organization first'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sales Return', style: AppTextStyles.h1),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const CreateSalesReturnScreen(),
                  );
                  if (result == true) {
                    _loadReturns();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Create Sales Return'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                        value: 'Last 7 Days', child: Text('Last 7 Days')),
                    DropdownMenuItem(
                        value: 'Last 30 Days', child: Text('Last 30 Days')),
                    DropdownMenuItem(
                        value: 'Last 365 Days', child: Text('Last 365 Days')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFilter = value);
                      _loadReturns();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _returns.isEmpty
                    ? const Center(child: Text('No sales returns found'))
                    : UnifiedDataTable(
                        columns: const [
                          DataColumn(label: TableHeader('Date')),
                          DataColumn(label: TableHeader('Sales Return Number')),
                          DataColumn(label: TableHeader('Party Name')),
                          DataColumn(label: TableHeader('Invoice No')),
                          DataColumn(label: TableHeader('Amount')),
                          DataColumn(label: TableHeader('Status')),
                          DataColumn(label: TableHeader('Actions')),
                        ],
                        rows: _returns.map((salesReturn) {
                          return DataRow(cells: [
                            DataCell(TableCellText(
                                '${salesReturn.returnDate.day.toString().padLeft(2, '0')} ${_getMonthName(salesReturn.returnDate.month)} ${salesReturn.returnDate.year}')),
                            DataCell(TableCellText(salesReturn.returnNumber)),
                            DataCell(
                                TableCellText(salesReturn.partyName ?? '-')),
                            DataCell(TableCellText(
                                salesReturn.invoiceNumber ?? '-')),
                            DataCell(TableCellText(
                                '₹ ${salesReturn.totalAmount.toStringAsFixed(2)}')),
                            DataCell(TableStatusBadge(
                              salesReturn.status == 'refunded'
                                  ? 'Refunded'
                                  : 'Unpaid',
                            )),
                            DataCell(
                              TableActionButtons(
                                onView: () => _viewReturn(salesReturn),
                                onEdit: () => _editReturn(salesReturn),
                                onDelete: () => _showDeleteDialog(salesReturn),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
