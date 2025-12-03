import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/sales_return_model.dart';
import '../../services/sales_return_service.dart';
import '../../providers/organization_provider.dart';
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateSalesReturnScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadReturns();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
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
                    : Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Sales Return Number')),
                              DataColumn(label: Text('Party Name')),
                              DataColumn(label: Text('Invoice No')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _returns.map((salesReturn) {
                              return DataRow(cells: [
                                DataCell(Text(
                                    '${salesReturn.returnDate.day.toString().padLeft(2, '0')} ${_getMonthName(salesReturn.returnDate.month)} ${salesReturn.returnDate.year}')),
                                DataCell(Text(salesReturn.returnNumber)),
                                DataCell(Text(salesReturn.partyName ?? '-')),
                                DataCell(
                                    Text(salesReturn.invoiceNumber ?? '-')),
                                DataCell(Text(
                                    '₹ ${salesReturn.totalAmount.toStringAsFixed(2)}')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: salesReturn.status == 'refunded'
                                          ? Colors.blue[50]
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      salesReturn.status == 'refunded'
                                          ? 'Refunded'
                                          : 'Unpaid',
                                      style: TextStyle(
                                        color: salesReturn.status == 'refunded'
                                            ? Colors.blue[700]
                                            : Colors.red[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () =>
                                        _showDeleteDialog(salesReturn),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
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
