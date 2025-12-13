import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/purchase_order_model.dart';
import '../../providers/organization_provider.dart';
import '../../services/purchase_order_service.dart';
import '../../widgets/unified_data_table.dart';
import 'create_purchase_order_screen.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  final PurchaseOrderService _service = PurchaseOrderService();
  List<PurchaseOrder> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _dateFilter = 'last_365_days';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isLoading = true);

    try {
      final orders = await _service.getPurchaseOrders(
        orgProvider.selectedOrganization!.id,
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      setState(() {
        _orders = orders.map((o) => PurchaseOrder.fromJson(o)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Text(
            'Purchase Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePurchaseOrderScreen(),
                ),
              );
              if (result == true) {
                _loadOrders();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Create Purchase Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Date Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _dateFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'last_365_days',
                      child: Text('Last 365 Days'),
                    ),
                    DropdownMenuItem(
                      value: 'this_month',
                      child: Text('This Month'),
                    ),
                    DropdownMenuItem(
                      value: 'last_month',
                      child: Text('Last Month'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _dateFilter = value!);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedFilter,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Show All Orders')),
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
                DropdownMenuItem(value: 'sent', child: Text('Sent')),
                DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                DropdownMenuItem(value: 'received', child: Text('Received')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                _loadOrders();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Transactions Matching the current filter',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: UnifiedDataTable(
        columns: const [
          DataColumn(label: TableHeader('Date')),
          DataColumn(label: TableHeader('Purchase Order Number')),
          DataColumn(label: TableHeader('Party Name')),
          DataColumn(label: TableHeader('Valid Till')),
          DataColumn(label: TableHeader('Amount')),
          DataColumn(label: TableHeader('Status')),
          DataColumn(label: TableHeader('Actions')),
        ],
        rows: _orders.map((order) {
          return DataRow(
            cells: [
              DataCell(
                TableCellText(
                  DateFormat('dd MMM yyyy').format(order.orderDate),
                ),
              ),
              DataCell(TableCellText(order.orderNumber)),
              DataCell(TableCellText(order.partyName ?? 'N/A')),
              DataCell(
                TableCellText(
                  order.expectedDeliveryDate != null
                      ? DateFormat('dd MMM yyyy')
                          .format(order.expectedDeliveryDate!)
                      : '-',
                ),
              ),
              DataCell(TableAmount(amount: order.totalAmount)),
              DataCell(TableStatusBadge(order.status)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Convert to Invoice button
                    if (order.status != 'converted' &&
                        !(order.convertedToInvoice ?? false))
                      ElevatedButton.icon(
                        onPressed: () => _convertToInvoice(order),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Convert to Invoice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Converted',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreatePurchaseOrderScreen(orderId: order.id),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _loadOrders();
                          }
                        });
                      },
                      tooltip: 'Edit',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _convertToInvoice(PurchaseOrder order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to Purchase Invoice'),
        content: Text(
          'Are you sure you want to convert Purchase Order ${order.orderNumber} to a Purchase Invoice?\n\n'
          'This will:\n'
          '• Create a new purchase invoice\n'
          '• Update stock quantities\n'
          '• Update bank account balance (if payment made)\n'
          '• Mark this order as converted',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Convert'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      final result = await _service.convertToInvoice(order.id);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success dialog with option to view invoice
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase order converted successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Invoice Number: ${result['data']['invoice_number']}'),
                SizedBox(height: 16),
                Text(
                  'The invoice has been created and is now available in Purchase Invoices.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadOrders();
                },
                child: Text('Stay Here'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate to Purchase Invoices screen (index 14 in dashboard)
                  Navigator.pushReplacementNamed(context, '/user-dashboard',
                      arguments: {'screen': 14});
                },
                icon: Icon(Icons.receipt_long),
                label: Text('View Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        );

        // Reload orders
        _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error converting order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
