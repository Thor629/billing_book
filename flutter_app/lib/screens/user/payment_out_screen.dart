import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/payment_out_model.dart';
import '../../services/payment_out_service.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Payment Out',
                  style: AppTextStyles.h2,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_view),
                  tooltip: 'View',
                ),
              ],
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // Search
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) => _loadPayments(),
                  ),
                ),
                const SizedBox(width: 16),

                // Date Filter
                DropdownButton<String>(
                  value: _selectedDateFilter,
                  items: [
                    'Last 7 Days',
                    'Last 30 Days',
                    'Last 365 Days',
                  ]
                      .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text(filter),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDateFilter = value!);
                    _loadPayments();
                  },
                ),

                const Spacer(),

                // Create Button
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
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _payments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Transactions Matching the current filter',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Date',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Payment Number',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Party Name',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Amount',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(width: 50),
                                  ],
                                ),
                              ),

                              // Table Rows
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _payments.length,
                                itemBuilder: (context, index) {
                                  final payment = _payments[index];
                                  return _buildPaymentRow(payment);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(PaymentOut payment) {
    final date = DateTime.parse(payment.paymentDate);
    final formattedDate = DateFormat('dd MMM yyyy').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              formattedDate,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              payment.paymentNumber,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              payment.party?.name ?? 'N/A',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${payment.amount.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 50,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleAction(value, payment),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, PaymentOut payment) async {
    if (action == 'delete') {
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
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
