import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/organization_provider.dart';
import '../../models/purchase_return_model.dart';
import '../../services/purchase_return_service.dart';
import '../../widgets/loading_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Purchase Returns', style: AppTextStyles.h1),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePurchaseReturnScreen(),
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
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by return number or supplier...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 24),

          // Returns List
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
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
                          ],
                        ),
                      )
                    : Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Return No.')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Supplier')),
                              DataColumn(label: Text('Total Amount')),
                              DataColumn(label: Text('Amount Received')),
                              DataColumn(label: Text('Payment Mode')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _filteredReturns.map((ret) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(ret.returnNumber)),
                                  DataCell(Text(
                                    '${ret.returnDate.day}/${ret.returnDate.month}/${ret.returnDate.year}',
                                  )),
                                  DataCell(Text(ret.party?.name ?? '-')),
                                  DataCell(Text(
                                      '₹${ret.totalAmount.toStringAsFixed(2)}')),
                                  DataCell(Text(
                                      '₹${ret.amountReceived.toStringAsFixed(2)}')),
                                  DataCell(Text(ret.paymentMode ?? '-')),
                                  DataCell(_buildStatusChip(ret.status)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          onPressed: () {
                                            // TODO: View details
                                          },
                                          tooltip: 'View',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              _deleteReturn(ret.id),
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'rejected':
        color = AppColors.expiredRed;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
            const SnackBar(content: Text('Purchase return deleted')),
          );
          _loadReturns();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
