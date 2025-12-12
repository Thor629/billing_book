import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/organization_provider.dart';
import '../../models/purchase_return_model.dart';
import '../../services/purchase_return_service.dart';
import '../../widgets/unified_data_table.dart';
import 'create_purchase_return_screen.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  List<PurchaseReturn> _returns = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'Last 365 Days';

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    setState(() => _isLoading = true);
    try {
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization != null) {
        final service = PurchaseReturnService();
        final returns = await service.getPurchaseReturns(
          orgProvider.selectedOrganization!.id,
        );
        setState(() {
          _returns = returns;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<PurchaseReturn> get _filteredReturns {
    if (_searchQuery.isEmpty) return _returns;
    return _returns.where((ret) {
      return ret.returnNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          ret.party?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ==
              true;
    }).toList();
  }

  int get _totalReturns => _returns.length;
  int get _pendingReturns =>
      _returns.where((r) => r.status.toLowerCase() == 'pending').length;
  int get _approvedReturns =>
      _returns.where((r) => r.status.toLowerCase() == 'approved').length;

  double get _totalAmount {
    double total = 0;
    for (var ret in _returns) {
      total += ret.totalAmount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Purchase Returns', style: AppTextStyles.h1),
                Row(
                  children: [
                    _buildReportsButton(),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      tooltip: 'Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadReturns,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Returns',
                    value: '₹${_totalAmount.toStringAsFixed(2)}',
                    icon: Icons.currency_rupee,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Count',
                    value: _totalReturns.toString(),
                    icon: Icons.assignment_return,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Approved',
                    value: _approvedReturns.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pending',
                    value: _pendingReturns.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Bar
            Row(
              children: [
                // Date Filter
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Last 365 Days',
                            child: Text('Last 365 Days'),
                          ),
                          DropdownMenuItem(
                            value: 'Last 30 Days',
                            child: Text('Last 30 Days'),
                          ),
                          DropdownMenuItem(
                            value: 'Last 7 Days',
                            child: Text('Last 7 Days'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedFilter = value);
                            _loadReturns();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Search
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search returns...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const Spacer(),

                // Create Purchase Return Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CreatePurchaseReturnScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadReturns();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Purchase Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredReturns.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_return_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No purchase returns found',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first purchase return to get started',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreatePurchaseReturnScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadReturns();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Return'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: AppColors.textLight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : UnifiedDataTable(
                          columns: const [
                            DataColumn(label: TableHeader('Return No.')),
                            DataColumn(label: TableHeader('Date')),
                            DataColumn(label: TableHeader('Supplier')),
                            DataColumn(label: TableHeader('Total Amount')),
                            DataColumn(label: TableHeader('Amount Received')),
                            DataColumn(label: TableHeader('Payment Mode')),
                            DataColumn(label: TableHeader('Status')),
                            DataColumn(label: TableHeader('Actions')),
                          ],
                          rows: _buildReturnRows(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildReturnRows() {
    return _filteredReturns.map((ret) {
      return DataRow(
        cells: [
          DataCell(TableCellText(ret.returnNumber)),
          DataCell(TableCellText(
            '${ret.returnDate.day}/${ret.returnDate.month}/${ret.returnDate.year}',
          )),
          DataCell(TableCellText(ret.party?.name ?? '-')),
          DataCell(TableAmount(amount: ret.totalAmount)),
          DataCell(TableAmount(amount: ret.amountReceived)),
          DataCell(TableCellText(ret.paymentMode ?? '-')),
          DataCell(TableStatusBadge(ret.status)),
          DataCell(
            TableActionButtons(
              onView: () => _viewReturn(ret),
              onEdit: () => _editReturn(ret),
              onDelete: () => _deleteReturn(ret.id),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _viewReturn(PurchaseReturn ret) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Return ${ret.returnNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Supplier', ret.party?.name ?? 'N/A'),
              _buildDetailRow(
                'Date',
                '${ret.returnDate.day}/${ret.returnDate.month}/${ret.returnDate.year}',
              ),
              _buildDetailRow(
                'Total Amount',
                '₹${ret.totalAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Amount Received',
                '₹${ret.amountReceived.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Payment Mode', ret.paymentMode ?? 'N/A'),
              _buildDetailRow('Status', ret.status.toUpperCase()),
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

  void _editReturn(PurchaseReturn ret) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePurchaseReturnScreen(
          returnId: ret.id,
          returnData: {
            'return_number': ret.returnNumber,
            'party_id': ret.party?.id,
            'party_name': ret.party?.name,
            'return_date': ret.returnDate.toIso8601String(),
            'total_amount': ret.totalAmount,
            'amount_received': ret.amountReceived,
            'payment_mode': ret.paymentMode,
            'status': ret.status,
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadReturns();
      }
    });
  }

  Future<void> _deleteReturn(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase Return'),
        content: const Text('Are you sure you want to delete this return?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final orgProvider =
            Provider.of<OrganizationProvider>(context, listen: false);

        final service = PurchaseReturnService();
        await service.deletePurchaseReturn(
          orgProvider.selectedOrganization!.id,
          id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase return deleted'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReturns();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.h2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsButton() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, size: 18, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text('Reports', style: TextStyle(color: Colors.blue[700])),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'returns', child: Text('Returns Report')),
        const PopupMenuItem(value: 'vendor', child: Text('Vendor Report')),
      ],
      onSelected: (value) {},
    );
  }
}
