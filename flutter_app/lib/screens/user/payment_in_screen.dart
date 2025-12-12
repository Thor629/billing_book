import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/payment_in_model.dart';
import '../../services/payment_in_service.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/unified_data_table.dart';
import 'create_payment_in_screen.dart';

class PaymentInScreen extends StatefulWidget {
  const PaymentInScreen({super.key});

  @override
  State<PaymentInScreen> createState() => _PaymentInScreenState();
}

class _PaymentInScreenState extends State<PaymentInScreen> {
  final PaymentInService _paymentService = PaymentInService();
  String _selectedFilter = 'Last 365 Days';
  bool _isLoading = true;
  List<PaymentIn> _payments = [];
  Map<String, dynamic> _summary = {
    'total_received': 0.0,
    'total_count': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _paymentService.getPayments(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _selectedFilter,
      );
      setState(() {
        _payments = result['payments'] as List<PaymentIn>;
        _summary = result['summary'];
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
                Row(
                  children: [
                    Text('Payment In', style: AppTextStyles.h1),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Payment Received',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
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

            // Action Bar
            Row(
              children: [
                // Search
                Container(
                  width: 250,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

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
                            _loadPayments();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Create Payment In Button
                ElevatedButton.icon(
                  onPressed: _showCreatePaymentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Payment In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
                                'Record your first payment',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : UnifiedDataTable(
                          columns: const [
                            DataColumn(label: TableHeader('Date')),
                            DataColumn(label: TableHeader('Payment Number')),
                            DataColumn(label: TableHeader('Party Name')),
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
      return DataRow(
        cells: [
          DataCell(TableCellText(_formatDate(payment.paymentDate))),
          DataCell(TableCellText(payment.paymentNumber)),
          DataCell(TableCellText(payment.party?.name ?? 'N/A')),
          DataCell(TableCellText(
            '₹${payment.amount.toStringAsFixed(2)}',
            style: AppTextStyles.currency,
          )),
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  void _handlePaymentAction(String action, PaymentIn payment) {
    switch (action) {
      case 'view':
        _viewPayment(payment);
        break;
      case 'edit':
        _editPayment(payment);
        break;
      case 'duplicate':
        _duplicatePayment(payment);
        break;
      case 'delete':
        _deletePayment(payment);
        break;
    }
  }

  void _viewPayment(PaymentIn payment) {
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
              _buildDetailRow('Date', _formatDate(payment.paymentDate)),
              _buildDetailRow(
                  'Amount', '₹${payment.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Payment Mode', payment.paymentMode),
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

  Future<void> _editPayment(PaymentIn payment) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreatePaymentInScreen(
        paymentId: payment.id,
        paymentData: {
          'payment_number': payment.paymentNumber,
          'party_id': payment.party?.id,
          'party_name': payment.party?.name,
          'amount': payment.amount,
          'payment_mode': payment.paymentMode,
          'payment_date': payment.paymentDate.toIso8601String(),
          'notes': payment.notes,
        },
      ),
    );

    if (result == true) {
      _loadPayments();
    }
  }

  Future<void> _duplicatePayment(PaymentIn payment) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicating payment ${payment.paymentNumber}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreatePaymentInScreen(),
    );
    if (result == true) {
      _loadPayments();
    }
  }

  Future<void> _deletePayment(PaymentIn payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
            'Are you sure you want to delete payment ${payment.paymentNumber}?'),
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

    if (confirm == true && payment.id != null) {
      try {
        await _paymentService.deletePayment(payment.id!);
        _loadPayments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting payment: $e')),
          );
        }
      }
    }
  }

  Future<void> _showCreatePaymentDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreatePaymentInScreen(),
    );

    // Reload payments if a payment was successfully created
    if (result == true) {
      _loadPayments();
    }
  }
}
