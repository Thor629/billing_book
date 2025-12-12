import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/credit_note_model.dart';
import '../../services/credit_note_service.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/unified_data_table.dart';
import 'create_credit_note_screen.dart';

class CreditNoteScreen extends StatefulWidget {
  const CreditNoteScreen({super.key});

  @override
  State<CreditNoteScreen> createState() => _CreditNoteScreenState();
}

class _CreditNoteScreenState extends State<CreditNoteScreen> {
  final CreditNoteService _creditNoteService = CreditNoteService();
  String _selectedFilter = 'Last 365 Days';
  bool _isLoading = true;
  List<CreditNote> _creditNotes = [];

  @override
  void initState() {
    super.initState();
    _loadCreditNotes();
  }

  Future<void> _loadCreditNotes() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _creditNoteService.getCreditNotes(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _selectedFilter,
      );
      setState(() {
        _creditNotes = result['credit_notes'] as List<CreditNote>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading credit notes: $e')),
        );
      }
    }
  }

  Future<void> _deleteCreditNote(int id) async {
    try {
      await _creditNoteService.deleteCreditNote(id);
      _loadCreditNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit note deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting credit note: $e')),
        );
      }
    }
  }

  void _viewCreditNote(CreditNote creditNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Credit Note ${creditNote.creditNoteNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', creditNote.partyName ?? 'N/A'),
              _buildDetailRow(
                'Date',
                '${creditNote.creditNoteDate.day.toString().padLeft(2, '0')} ${_getMonthName(creditNote.creditNoteDate.month)} ${creditNote.creditNoteDate.year}',
              ),
              _buildDetailRow('Invoice', creditNote.invoiceNumber ?? 'N/A'),
              _buildDetailRow(
                'Amount',
                '₹${creditNote.totalAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Amount Received',
                '₹${creditNote.amountReceived.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Payment Mode', creditNote.paymentMode ?? 'N/A'),
              _buildDetailRow('Status', creditNote.status),
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

  void _editCreditNote(CreditNote creditNote) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateCreditNoteScreen(
        creditNoteId: creditNote.id,
        creditNoteData: {
          'credit_note_number': creditNote.creditNoteNumber,
          'party_id': creditNote.partyId,
          'party_name': creditNote.partyName,
          'invoice_number': creditNote.invoiceNumber,
          'credit_note_date': creditNote.creditNoteDate.toIso8601String(),
          'total_amount': creditNote.totalAmount,
          'amount_received': creditNote.amountReceived,
          'payment_mode': creditNote.paymentMode,
          'status': creditNote.status,
        },
      ),
    );

    if (result == true) {
      _loadCreditNotes();
    }
  }

  void _showDeleteDialog(CreditNote creditNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credit Note'),
        content: Text(
            'Are you sure you want to delete credit note #${creditNote.creditNoteNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCreditNote(creditNote.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = Provider.of<OrganizationProvider>(context);

    if (orgProvider.selectedOrganization == null) {
      return const Center(
        child: Text('Please select an organization first'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Credit Note', style: AppTextStyles.h1),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const CreateCreditNoteScreen(),
                  );
                  if (result == true) {
                    _loadCreditNotes();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Create Credit Note'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                        value: 'Last 7 Days', child: Text('Last 7 Days')),
                    DropdownMenuItem(
                        value: 'Last 30 Days', child: Text('Last 30 Days')),
                    DropdownMenuItem(
                        value: 'Last 365 Days', child: Text('Last 365 Days')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFilter = value);
                      _loadCreditNotes();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _creditNotes.isEmpty
                    ? const Center(child: Text('No credit notes found'))
                    : UnifiedDataTable(
                        columns: const [
                          DataColumn(label: TableHeader('Date')),
                          DataColumn(label: TableHeader('Credit Note Number')),
                          DataColumn(label: TableHeader('Party Name')),
                          DataColumn(label: TableHeader('Invoice No')),
                          DataColumn(label: TableHeader('Amount')),
                          DataColumn(label: TableHeader('Amount Received')),
                          DataColumn(label: TableHeader('Payment Mode')),
                          DataColumn(label: TableHeader('Status')),
                          DataColumn(label: TableHeader('Actions')),
                        ],
                        rows: _creditNotes.map((creditNote) {
                          return DataRow(cells: [
                            DataCell(TableCellText(
                                '${creditNote.creditNoteDate.day.toString().padLeft(2, '0')} ${_getMonthName(creditNote.creditNoteDate.month)} ${creditNote.creditNoteDate.year}')),
                            DataCell(
                                TableCellText(creditNote.creditNoteNumber)),
                            DataCell(
                                TableCellText(creditNote.partyName ?? '-')),
                            DataCell(
                                TableCellText(creditNote.invoiceNumber ?? '-')),
                            DataCell(TableCellText(
                                '₹ ${creditNote.totalAmount.toStringAsFixed(2)}')),
                            DataCell(TableCellText(
                                '₹ ${creditNote.amountReceived.toStringAsFixed(2)}')),
                            DataCell(
                                TableCellText(creditNote.paymentMode ?? '-')),
                            DataCell(TableStatusBadge(
                              creditNote.status == 'applied'
                                  ? 'Applied'
                                  : creditNote.status == 'issued'
                                      ? 'Issued'
                                      : 'Draft',
                            )),
                            DataCell(
                              TableActionButtons(
                                onView: () => _viewCreditNote(creditNote),
                                onEdit: () => _editCreditNote(creditNote),
                                onDelete: () => _showDeleteDialog(creditNote),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }
}
