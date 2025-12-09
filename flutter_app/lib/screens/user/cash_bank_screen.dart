import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/bank_account_model.dart';
import '../../models/transaction_model.dart';
import '../../services/bank_account_service.dart';
import '../../widgets/loading_indicator.dart';

class CashBankScreen extends StatefulWidget {
  const CashBankScreen({super.key});

  @override
  State<CashBankScreen> createState() => _CashBankScreenState();
}

class _CashBankScreenState extends State<CashBankScreen> {
  final BankAccountService _bankAccountService = BankAccountService();
  List<BankAccount> _accounts = [];
  List<BankTransaction> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingTransactions = false;
  String _selectedPeriod = 'All Time';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      final token = await authProvider.token;
      if (token == null) throw Exception('Not authenticated');

      final accounts = await _bankAccountService.getBankAccounts(
        token,
        orgProvider.selectedOrganization?.id,
      );

      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });

      // Load transactions after accounts are loaded
      await _loadTransactions();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading accounts: $e')),
        );
      }
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization == null) {
        setState(() => _isLoadingTransactions = false);
        return;
      }

      final token = await authProvider.token;
      if (token == null) throw Exception('Not authenticated');

      // Calculate date range based on selected period
      final now = DateTime.now();
      String? startDate;
      String? endDate;

      switch (_selectedPeriod) {
        case 'Last 30 Days':
          startDate = DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 30)));
          endDate = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'Last 90 Days':
          startDate = DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 90)));
          endDate = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'This Year':
          startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, 1, 1));
          endDate = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'All Time':
          // No date filter - show all transactions
          startDate = null;
          endDate = null;
          break;
      }

      final transactions = await _bankAccountService.getTransactions(
        token,
        organizationId: orgProvider.selectedOrganization!.id,
        startDate: startDate,
        endDate: endDate,
      );

      print('DEBUG: Loaded ${transactions.length} transactions');
      print('DEBUG: Organization ID: ${orgProvider.selectedOrganization!.id}');
      print('DEBUG: Date range: $startDate to $endDate');

      setState(() {
        _transactions = transactions;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      print('DEBUG ERROR: Failed to load transactions: $e');
      setState(() => _isLoadingTransactions = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  double get _totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.currentBalance);
  }

  double get _cashInHand {
    return _accounts
        .where((account) => account.accountType == 'cash')
        .fold(0.0, (sum, account) => sum + account.currentBalance);
  }

  List<BankAccount> get _bankAccounts {
    return _accounts.where((account) => account.accountType == 'bank').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cash and Bank', style: AppTextStyles.h1),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showAddReduceMoneyDialog(),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Add/Reduce Money'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showTransferMoneyDialog(),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Transfer Money'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAccountDialog(isBankAccount: true),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Expanded(child: Center(child: LoadingIndicator()))
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Balance
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance:',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${NumberFormat('#,##,###.##').format(_totalBalance)}',
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cash Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cash', style: AppTextStyles.bodyMedium),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cash in hand',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    '₹${NumberFormat('#,##,###.##').format(_cashInHand)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Bank Accounts Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bank Accounts',
                                  style: AppTextStyles.bodyMedium),
                              TextButton(
                                onPressed: () =>
                                    _showAddAccountDialog(isBankAccount: true),
                                child: const Text('+ Add New Bank'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Unlinked Transactions (placeholder)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.link_off,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Unlinked Transactions',
                                style: AppTextStyles.bodySmall,
                              ),
                              const Spacer(),
                              Text(
                                '₹0',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bank Account List
                        Expanded(
                          child: ListView.builder(
                            itemCount: _bankAccounts.length,
                            itemBuilder: (context, index) {
                              final account = _bankAccounts[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          account.accountName[0].toUpperCase(),
                                          style: AppTextStyles.h3.copyWith(
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account.accountName,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (account.bankAccountNo != null)
                                            Text(
                                              account.bankAccountNo!,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₹${NumberFormat('#,##,###.##').format(account.currentBalance)}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right Content Area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          // Transactions Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'All Transactions',
                                  style: AppTextStyles.h3,
                                ),
                                const Spacer(),
                                DropdownButton<String>(
                                  value: _selectedPeriod,
                                  items: [
                                    'All Time',
                                    'Last 30 Days',
                                    'Last 90 Days',
                                    'This Year'
                                  ]
                                      .map((period) => DropdownMenuItem(
                                            value: period,
                                            child: Text(period),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedPeriod = value!);
                                    _loadTransactions();
                                  },
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download),
                                  tooltip: 'Export',
                                ),
                              ],
                            ),
                          ),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 52), // Icon space
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Description',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Account',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Type',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Date',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Amount',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Transactions List
                          Expanded(
                            child: _isLoadingTransactions
                                ? const Center(child: LoadingIndicator())
                                : _transactions.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.receipt_long_outlined,
                                              size: 64,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No Transactions',
                                              style: AppTextStyles.h3.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'You don\'t have any transaction in selected period',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _transactions.length,
                                        itemBuilder: (context, index) {
                                          final transaction =
                                              _transactions[index];
                                          return _buildTransactionRow(
                                              transaction);
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(BankTransaction transaction) {
    // Determine icon, color, and type label based on transaction type
    IconData icon;
    Color amountColor;
    String amountPrefix;
    String typeLabel;

    switch (transaction.transactionType) {
      case 'add':
        icon = Icons.add_circle;
        amountColor = Colors.green;
        amountPrefix = '+';
        typeLabel = 'Add Money';
        break;
      case 'reduce':
        icon = Icons.remove_circle;
        amountColor = Colors.red;
        amountPrefix = '-';
        typeLabel = 'Reduce Money';
        break;
      case 'expense':
        icon = Icons.shopping_cart;
        amountColor = Colors.orange;
        amountPrefix = '-';
        typeLabel = 'Expense';
        break;
      case 'payment_in':
        icon = Icons.payment;
        amountColor = Colors.green;
        amountPrefix = '+';
        typeLabel = 'Payment In';
        break;
      case 'payment_out':
        icon = Icons.payment;
        amountColor = Colors.red;
        amountPrefix = '-';
        typeLabel = 'Payment Out';
        break;
      case 'sales_return':
        icon = Icons.assignment_return;
        amountColor = Colors.orange;
        amountPrefix = '-';
        typeLabel = 'Sales Return';
        break;
      case 'purchase_return':
        icon = Icons.assignment_return_outlined;
        amountColor = Colors.blue;
        amountPrefix = '+';
        typeLabel = 'Purchase Return';
        break;
      case 'credit_note':
        icon = Icons.note_add;
        amountColor = Colors.green;
        amountPrefix = '+';
        typeLabel = 'Credit Note';
        break;
      case 'transfer_in':
        icon = Icons.arrow_downward;
        amountColor = Colors.green;
        amountPrefix = '+';
        typeLabel = 'Transfer In';
        break;
      case 'transfer_out':
        icon = Icons.arrow_upward;
        amountColor = Colors.red;
        amountPrefix = '-';
        typeLabel = 'Transfer Out';
        break;
      default:
        icon = Icons.swap_horiz;
        amountColor = Colors.grey;
        amountPrefix = '';
        typeLabel = 'Transaction';
    }

    // Format date
    final date = DateTime.parse(transaction.transactionDate);
    final formattedDate = DateFormat('dd MMM yyyy').format(date);

    // Get account name
    final account = _accounts.firstWhere(
      (acc) => acc.id == transaction.accountId,
      orElse: () => BankAccount(
        userId: transaction.userId,
        accountName: 'Unknown Account',
        openingBalance: 0,
        asOfDate: '',
        currentBalance: 0,
        accountType: 'cash',
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: amountColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Description
          Expanded(
            flex: 3,
            child: Text(
              transaction.description ?? typeLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Account Name
          Expanded(
            flex: 2,
            child: Text(
              account.accountName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Type Badge
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Date
          Expanded(
            flex: 1,
            child: Text(
              formattedDate,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Amount
          SizedBox(
            width: 120,
            child: Text(
              '$amountPrefix₹${NumberFormat('#,##,###.##').format(transaction.amount)}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog({bool isBankAccount = false}) {
    showDialog(
      context: context,
      builder: (context) => _AddAccountDialog(
        isBankAccount: isBankAccount,
        onAccountAdded: _loadAccounts,
      ),
    );
  }

  void _showAddReduceMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddReduceMoneyDialog(
        accounts: _accounts,
        onTransactionAdded: _loadAccounts,
      ),
    );
  }

  void _showTransferMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => _TransferMoneyDialog(
        accounts: _accounts,
        onTransferCompleted: _loadAccounts,
      ),
    );
  }
}

// Add Account Dialog
class _AddAccountDialog extends StatefulWidget {
  final bool isBankAccount;
  final VoidCallback onAccountAdded;

  const _AddAccountDialog({
    required this.isBankAccount,
    required this.onAccountAdded,
  });

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _asOfDateController = TextEditingController();
  final _bankAccountNoController = TextEditingController();
  final _reEnterBankAccountNoController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _asOfDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _openingBalanceController.dispose();
    _asOfDateController.dispose();
    _bankAccountNoController.dispose();
    _reEnterBankAccountNoController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    _upiIdController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _asOfDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isBankAccount &&
        _bankAccountNoController.text != _reEnterBankAccountNoController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank account numbers do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      final account = BankAccount(
        userId: authProvider.user!.id,
        organizationId: orgProvider.selectedOrganization?.id,
        accountName: _accountNameController.text,
        openingBalance: double.parse(_openingBalanceController.text),
        asOfDate: _asOfDateController.text,
        bankAccountNo:
            widget.isBankAccount ? _bankAccountNoController.text : null,
        ifscCode: widget.isBankAccount ? _ifscCodeController.text : null,
        accountHolderName:
            widget.isBankAccount ? _accountHolderNameController.text : null,
        upiId: widget.isBankAccount ? _upiIdController.text : null,
        bankName: widget.isBankAccount ? _bankNameController.text : null,
        branchName: widget.isBankAccount ? _branchNameController.text : null,
        currentBalance: double.parse(_openingBalanceController.text),
        accountType: widget.isBankAccount ? 'bank' : 'cash',
      );

      final token = await authProvider.token;
      if (token == null) throw Exception('Not authenticated');

      await BankAccountService().createBankAccount(token, account);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        widget.onAccountAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.isBankAccount
                          ? Icons.account_balance
                          : Icons.account_balance_wallet,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isBankAccount
                        ? 'Add New Bank Account'
                        : 'Add New Cash Account',
                    style: AppTextStyles.h2,
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _accountNameController,
                        decoration: InputDecoration(
                          labelText: 'Account Name *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _openingBalanceController,
                        decoration: InputDecoration(
                          labelText: 'Opening Balance *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixText: '₹ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _asOfDateController,
                        decoration: InputDecoration(
                          labelText: 'As of Date *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDate,
                          ),
                        ),
                        readOnly: true,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      if (widget.isBankAccount) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bankAccountNoController,
                          decoration: InputDecoration(
                            labelText: 'Bank Account No',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reEnterBankAccountNoController,
                          decoration: InputDecoration(
                            labelText: 'Re-enter Bank Account No',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ifscCodeController,
                          decoration: InputDecoration(
                            labelText: 'IFSC Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _accountHolderNameController,
                          decoration: InputDecoration(
                            labelText: 'Account Holder Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _upiIdController,
                          decoration: InputDecoration(
                            labelText: 'UPI ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bankNameController,
                          decoration: InputDecoration(
                            labelText: 'Bank Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _branchNameController,
                          decoration: InputDecoration(
                            labelText: 'Branch Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add/Reduce Money Dialog
class _AddReduceMoneyDialog extends StatefulWidget {
  final List<BankAccount> accounts;
  final VoidCallback onTransactionAdded;

  const _AddReduceMoneyDialog({
    required this.accounts,
    required this.onTransactionAdded,
  });

  @override
  State<_AddReduceMoneyDialog> createState() => _AddReduceMoneyDialogState();
}

class _AddReduceMoneyDialogState extends State<_AddReduceMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  BankAccount? _selectedAccount;
  String _transactionType = 'add';
  String _accountTypeFilter = 'cash'; // 'cash' or 'bank'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Set first cash account as default
    final cashAccounts =
        widget.accounts.where((a) => a.accountType == 'cash').toList();
    if (cashAccounts.isNotEmpty) {
      _selectedAccount = cashAccounts.first;
    } else if (widget.accounts.isNotEmpty) {
      _selectedAccount = widget.accounts.first;
      _accountTypeFilter = widget.accounts.first.accountType;
    }
  }

  List<BankAccount> get _filteredAccounts {
    return widget.accounts
        .where((account) => account.accountType == _accountTypeFilter)
        .toList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      final transaction = BankTransaction(
        userId: authProvider.user!.id,
        organizationId: orgProvider.selectedOrganization?.id,
        accountId: _selectedAccount!.id!,
        transactionType: _transactionType,
        amount: double.parse(_amountController.text),
        transactionDate: _dateController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      final token = await authProvider.token;
      if (token == null) throw Exception('Not authenticated');

      await BankAccountService().addTransaction(token, transaction);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
        widget.onTransactionAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add/Reduce Money', style: AppTextStyles.h2),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'add', child: Text('Add Money')),
                  DropdownMenuItem(
                      value: 'reduce', child: Text('Reduce Money')),
                ],
                onChanged: (value) {
                  setState(() => _transactionType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Cash or Bank Selection
              DropdownButtonFormField<String>(
                value: _accountTypeFilter,
                decoration: InputDecoration(
                  labelText: 'Account Type *',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    _accountTypeFilter == 'cash'
                        ? Icons.account_balance_wallet
                        : Icons.account_balance,
                    color: AppColors.primaryDark,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'cash',
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 20),
                        SizedBox(width: 8),
                        Text('Cash'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'bank',
                    child: Row(
                      children: [
                        Icon(Icons.account_balance, size: 20),
                        SizedBox(width: 8),
                        Text('Bank'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _accountTypeFilter = value!;
                    // Reset selected account when type changes
                    final filtered = _filteredAccounts;
                    _selectedAccount =
                        filtered.isNotEmpty ? filtered.first : null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Account Selection (filtered by type)
              DropdownButtonFormField<BankAccount>(
                value: _filteredAccounts.contains(_selectedAccount)
                    ? _selectedAccount
                    : (_filteredAccounts.isNotEmpty
                        ? _filteredAccounts.first
                        : null),
                decoration: InputDecoration(
                  labelText: _accountTypeFilter == 'cash'
                      ? 'Select Cash Account *'
                      : 'Select Bank Account *',
                  border: const OutlineInputBorder(),
                  helperText: _filteredAccounts.isEmpty
                      ? 'No ${_accountTypeFilter} accounts available'
                      : null,
                ),
                items: _filteredAccounts.isEmpty
                    ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No accounts available'),
                        )
                      ]
                    : _filteredAccounts
                        .map((account) => DropdownMenuItem(
                              value: account,
                              child: Text(
                                '${account.accountName} - ₹${NumberFormat('#,##,###.##').format(account.currentBalance)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                onChanged: _filteredAccounts.isEmpty
                    ? null
                    : (value) {
                        setState(() => _selectedAccount = value);
                      },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date *',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Transfer Money Dialog
class _TransferMoneyDialog extends StatefulWidget {
  final List<BankAccount> accounts;
  final VoidCallback onTransferCompleted;

  const _TransferMoneyDialog({
    required this.accounts,
    required this.onTransferCompleted,
  });

  @override
  State<_TransferMoneyDialog> createState() => _TransferMoneyDialogState();
}

class _TransferMoneyDialogState extends State<_TransferMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _manualAccountHolderController = TextEditingController();
  final _manualAccountNumberController = TextEditingController();
  final _manualBankNameController = TextEditingController();
  final _manualIfscController = TextEditingController();
  BankAccount? _fromAccount;
  BankAccount? _toAccount;
  bool _isLoading = false;
  bool _isManualEntry = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _manualAccountHolderController.dispose();
    _manualAccountNumberController.dispose();
    _manualBankNameController.dispose();
    _manualIfscController.dispose();
    super.dispose();
  }

  void _toggleEntryMode(bool? value) {
    setState(() {
      _isManualEntry = value ?? false;
      // Clear destination data when switching modes
      if (_isManualEntry) {
        _toAccount = null;
      } else {
        _manualAccountHolderController.clear();
        _manualAccountNumberController.clear();
        _manualBankNameController.clear();
        _manualIfscController.clear();
      }
    });
  }

  String? _validateIfscCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'IFSC code is required';
    }
    if (value.length != 11) {
      return 'IFSC code must be 11 characters';
    }
    final regex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!regex.hasMatch(value)) {
      return 'Invalid IFSC format (e.g., SBIN0001234)';
    }
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Account number must contain only digits';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _transferMoney() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select from account')),
      );
      return;
    }

    if (!_isManualEntry && _toAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select to account')),
      );
      return;
    }

    if (!_isManualEntry && _fromAccount!.id == _toAccount!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot transfer to the same account')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    if (amount > _fromAccount!.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Available: ₹${NumberFormat('#,##,###.##').format(_fromAccount!.currentBalance)}',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final token = await authProvider.token;
      if (token == null) throw Exception('Not authenticated');

      if (_isManualEntry) {
        // External transfer
        await BankAccountService().transferMoney(
          token: token,
          fromAccountId: _fromAccount!.id!,
          amount: amount,
          date: _dateController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isExternal: true,
          externalAccountHolder: _manualAccountHolderController.text,
          externalAccountNumber: _manualAccountNumberController.text,
          externalBankName: _manualBankNameController.text,
          externalIfscCode: _manualIfscController.text.toUpperCase(),
        );
      } else {
        // Internal transfer
        await BankAccountService().transferMoney(
          token: token,
          fromAccountId: _fromAccount!.id!,
          toAccountId: _toAccount!.id!,
          amount: amount,
          date: _dateController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isExternal: false,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Money transferred successfully')),
        );
        widget.onTransferCompleted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transfer Money', style: AppTextStyles.h2),
                const SizedBox(height: 24),

                // From Account
                DropdownButtonFormField<BankAccount>(
                  value: _fromAccount,
                  decoration: const InputDecoration(
                    labelText: 'From Account *',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.accounts
                      .map((account) => DropdownMenuItem(
                            value: account,
                            child: Text(
                              '${account.accountName} (₹${NumberFormat('#,##,###.##').format(account.currentBalance)})',
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _fromAccount = value);
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Mode Toggle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isManualEntry ? Icons.edit : Icons.account_balance,
                            size: 20,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Transfer To:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('My Accounts'),
                              subtitle: const Text('Select from your accounts'),
                              value: false,
                              groupValue: _isManualEntry,
                              onChanged: _toggleEntryMode,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('External Account'),
                              subtitle: const Text('Enter bank details'),
                              value: true,
                              groupValue: _isManualEntry,
                              onChanged: _toggleEntryMode,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Conditional To Account Section
                if (!_isManualEntry) ...[
                  // Dropdown Mode
                  DropdownButtonFormField<BankAccount>(
                    value: _toAccount,
                    decoration: const InputDecoration(
                      labelText: 'To Account *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: widget.accounts
                        .map((account) => DropdownMenuItem(
                              value: account,
                              child: Text(account.accountName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _toAccount = value);
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ] else ...[
                  // Manual Entry Mode
                  TextFormField(
                    controller: _manualAccountHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Account Holder Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _manualAccountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateAccountNumber,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _manualBankNameController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _manualIfscController,
                    decoration: const InputDecoration(
                      labelText: 'IFSC Code *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                      hintText: 'e.g., SBIN0001234',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 11,
                    validator: _validateIfscCode,
                  ),
                ],
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Date
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date *',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _transferMoney,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Transfer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
