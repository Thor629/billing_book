import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/debit_note_model.dart';
import '../../services/debit_note_service.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/unified_data_table.dart';
import 'create_debit_note_screen.dart';

class DebitNoteScreen extends StatefulWidget {
  const DebitNoteScreen({super.key});

  @override
  State<DebitNoteScreen> createState() => _DebitNoteScreenState();
}

class _DebitNoteScreenState extends State<DebitNoteScreen> {
  final DebitNoteService _debitNoteService = DebitNoteService();
  String _selectedFilter = 'Last 365 Days';
  bool _isLoading = true;
  List<DebitNote> _debitNotes = [];

  @override
  void initState() {
    super.initState();
    _loadDebitNotes();
  }

  Future<void> _loadDebitNotes() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _debitNoteService.getDebitNotes(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _selectedFilter,
      );
      setState(() {
        _debitNotes = result['debit_notes'] as List<DebitNote>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading debit notes: $e')),
        );
      }
    }
  }

  Future<void> _deleteDebitNote(int id) async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    try {
      await _debitNoteService.deleteDebitNote(
        id,
        orgProvider.selectedOrganization!.id,
      );
      _loadDebitNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debit note deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting debit note: $e')),
        );
      }
    }
  }

  void _viewDebitNote(DebitNote debitNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debit Note ${debitNote.debitNoteNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Supplier', debitNote.partyName ?? 'N/A'),
              _buildDetailRow(
                'Date',
                '${debitNote.debitNoteDate.day.toString().padLeft(2, '0')} ${_getMonthName(debitNote.debitNoteDate.month)} ${debitNote.debitNoteDate.year}',
              ),
              _buildDetailRow(
                'Amount',
                '₹${debitNote.totalAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Amount Paid',
                '₹${debitNote.amountPaid.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Payment Mode', debitNote.paymentMode ?? 'N/A'),
              _buildDetailRow('Status', debitNote.status),
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

  void _editDebitNote(DebitNote debitNote) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateDebitNoteScreen(
        debitNoteId: debitNote.id,
        debitNoteData: {
          'debit_note_number': debitNote.debitNoteNumber,
          'party_id': debitNote.partyId,
          'party_name': debitNote.partyName,
          'debit_note_date': debitNote.debitNoteDate.toIso8601String(),
          'total_amount': debitNote.totalAmount,
          'amount_paid': debitNote.amountPaid,
          'payment_mode': debitNote.paymentMode,
          'status': debitNote.status,
        },
      ),
    );

    if (result == true) {
      _loadDebitNotes();
    }
  }

  void _showDeleteDialog(DebitNote debitNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Debit Note'),
        content: Text(
            'Are you sure you want to delete debit note #${debitNote.debitNoteNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDebitNote(debitNote.id);
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
              Text('Debit Note', style: AppTextStyles.h1),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const CreateDebitNoteScreen(),
                  );
                  if (result == true) {
                    _loadDebitNotes();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Create Debit Note'),
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
                      _loadDebitNotes();
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
                : _debitNotes.isEmpty
                    ? const Center(child: Text('No debit notes found'))
                    : Card(
                        child: UnifiedDataTable(
                          columns: const [
                            DataColumn(label: TableHeader('Date')),
                            DataColumn(label: TableHeader('Debit Note Number')),
                            DataColumn(label: TableHeader('Supplier Name')),
                            DataColumn(label: TableHeader('Amount')),
                            DataColumn(label: TableHeader('Amount Paid')),
                            DataColumn(label: TableHeader('Payment Mode')),
                            DataColumn(label: TableHeader('Status')),
                            DataColumn(label: TableHeader('Actions')),
                          ],
                          rows: _debitNotes.map((debitNote) {
                            return DataRow(cells: [
                              DataCell(TableCellText(
                                  '${debitNote.debitNoteDate.day.toString().padLeft(2, '0')} ${_getMonthName(debitNote.debitNoteDate.month)} ${debitNote.debitNoteDate.year}')),
                              DataCell(
                                  TableCellText(debitNote.debitNoteNumber)),
                              DataCell(
                                  TableCellText(debitNote.partyName ?? '-')),
                              DataCell(TableCellText(
                                  '₹ ${debitNote.totalAmount.toStringAsFixed(2)}')),
                              DataCell(TableCellText(
                                  '₹ ${debitNote.amountPaid.toStringAsFixed(2)}')),
                              DataCell(
                                  TableCellText(debitNote.paymentMode ?? '-')),
                              DataCell(TableStatusBadge(
                                debitNote.status == 'issued'
                                    ? 'Issued'
                                    : debitNote.status == 'cancelled'
                                        ? 'Cancelled'
                                        : 'Draft',
                              )),
                              DataCell(
                                TableActionButtons(
                                  onView: () => _viewDebitNote(debitNote),
                                  onEdit: () => _editDebitNote(debitNote),
                                  onDelete: () => _showDeleteDialog(debitNote),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
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
