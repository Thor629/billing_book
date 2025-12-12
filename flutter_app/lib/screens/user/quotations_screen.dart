import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/quotation_model.dart';
import '../../services/quotation_service.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/unified_data_table.dart';
import 'create_quotation_screen.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  final QuotationService _quotationService = QuotationService();
  String _selectedFilter = 'Last 365 Days';
  String _selectedStatusFilter = 'all';
  bool _isLoading = true;
  List<Quotation> _quotations = [];
  Map<String, dynamic> _summary = {
    'total_quotations': 0,
    'open': 0,
    'accepted': 0,
    'total_amount': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<void> _loadQuotations() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _quotationService.getQuotations(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _selectedFilter,
        statusFilter: _selectedStatusFilter,
      );
      setState(() {
        _quotations = result['quotations'] as List<Quotation>;
        _summary = result['summary'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quotations: $e')),
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
                Text('Quotation / Estimate', style: AppTextStyles.h1),
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

            // Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Quotations',
                    value: '${_summary['total_quotations'] ?? 0}',
                    icon: Icons.description_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Open',
                    value: '${_summary['open'] ?? 0}',
                    icon: Icons.pending_outlined,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Accepted',
                    value: '${_summary['accepted'] ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Amount',
                    value: '₹${_formatAmount(_summary['total_amount'])}',
                    icon: Icons.currency_rupee,
                    color: Colors.purple,
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
                            _loadQuotations();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Status Filter
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 18),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedStatusFilter,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: 'open',
                            child: Text('Open'),
                          ),
                          DropdownMenuItem(
                            value: 'accepted',
                            child: Text('Accepted'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Rejected'),
                          ),
                          DropdownMenuItem(
                            value: 'expired',
                            child: Text('Expired'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedStatusFilter = value);
                            _loadQuotations();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Create Quotation Button
                ElevatedButton.icon(
                  onPressed: () async {
                    await _showCreateQuotationDialog();
                    _loadQuotations();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Quotation'),
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
                  : _quotations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No quotations found',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first quotation',
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
                            DataColumn(label: TableHeader('Quotation Number')),
                            DataColumn(label: TableHeader('Party Name')),
                            DataColumn(label: TableHeader('Due In')),
                            DataColumn(label: TableHeader('Amount')),
                            DataColumn(label: TableHeader('Status')),
                            DataColumn(label: TableHeader('Actions')),
                          ],
                          rows: _buildQuotationRows(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildQuotationRows() {
    return _quotations.map((quotation) {
      return DataRow(
        cells: [
          DataCell(TableCellText(_formatDate(quotation.quotationDate))),
          DataCell(TableCellText(quotation.quotationNumber)),
          DataCell(TableCellText(quotation.party?.name ?? 'N/A')),
          DataCell(TableCellText(quotation.dueInText)),
          DataCell(TableCellText(
            '₹${_formatAmount(quotation.totalAmount)}',
            style: AppTextStyles.currency,
          )),
          DataCell(TableStatusBadge(quotation.status)),
          DataCell(
            TableActionButtons(
              onView: () => _viewQuotation(quotation),
              onEdit: () => _editQuotation(quotation),
              onDelete: () => _deleteQuotation(quotation),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildQuotationRowsOld() {
    return _quotations.map((quotation) {
      final isExpired = quotation.isExpired;

      return DataRow(
        cells: [
          DataCell(Text(_formatDate(quotation.quotationDate))),
          DataCell(Text(quotation.quotationNumber)),
          DataCell(Text(quotation.party?.name ?? 'N/A')),
          DataCell(
            Text(
              quotation.dueInText,
              style: TextStyle(
                color: isExpired ? Colors.red : null,
              ),
            ),
          ),
          DataCell(Text('₹${_formatAmount(quotation.totalAmount)}')),
          DataCell(_buildStatusBadge(quotation.status)),
          DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.content_copy, size: 18),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'convert',
                  child: Row(
                    children: [
                      Icon(Icons.transform, size: 18),
                      SizedBox(width: 8),
                      Text('Convert to Invoice'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleQuotationAction(value, quotation),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'open':
        color = Colors.blue;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'expired':
        color = Colors.grey;
        break;
      case 'converted':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
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

  void _handleQuotationAction(String action, Quotation quotation) {
    switch (action) {
      case 'view':
        _viewQuotation(quotation);
        break;
      case 'edit':
        _editQuotation(quotation);
        break;
      case 'duplicate':
        _duplicateQuotation(quotation);
        break;
      case 'delete':
        _deleteQuotation(quotation);
        break;
      case 'convert':
        _convertToInvoice(quotation);
        break;
    }
  }

  void _viewQuotation(Quotation quotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quotation ${quotation.quotationNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Party', quotation.party?.name ?? 'N/A'),
              _buildDetailRow('Date', _formatDate(quotation.quotationDate)),
              _buildDetailRow(
                  'Valid Until', _formatDate(quotation.validityDate)),
              _buildDetailRow(
                  'Amount', '₹${quotation.totalAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Status', quotation.status.toUpperCase()),
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

  void _editQuotation(Quotation quotation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuotationScreen(
          quotationId: quotation.id,
          quotationData: {
            'quotation_number': quotation.quotationNumber,
            'party_id': quotation.party?.id,
            'party_name': quotation.party?.name,
            'quotation_date': quotation.quotationDate.toIso8601String(),
            'validity_date': quotation.validityDate.toIso8601String(),
            'total_amount': quotation.totalAmount,
            'status': quotation.status,
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadQuotations();
      }
    });
  }

  void _duplicateQuotation(Quotation quotation) {
    // Navigate to create screen with duplicated data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicating quotation ${quotation.quotationNumber}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateQuotationScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadQuotations();
      }
    });
  }

  void _convertToInvoice(Quotation quotation) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Convert to invoice feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteQuotation(Quotation quotation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quotation'),
        content: Text(
            'Are you sure you want to delete quotation ${quotation.quotationNumber}?'),
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

    if (confirm == true && quotation.id != null) {
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization == null) return;

      try {
        await _quotationService.deleteQuotation(
          quotation.id!,
          orgProvider.selectedOrganization!.id,
        );
        _loadQuotations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quotation deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting quotation: $e')),
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

  Future<void> _showCreateQuotationDialog() async {
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
                    child: const CreateQuotationScreen(),
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
