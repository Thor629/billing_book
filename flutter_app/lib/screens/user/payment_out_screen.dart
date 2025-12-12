import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/payment_out_model.dart';
import '../../services/payment_out_service.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/unified_data_table.dart';
import 'create_payment_out_screen.dart';

class PaymentOutScreen extends StatefulWidget {
  const PaymentOutScreen({super.key});

  @override
  State<PaymentOutScreen> createState() => _PaymentOutScreenState();
}

class _PaymentOutScreenState extends State<PaymentOutScreen> {
  final PaymentOutService _paymentOutService = PaymentOutService();
  List<PaymentOut> _payments = [];
  bool _isLoading = false;
  String _selectedDateFilter = 'Last 365 Days';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _paymentOutService.getPaymentOuts(
        organizationId: orgProvider.selectedOrganization!.id.toString(),
        dateFilter: _selectedDateFilter,
        search: _searchController.text,
      );

      setState(() {
        _payments = result['payments'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    }
  }

  int get _totalPayments => _payments.length;

  double get _totalAmount {
    double total = 0;
    for (var payment in _payments) {
      total += payment.amount;
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
                Text('Payment Out', style: AppTextStyles.h1),
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
                      onPressed: _loadPayments,
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
                    title: 'Total Paid Out',
                    value: '₹${_totalAmount.toStringAsFixed(2)}',
                    icon: Icons.currency_rupee,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Payments',
                    value: _totalPayments.toString(),
                    icon: Icons.payment,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'This Month',
                    value: _getThisMonthCount().toString(),
                    icon: Icons.calendar_month,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'This Week',
                    value: _getThisWeekCount().toString(),
                    icon: Icons.date_range,
                    color: Colors.green,
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
                        value: _selectedDateFilter,
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
                            setState(() => _selectedDateFilter = value);
                            _loadPayments();
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search payments...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) => _loadPayments(),
                  ),
                ),
                const Spacer(),

                // Create Payment Out Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePaymentOutScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadPayments();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Payment Out'),
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
                  : _payments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No payments found',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first payment out to get started',
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
                                          const CreatePaymentOutScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadPayments();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Payment'),
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
                            DataColumn(label: TableHeader('Date')),
                            DataColumn(label: TableHeader('Payment No.')),
                            DataColumn(label: TableHeader('Party Name')),
                            DataColumn(label: TableHeader('Payment Method')),
                            DataColumn(label: TableHeader('Amount')),
                            DataColumn(label: TableHeader('Actions')),
                          ],
                          rows: _buildPaymentRows(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildPaymentRows() {
    return _payments.map((payment) {
      final date = DateTime.parse(payment.paymentDate);
      final formattedDate = DateFormat('dd MMM yyyy').format(date);

      return DataRow(
        cells: [
          DataCell(TableCellText(formattedDate)),
          DataCell(TableCellText(payment.paymentNumber)),
          DataCell(TableCellText(payment.party?.name ?? 'N/A')),
          DataCell(TableCellText(payment.paymentMethod)),
          DataCell(TableAmount(amount: payment.amount)),
          DataCell(
            TableActionButtons(
              onView: () => _viewPayment(payment),
              onEdit: () => _editPayment(payment),
              onDelete: () => _deletePayment(payment),
            ),
          ),
        ],
      );
    }).toList();
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    return _payments.where((p) {
      final date = DateTime.parse(p.paymentDate);
      return date.month == now.month && date.year == now.year;
    }).length;
  }

  int _getThisWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _payments.where((p) {
      final date = DateTime.parse(p.paymentDate);
      return date.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).length;
  }

  void _viewPayment(PaymentOut payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment ${payment.paymentNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Party', payment.party?.name ?? 'N/A'),
              _buildDetailRow('Date', payment.paymentDate),
              _buildDetailRow(
                  'Amount', '₹${payment.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Payment Method', payment.paymentMethod),
              if (payment.notes != null && payment.notes!.isNotEmpty)
                _buildDetailRow('Notes', payment.notes!),
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

  void _editPayment(PaymentOut payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePaymentOutScreen(
          paymentId: payment.id,
          paymentData: {
            'payment_number': payment.paymentNumber,
            'party_id': payment.party?.id,
            'amount': payment.amount,
            'payment_method': payment.paymentMethod,
            'payment_date': payment.paymentDate,
            'reference_number': payment.referenceNumber,
            'notes': payment.notes,
            'bank_account_id': payment.bankAccountId,
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadPayments();
      }
    });
  }

  Future<void> _deletePayment(PaymentOut payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment?'),
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
      try {
        final orgProvider =
            Provider.of<OrganizationProvider>(context, listen: false);
        await _paymentOutService.deletePaymentOut(
          payment.id!,
          orgProvider.selectedOrganization!.id.toString(),
        );
        _loadPayments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting payment: $e'),
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
        const PopupMenuItem(value: 'payments', child: Text('Payments Report')),
        const PopupMenuItem(value: 'party', child: Text('Party Report')),
      ],
      onSelected: (value) {},
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
