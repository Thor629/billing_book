import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/sales_invoice_model.dart';
import '../../services/sales_invoice_service.dart';
import '../../providers/organization_provider.dart';
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
                      onPressed: () {},
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
                    value:
                        '₹${_summary['total_sales']?.toStringAsFixed(2) ?? '0.00'}',
                    icon: Icons.currency_rupee,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Paid',
                    value: '₹${_summary['paid']?.toStringAsFixed(2) ?? '0.00'}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Unpaid',
                    value:
                        '₹${_summary['unpaid']?.toStringAsFixed(2) ?? '0.00'}',
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
                      : Card(
                          child: SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width - 300,
                                  ),
                                  child: DataTable(
                                    showCheckboxColumn: true,
                                    columnSpacing: 40,
                                    columns: const [
                                      DataColumn(label: Text('Date')),
                                      DataColumn(label: Text('Invoice Number')),
                                      DataColumn(label: Text('Party Name')),
                                      DataColumn(label: Text('Due In')),
                                      DataColumn(label: Text('Amount')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: _buildInvoiceRows(),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
      final isOverdue = invoice.isOverdue;

      return DataRow(
        cells: [
          DataCell(Text(_formatDate(invoice.invoiceDate))),
          DataCell(Text(invoice.fullInvoiceNumber)),
          DataCell(Text(invoice.party?.name ?? 'N/A')),
          DataCell(
            Text(
              invoice.dueInText,
              style: TextStyle(
                color: isOverdue ? Colors.red : null,
              ),
            ),
          ),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${invoice.totalAmount.toStringAsFixed(2)}'),
                if (invoice.balanceAmount > 0)
                  Text(
                    '(₹${invoice.balanceAmount.toStringAsFixed(2)} unpaid)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                invoice.paymentStatus.toUpperCase(),
                style: TextStyle(
                  color: isPaid ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (value) => _handleInvoiceAction(value, invoice),
            ),
          ),
        ],
      );
    }).toList();
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

  void _handleInvoiceAction(String action, SalesInvoice invoice) {
    switch (action) {
      case 'view':
        // TODO: Implement view invoice
        break;
      case 'edit':
        // TODO: Implement edit invoice
        break;
      case 'delete':
        _deleteInvoice(invoice);
        break;
    }
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
