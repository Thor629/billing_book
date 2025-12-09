import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/debit_note_model.dart';
import '../../services/debit_note_service.dart';
import '../../providers/organization_provider.dart';
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateDebitNoteScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadDebitNotes();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Debit Note Number')),
                              DataColumn(label: Text('Supplier Name')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Amount Paid')),
                              DataColumn(label: Text('Payment Mode')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _debitNotes.map((debitNote) {
                              return DataRow(cells: [
                                DataCell(Text(
                                    '${debitNote.debitNoteDate.day.toString().padLeft(2, '0')} ${_getMonthName(debitNote.debitNoteDate.month)} ${debitNote.debitNoteDate.year}')),
                                DataCell(Text(debitNote.debitNoteNumber)),
                                DataCell(Text(debitNote.partyName ?? '-')),
                                DataCell(Text(
                                    '₹ ${debitNote.totalAmount.toStringAsFixed(2)}')),
                                DataCell(Text(
                                    '₹ ${debitNote.amountPaid.toStringAsFixed(2)}')),
                                DataCell(Text(debitNote.paymentMode ?? '-')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: debitNote.status == 'issued'
                                          ? Colors.blue[50]
                                          : debitNote.status == 'cancelled'
                                              ? Colors.red[50]
                                              : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      debitNote.status == 'issued'
                                          ? 'Issued'
                                          : debitNote.status == 'cancelled'
                                              ? 'Cancelled'
                                              : 'Draft',
                                      style: TextStyle(
                                        color: debitNote.status == 'issued'
                                            ? Colors.blue[700]
                                            : debitNote.status == 'cancelled'
                                                ? Colors.red[700]
                                                : Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () =>
                                        _showDeleteDialog(debitNote),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
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
