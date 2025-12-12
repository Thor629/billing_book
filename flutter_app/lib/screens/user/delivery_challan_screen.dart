import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/delivery_challan_model.dart';
import '../../services/delivery_challan_service.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/unified_data_table.dart';
import 'create_delivery_challan_screen.dart';

class DeliveryChallanScreen extends StatefulWidget {
  const DeliveryChallanScreen({super.key});

  @override
  State<DeliveryChallanScreen> createState() => _DeliveryChallanScreenState();
}

class _DeliveryChallanScreenState extends State<DeliveryChallanScreen> {
  final DeliveryChallanService _challanService = DeliveryChallanService();
  List<DeliveryChallan> _challans = [];
  bool _isLoading = true;
  String _dateFilter = 'Last 365 Days';
  String _statusFilter = 'Show Open Challans';
  String _searchQuery = '';
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadChallans();
  }

  Future<void> _loadChallans() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _challanService.getDeliveryChallans(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _dateFilter,
        status: _statusFilter,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _challans = result['challans'];
        _summary = result['summary'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading delivery challans: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Delivery Challan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.grid_view),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                // Search
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _loadChallans();
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Date Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _dateFilter,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: [
                      'Last 7 Days',
                      'Last 30 Days',
                      'Last 90 Days',
                      'Last 365 Days'
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
                      if (value != null) {
                        setState(() => _dateFilter = value);
                        _loadChallans();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Status Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: ['Show Open Challans', 'Show All']
                        .map((filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _statusFilter = value);
                        _loadChallans();
                      }
                    },
                  ),
                ),
                const Spacer(),

                // Create Button
                ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const CreateDeliveryChallanScreen(),
                    );
                    if (result == true) {
                      _loadChallans();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Create Delivery Challan'),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _challans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Transactions Matching the current filter',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : UnifiedDataTable(
                        columns: const [
                          DataColumn(label: TableHeader('Date')),
                          DataColumn(
                              label: TableHeader('Delivery Challan Number')),
                          DataColumn(label: TableHeader('Party Name')),
                          DataColumn(label: TableHeader('Amount')),
                          DataColumn(label: TableHeader('Status')),
                          DataColumn(label: TableHeader('Actions')),
                        ],
                        rows: _challans
                            .map(
                              (challan) => DataRow(
                                cells: [
                                  DataCell(TableCellText(
                                    DateFormat('dd MMM yyyy')
                                        .format(challan.challanDate),
                                  )),
                                  DataCell(
                                      TableCellText(challan.challanNumber)),
                                  DataCell(TableCellText(
                                      challan.party?.name ?? '-')),
                                  DataCell(
                                      TableAmount(amount: challan.totalAmount)),
                                  DataCell(TableStatusBadge(challan.status)),
                                  DataCell(
                                    TableActionButtons(
                                      onView: () => _viewChallan(challan),
                                      onEdit: () => _editChallan(challan),
                                      onDelete: () => _deleteChallan(challan),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }

  void _viewChallan(DeliveryChallan challan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery Challan ${challan.challanNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Party', challan.party?.name ?? 'N/A'),
              _buildDetailRow(
                'Date',
                DateFormat('dd MMM yyyy').format(challan.challanDate),
              ),
              _buildDetailRow(
                'Amount',
                '₹${challan.totalAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Status', challan.status),
              if (challan.notes != null && challan.notes!.isNotEmpty)
                _buildDetailRow('Notes', challan.notes!),
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

  Future<void> _editChallan(DeliveryChallan challan) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateDeliveryChallanScreen(
        challanId: challan.id,
        challanData: {
          'challan_number': challan.challanNumber,
          'party_id': challan.party?.id,
          'party_name': challan.party?.name,
          'challan_date': challan.challanDate.toIso8601String(),
          'total_amount': challan.totalAmount,
          'status': challan.status,
          'notes': challan.notes,
        },
      ),
    );

    if (result == true) {
      _loadChallans();
    }
  }

  Future<void> _deleteChallan(DeliveryChallan challan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Delivery Challan'),
        content: Text(
          'Are you sure you want to delete challan ${challan.challanNumber}?',
        ),
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
        await _challanService.deleteDeliveryChallan(challan.id!);
        _loadChallans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delivery challan deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting challan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
