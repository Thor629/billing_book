import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/sales_invoice_model.dart';
import '../../services/sales_invoice_service.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/unified_data_table.dart';
import 'create_sales_invoice_screen.dart';

class SalesInvoicesScreen extends StatefulWidget {
  const SalesInvoicesScreen({super.key});

  @override
  State<SalesInvoicesScreen> createState() => _SalesInvoicesScreenState();
}

class _SalesInvoicesScreenState extends State<SalesInvoicesScreen> {
  final SalesInvoiceService _invoiceService = SalesInvoiceService();
  String _selectedFilter = 'Last 365 Days';
  bool _isLoading = true;
  List<SalesInvoice> _invoices = [];
  Map<String, dynamic> _summary = {
    'total_sales': 0.0,
    'paid': 0.0,
    'unpaid': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _invoiceService.getInvoices(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _selectedFilter,
      );
      setState(() {
        _invoices = result['invoices'] as List<SalesInvoice>;
        _summary = result['summary'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoices: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = Provider.of<OrganizationProvider>(context);

    if (orgProvider.selectedOrganization == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please select an organization first'),
        ),
      );
    }

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
                Text('Sales Invoices', style: AppTextStyles.h1),
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
                      icon: const Icon(Icons.view_module_outlined),
                      onPressed: () {},
                      tooltip: 'Change View',
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
                    title: 'Total Sales',
                    value: '₹${_formatAmount(_summary['total_sales'])}',
                    icon: Icons.currency_rupee,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Paid',
                    value: '₹${_formatAmount(_summary['paid'])}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Unpaid',
                    value: '₹${_formatAmount(_summary['unpaid'])}',
                    icon: Icons.warning_amber_outlined,
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
                  child: Row(
                    children: [
                      const Icon(Icons.checklist, size: 18),
                      const SizedBox(width: 8),
                      const Text('Bulk Actions'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                const Spacer(),

                // Create Sales Invoice Button
                ElevatedButton.icon(
                  onPressed: () async {
                    await _showCreateInvoiceDialog();
                    _loadInvoices();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Sales Invoice'),
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
                                'No invoices found',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first sales invoice',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
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
      final isPaid = invoice.paymentStatus == 'paid';

      return DataRow(
        cells: [
          DataCell(TableCellText(invoice.fullInvoiceNumber)),
          DataCell(TableCellText(invoice.party?.name ?? 'POS')),
          DataCell(TableCellText(_formatDate(invoice.invoiceDate))),
          DataCell(TableCellText(
            '₹${_formatAmount(invoice.totalAmount)}',
            style: AppTextStyles.currency,
          )),
          DataCell(TableStatusBadge(isPaid ? 'Paid' : 'Unpaid')),
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

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is num) return amount.toStringAsFixed(2);
    if (amount is String) {
      final parsed = double.tryParse(amount);
      return parsed?.toStringAsFixed(2) ?? '0.00';
    }
    return '0.00';
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _viewInvoice(SalesInvoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice ${invoice.fullInvoiceNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Party', invoice.party?.name ?? 'POS'),
              _buildDetailRow('Date', _formatDate(invoice.invoiceDate)),
              _buildDetailRow('Due Date', _formatDate(invoice.dueDate)),
              _buildDetailRow(
                  'Amount', '₹${_formatAmount(invoice.totalAmount)}'),
              _buildDetailRow(
                  'Paid', '₹${_formatAmount(invoice.amountReceived)}'),
              _buildDetailRow(
                  'Balance', '₹${_formatAmount(invoice.balanceAmount)}'),
              _buildDetailRow('Status', invoice.paymentStatus.toUpperCase()),
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

  void _editInvoice(SalesInvoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSalesInvoiceScreen(
          invoiceId: invoice.id,
          invoiceData: {
            'invoice_number': invoice.fullInvoiceNumber,
            'party_id': invoice.party?.id,
            'party_name': invoice.party?.name,
            'invoice_date': invoice.invoiceDate.toIso8601String(),
            'due_date': invoice.dueDate.toIso8601String(),
            'total_amount': invoice.totalAmount,
            'amount_received': invoice.amountReceived,
            'balance_amount': invoice.balanceAmount,
            'payment_status': invoice.paymentStatus,
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadInvoices();
      }
    });
  }

  Future<void> _deleteInvoice(SalesInvoice invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
            'Are you sure you want to delete invoice ${invoice.fullInvoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && invoice.id != null) {
      try {
        await _invoiceService.deleteInvoice(invoice.id!);
        _loadInvoices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting invoice: $e')),
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
            Column(
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
        const PopupMenuItem(value: 'sales', child: Text('Sales Report')),
        const PopupMenuItem(value: 'gst', child: Text('GST Report')),
        const PopupMenuItem(value: 'party', child: Text('Party Report')),
      ],
      onSelected: (value) {},
    );
  }

  Future<void> _showCreateInvoiceDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.95,
                  constraints: const BoxConstraints(
                    maxWidth: 1400,
                    maxHeight: 900,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: const CreateSalesInvoiceScreen(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
