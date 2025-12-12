import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../services/expense_service.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/unified_data_table.dart';
import 'create_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String _dateFilter = 'Last 365 Days';
  String _categoryFilter = 'All Expenses Categories';
  String _searchQuery = '';
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isLoading = true);

    try {
      print(
          'DEBUG Expenses: Loading expenses for org ${orgProvider.selectedOrganization!.id}');
      final result = await _expenseService.getExpenses(
        organizationId: orgProvider.selectedOrganization!.id,
        dateFilter: _dateFilter,
        category: _categoryFilter != 'All Expenses Categories'
            ? _categoryFilter
            : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      print('DEBUG Expenses: Loaded ${result['expenses'].length} expenses');
      setState(() {
        _expenses = result['expenses'] ?? [];
        _summary = result['summary'];
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG Expenses: Error loading expenses: $e');
      setState(() {
        _expenses = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading expenses: $e')),
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
                  'Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Reports Button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Reports'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                      _loadExpenses();
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
                        _loadExpenses();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Category Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _categoryFilter,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: ['All Expenses Categories']
                        .map((filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _categoryFilter = value);
                        _loadExpenses();
                      }
                    },
                  ),
                ),
                const Spacer(),

                // Create Expense Button
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateExpenseScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadExpenses();
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
                  child: const Text('Create Expense'),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
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
                          DataColumn(label: TableHeader('Expense Number')),
                          DataColumn(label: TableHeader('Party Name')),
                          DataColumn(label: TableHeader('Category')),
                          DataColumn(label: TableHeader('Amount')),
                          DataColumn(label: TableHeader('Actions')),
                        ],
                        rows: _expenses
                            .map(
                              (expense) => DataRow(
                                cells: [
                                  DataCell(TableCellText(
                                    DateFormat('dd MMM yyyy')
                                        .format(expense.expenseDate),
                                  )),
                                  DataCell(
                                      TableCellText(expense.expenseNumber)),
                                  DataCell(TableCellText(
                                      expense.party?.name ?? '-')),
                                  DataCell(TableCellText(expense.category)),
                                  DataCell(
                                      TableAmount(amount: expense.totalAmount)),
                                  DataCell(
                                    TableActionButtons(
                                      onView: () => _viewExpense(expense),
                                      onEdit: () => _editExpense(expense),
                                      onDelete: () => _deleteExpense(expense),
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

  void _viewExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Expense ${expense.expenseNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Party', expense.party?.name ?? 'N/A'),
              _buildDetailRow(
                'Date',
                DateFormat('dd MMM yyyy').format(expense.expenseDate),
              ),
              _buildDetailRow('Category', expense.category),
              _buildDetailRow(
                'Amount',
                '₹${expense.totalAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Payment Mode', expense.paymentMode ?? 'N/A'),
              if (expense.notes != null && expense.notes!.isNotEmpty)
                _buildDetailRow('Notes', expense.notes!),
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

  void _editExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateExpenseScreen(
          expenseId: expense.id,
          expenseData: {
            'expense_number': expense.expenseNumber,
            'party_id': expense.party?.id,
            'party_name': expense.party?.name,
            'expense_date': expense.expenseDate.toIso8601String(),
            'category': expense.category,
            'payment_mode': expense.paymentMode,
            'total_amount': expense.totalAmount,
            'notes': expense.notes,
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadExpenses();
      }
    });
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Are you sure you want to delete expense ${expense.expenseNumber}?',
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
        await _expenseService.deleteExpense(expense.id!);
        _loadExpenses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting expense: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
