import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/organization_provider.dart';
import '../../services/purchase_invoice_service.dart';
import '../../widgets/unified_data_table.dart';
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
  String _selectedFilter = 'Last 365 Days';

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

  double get _totalAmount {
    double total = 0;
    for (var inv in _invoices) {
      if (inv['total_amount'] is num) {
        total += (inv['total_amount'] as num).toDouble();
      }
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
                Text('Purchase Invoices', style: AppTextStyles.h1),
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
                      onPressed: _loadInvoices,
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
                    title: 'Total Purchases',
                    value: '₹${_totalAmount.toStringAsFixed(2)}',
                    icon: Icons.currency_rupee,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Invoices',
                    value: _totalInvoices.toString(),
                    icon: Icons.receipt_long,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Paid',
                    value: _paidInvoices.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pending',
                    value: _pendingInvoices.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.red,
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
                            _loadInvoices();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Bulk Actions
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.checklist, size: 18),
                      SizedBox(width: 8),
                      Text('Bulk Actions'),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                const Spacer(),

                // Create Purchase Invoice Button
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
                  label: const Text('Create Purchase Invoice'),
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
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                DataColumn(label: TableHeader('Invoice #')),
                                DataColumn(label: TableHeader('Vendor')),
                                DataColumn(label: TableHeader('Date')),
                                DataColumn(label: TableHeader('Amount')),
                                DataColumn(label: TableHeader('Status')),
                                DataColumn(label: TableHeader('Actions')),
                              ],
                              rows: _buildInvoiceRows(),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildInvoiceRows() {
    return _invoices.map((invoice) {
      final invoiceNumber = invoice['invoice_number'] ?? '';
      final partyName = invoice['party']?['name'] ?? 'Unknown Vendor';
      final invoiceDate = invoice['invoice_date'] ?? '';
      final totalAmount = (invoice['total_amount'] is num)
          ? (invoice['total_amount'] as num).toDouble()
          : 0.0;
      final paymentStatus = invoice['payment_status'] ?? 'unpaid';

      String statusText;
      switch (paymentStatus) {
        case 'paid':
          statusText = 'Paid';
          break;
        case 'partial':
          statusText = 'Partial';
          break;
        case 'unpaid':
        default:
          statusText = 'Unpaid';
      }

      return DataRow(
        cells: [
          DataCell(TableCellText(invoiceNumber)),
          DataCell(TableCellText(partyName)),
          DataCell(TableCellText(invoiceDate)),
          DataCell(TableAmount(amount: totalAmount)),
          DataCell(TableStatusBadge(statusText)),
          DataCell(
            TableActionButtons(
              onView: () => _viewInvoice(invoice),
              onEdit: () => _editInvoice(invoice),
              onDelete: () => _deleteInvoice(invoice),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _viewInvoice(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice ${invoice['invoice_number'] ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Vendor', invoice['party']?['name'] ?? 'N/A'),
              _buildDetailRow('Date', invoice['invoice_date'] ?? 'N/A'),
              _buildDetailRow('Due Date', invoice['due_date'] ?? 'N/A'),
              _buildDetailRow(
                'Amount',
                '₹${((invoice['total_amount'] is num) ? (invoice['total_amount'] as num).toDouble() : 0.0).toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Status',
                (invoice['payment_status'] ?? 'unpaid')
                    .toString()
                    .toUpperCase(),
              ),
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
            width: 100,
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

  void _editInvoice(Map<String, dynamic> invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePurchaseInvoiceScreen(
          invoiceId: invoice['id'],
          invoiceData: {
            'invoice_number': invoice['invoice_number'],
            'party_id': invoice['party']?['id'],
            'party_name': invoice['party']?['name'],
            'invoice_date': invoice['invoice_date'],
            'due_date': invoice['due_date'],
            'total_amount': invoice['total_amount'],
            'payment_status': invoice['payment_status'],
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadInvoices();
      }
    });
  }

  Future<void> _deleteInvoice(Map<String, dynamic> invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
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
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);
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
        const PopupMenuItem(value: 'purchase', child: Text('Purchase Report')),
        const PopupMenuItem(value: 'gst', child: Text('GST Report')),
        const PopupMenuItem(value: 'vendor', child: Text('Vendor Report')),
      ],
      onSelected: (value) {},
    );
  }
}
