import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/expense_service.dart';
import '../../services/party_service.dart';
import '../../models/party_model.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';

class CreateExpenseScreen extends StatefulWidget {
  const CreateExpenseScreen({super.key});

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final PartyService _partyService = PartyService();

  final TextEditingController _expenseNumberController =
      TextEditingController();
  final TextEditingController _originalInvoiceController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _expenseDate = DateTime.now();
  String? _selectedCategory;
  String _paymentMode = 'Cash';
  bool _withGst = false;
  bool _isSaving = false;

  int? _selectedPartyId;
  String? _selectedPartyName;
  int? _selectedBankAccountId;
  String? _selectedBankAccountName;

  List<String> _categories = [];
  List<PartyModel> _parties = [];
  List<dynamic> _bankAccounts = [];
  List<ExpenseItemInput> _items = [];

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    try {
      // Load expense number
      try {
        final nextNumber = await _expenseService
            .getNextExpenseNumber(orgProvider.selectedOrganization!.id);
        _expenseNumberController.text = nextNumber.toString();
      } catch (e) {
        print('Error loading expense number: $e');
        // Set default expense number if API fails
        _expenseNumberController.text = '1';
      }

      // Load categories
      final categories = await _expenseService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadBankAccounts() async {
    if (_bankAccounts.isNotEmpty) return; // Already loaded

    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    try {
      final accounts = await _expenseService
          .getBankAccounts(orgProvider.selectedOrganization!.id);
      if (mounted) {
        setState(() {
          _bankAccounts = accounts;
        });
      }
    } catch (e) {
      print('Error loading bank accounts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bank accounts: $e')),
        );
      }
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  Future<void> _showPartySelectionDialog() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    try {
      _parties =
          await _partyService.getParties(orgProvider.selectedOrganization!.id);

      if (!mounted) return;

      final selectedParty = await showDialog<PartyModel>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Party',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Expanded(
                  child: _parties.isEmpty
                      ? const Center(child: Text('No parties found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _parties.length,
                          itemBuilder: (context, index) {
                            final party = _parties[index];
                            return ListTile(
                              title: Text(party.name),
                              subtitle: Text(party.phone),
                              onTap: () => Navigator.pop(context, party),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );

      if (selectedParty != null) {
        setState(() {
          _selectedPartyId = selectedParty.id;
          _selectedPartyName = selectedParty.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading parties: $e')),
        );
      }
    }
  }

  Future<void> _saveExpense() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization first')),
      );
      return;
    }

    // Validation
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    if (_paymentMode != 'Cash' && _selectedBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final expenseData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'expense_number': _expenseNumberController.text,
        'expense_date': _expenseDate.toIso8601String().split('T')[0],
        'category': _selectedCategory,
        'payment_mode': _paymentMode,
        'total_amount': _totalAmount,
        'with_gst': _withGst,
        if (_selectedPartyId != null) 'party_id': _selectedPartyId,
        if (_selectedBankAccountId != null)
          'bank_account_id': _selectedBankAccountId,
        if (_originalInvoiceController.text.isNotEmpty)
          'original_invoice_number': _originalInvoiceController.text,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
        'items': _items
            .map((item) => {
                  'item_name': item.itemName,
                  'description': item.description,
                  'quantity': item.quantity,
                  'rate': item.rate,
                  'amount': item.amount,
                })
            .toList(),
      };

      await _expenseService.createExpense(expenseData);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Expense created and balance updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Expense',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GST Toggle
                    Row(
                      children: [
                        const Text('Expense With GST'),
                        const Spacer(),
                        Switch(
                          value: _withGst,
                          onChanged: (value) {
                            setState(() => _withGst = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category
                    const Text('Expense Category'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Expense Number
                    const Text('Expense Number'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _expenseNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add Item Button
                    Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryDark),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('+ Add Item'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items List
                    if (_items.isNotEmpty)
                      ..._items.map((item) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.itemName),
                              subtitle:
                                  Text('Qty: ${item.quantity} × ₹${item.rate}'),
                              trailing: Text(
                                '₹${NumberFormat('#,##,###.##').format(item.amount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),

                    const SizedBox(height: 16),

                    // Total Amount
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Expense Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${NumberFormat('#,##,###.##').format(_totalAmount)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Side
              SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original Invoice Number
                    const Text('Original Invoice Number'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _originalInvoiceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date
                    const Text('Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expenseDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _expenseDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(DateFormat('d MMM yyyy').format(_expenseDate)),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Mode
                    const Text('Payment Mode'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _paymentMode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                        DropdownMenuItem(
                            value: 'Bank Transfer',
                            child: Text('Bank Transfer')),
                        DropdownMenuItem(
                            value: 'Cheque', child: Text('Cheque')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _paymentMode = value;
                            if (value == 'Cash') {
                              _selectedBankAccountId = null;
                              _selectedBankAccountName = null;
                            } else {
                              _loadBankAccounts();
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bank Account (if not cash)
                    if (_paymentMode != 'Cash') ...[
                      const Text('Bank Account'),
                      const SizedBox(height: 8),
                      _bankAccounts.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading bank accounts...',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonFormField<int>(
                              value: _selectedBankAccountId,
                              decoration: InputDecoration(
                                hintText: 'Select bank account',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _bankAccounts
                                  .map((account) => DropdownMenuItem<int>(
                                        value: account['id'],
                                        child: Text(
                                          '${account['account_name']} - ₹${NumberFormat('#,##,###.##').format(double.parse(account['current_balance'].toString()))}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final account = _bankAccounts.firstWhere(
                                    (acc) => acc['id'] == value,
                                  );
                                  setState(() {
                                    _selectedBankAccountId = value;
                                    _selectedBankAccountName =
                                        account['account_name'];
                                  });
                                }
                              },
                            ),
                      const SizedBox(height: 16),
                    ],

                    // Note
                    const Text('Note'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter Notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _expenseNumberController.dispose();
    _originalInvoiceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class ExpenseItemInput {
  final String itemName;
  final String? description;
  final double quantity;
  final double rate;
  final double amount;

  ExpenseItemInput({
    required this.itemName,
    this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
  });
}

class _AddItemDialog extends StatefulWidget {
  final Function(ExpenseItemInput) onAdd;

  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _rateController =
      TextEditingController(text: '0');

  double get _amount {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    return qty * rate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rate *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount:'),
                  Text(
                    '₹${NumberFormat('#,##,###.##').format(_amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_itemNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter item name')),
                      );
                      return;
                    }

                    widget.onAdd(
                      ExpenseItemInput(
                        itemName: _itemNameController.text,
                        description: _descriptionController.text.isEmpty
                            ? null
                            : _descriptionController.text,
                        quantity:
                            double.tryParse(_quantityController.text) ?? 1,
                        rate: double.tryParse(_rateController.text) ?? 0,
                        amount: _amount,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}
