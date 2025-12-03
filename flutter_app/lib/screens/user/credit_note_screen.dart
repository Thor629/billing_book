import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/credit_note_model.dart';
import '../../services/credit_note_service.dart';
import '../../providers/organization_provider.dart';
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateCreditNoteScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadCreditNotes();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
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
                    : Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Credit Note Number')),
                              DataColumn(label: Text('Party Name')),
                              DataColumn(label: Text('Invoice No')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _creditNotes.map((creditNote) {
                              return DataRow(cells: [
                                DataCell(Text(
                                    '${creditNote.creditNoteDate.day.toString().padLeft(2, '0')} ${_getMonthName(creditNote.creditNoteDate.month)} ${creditNote.creditNoteDate.year}')),
                                DataCell(Text(creditNote.creditNoteNumber)),
                                DataCell(Text(creditNote.partyName ?? '-')),
                                DataCell(Text(creditNote.invoiceNumber ?? '-')),
                                DataCell(Text(
                                    '₹ ${creditNote.totalAmount.toStringAsFixed(2)}')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: creditNote.status == 'applied'
                                          ? Colors.green[50]
                                          : creditNote.status == 'issued'
                                              ? Colors.blue[50]
                                              : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      creditNote.status == 'applied'
                                          ? 'Applied'
                                          : creditNote.status == 'issued'
                                              ? 'Issued'
                                              : 'Draft',
                                      style: TextStyle(
                                        color: creditNote.status == 'applied'
                                            ? Colors.green[700]
                                            : creditNote.status == 'issued'
                                                ? Colors.blue[700]
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
                                        _showDeleteDialog(creditNote),
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
