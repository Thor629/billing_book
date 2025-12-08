import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/organization_provider.dart';
import '../../services/purchase_invoice_service.dart';
import 'create_purchase_invoice_screen.dart';

class PurchaseInvoicesScreen extends StatefulWidget {
  const PurchaseInvoicesScreen({super.key});

  @override
  State<PurchaseInvoicesScreen> createState() => _PurchaseInvoicesScreenState();
}

class _PurchaseInvoicesScreenState extends State<PurchaseInvoicesScreen> {
  final PurchaseInvoiceService _purchaseInvoiceService =
      PurchaseInvoiceService();
  List<dynamic> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please select an organization';
        });
        return;
      }

      final result = await _purchaseInvoiceService.getPurchaseInvoices(
        organizationId: orgProvider.selectedOrganization!.id,
      );

      setState(() {
        _invoices = result['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading invoices: $e';
      });
    }
  }

  int get _totalInvoices => _invoices.length;
  int get _pendingInvoices => _invoices
      .where((inv) =>
          inv['payment_status'] == 'unpaid' ||
          inv['payment_status'] == 'partial')
      .length;
  int get _paidInvoices =>
      _invoices.where((inv) => inv['payment_status'] == 'paid').length;
  int get _overdueInvoices => 0; // TODO: Calculate based on due_date

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Purchase Invoices', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Manage vendor invoices and track payments',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePurchaseInvoiceScreen(),
                    ),
                  );
                  if (result == true && mounted) {
                    // Reload the list
                    _loadInvoices();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('New Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Invoices',
                  _totalInvoices.toString(),
                  Icons.receipt_long,
                  AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _pendingInvoices.toString(),
                  Icons.pending_actions,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Paid',
                  _paidInvoices.toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  _overdueInvoices.toString(),
                  Icons.error,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Table
          Expanded(
            child: Card(
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('Invoice #',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Vendor',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Date',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Amount',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Status',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Actions',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        size: 64, color: Colors.red[300]),
                                    const SizedBox(height: 16),
                                    Text(_errorMessage!,
                                        style: AppTextStyles.bodyMedium),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadInvoices,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : _invoices.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No purchase invoices yet',
                                          style: AppTextStyles.h3.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Create your first purchase invoice to get started',
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
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
                                                    const CreatePurchaseInvoiceScreen(),
                                              ),
                                            );
                                            if (result == true && mounted) {
                                              _loadInvoices();
                                            }
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Create Invoice'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryDark,
                                            foregroundColor:
                                                AppColors.textLight,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _invoices.length,
                                    itemBuilder: (context, index) {
                                      final invoice = _invoices[index];
                                      return _buildInvoiceRow(invoice);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(Map<String, dynamic> invoice) {
    final invoiceNumber = invoice['invoice_number'] ?? '';
    final partyName = invoice['party']?['name'] ?? 'Unknown Vendor';
    final invoiceDate = invoice['invoice_date'] ?? '';
    final totalAmount = (invoice['total_amount'] is num)
        ? (invoice['total_amount'] as num).toDouble()
        : 0.0;
    final paymentStatus = invoice['payment_status'] ?? 'unpaid';

    Color statusColor;
    String statusText;
    switch (paymentStatus) {
      case 'paid':
        statusColor = AppColors.success;
        statusText = 'Paid';
        break;
      case 'partial':
        statusColor = AppColors.warning;
        statusText = 'Partial';
        break;
      case 'unpaid':
      default:
        statusColor = Colors.red;
        statusText = 'Unpaid';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(invoiceNumber, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Text(partyName, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Text(invoiceDate, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  onPressed: () {
                    // TODO: View invoice details
                  },
                  tooltip: 'View',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Invoice'),
                        content: const Text(
                            'Are you sure you want to delete this invoice?'),
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

                    if (confirm == true && mounted) {
                      final orgProvider = Provider.of<OrganizationProvider>(
                          context,
                          listen: false);
                      try {
                        await _purchaseInvoiceService.deletePurchaseInvoice(
                          invoice['id'],
                          orgProvider.selectedOrganization!.id,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadInvoices();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting invoice: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                  Text(
                    value,
                    style: AppTextStyles.h2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
