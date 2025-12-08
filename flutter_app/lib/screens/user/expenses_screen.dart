import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../services/expense_service.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';
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
                  onPressed: () {},
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
                    : SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey[100],
                          ),
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Expense Number')),
                            DataColumn(label: Text('Party Name')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Amount')),
                          ],
                          rows: _expenses
                              .map(
                                (expense) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        DateFormat('dd MMM yyyy')
                                            .format(expense.expenseDate),
                                      ),
                                    ),
                                    DataCell(
                                      Text(expense.expenseNumber),
                                    ),
                                    DataCell(
                                      Text(expense.party?.name ?? '-'),
                                    ),
                                    DataCell(
                                      Text(expense.category),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${NumberFormat('#,##,###.##').format(expense.totalAmount)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
