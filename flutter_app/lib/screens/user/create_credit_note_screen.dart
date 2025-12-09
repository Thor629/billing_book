import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/credit_note_service.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../services/bank_account_service.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../models/bank_account_model.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';

class CreateCreditNoteScreen extends StatefulWidget {
  const CreateCreditNoteScreen({super.key});

  @override
  State<CreateCreditNoteScreen> createState() =>
      _CreateCreditNoteScreenState();
}

class _CreateCreditNoteScreenState extends State<CreateCreditNoteScreen> {
  final CreditNoteService _creditNoteService = CreditNoteService();
  final PartyService _partyService = PartyService();
  final ItemService _itemService = ItemService();
  final BankAccountService _bankAccountService = BankAccountService();

  final TextEditingController _creditNoteNumberController =
      TextEditingController(text: '1');
  final TextEditingController _invoiceSearchController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _amountReceivedController =
      TextEditingController();

  DateTime _creditNoteDate = DateTime.now();
  int? _selectedPartyId;
  String? _selectedPartyName;
  String? _linkedInvoiceNumber;
  bool _isSaving = false;
  bool _isFullyPaid = false;
  String _paymentMode = 'Cash';

  List<CreditNoteItemRow> _items = [];
  List<PartyModel> _parties = [];
  List<ItemModel> _availableItems = [];
  List<BankAccount> _bankAccounts = [];
  int? _selectedBankAccountId;

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get _discount => 0;
  double get _tax => _items.fold(0, (sum, item) => sum + item.taxAmount);
  double get _totalAmount => _subtotal - _discount + _tax;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (orgProvider.selectedOrganization != null) {
      try {
        final token = await authProvider.token;
        if (token == null) return;

        final parties = await _partyService
            .getParties(orgProvider.selectedOrganization!.id);
        final items =
            await _itemService.getItems(orgProvider.selectedOrganization!.id);
        final accounts = await _bankAccountService.getBankAccounts(
          token,
          orgProvider.selectedOrganization!.id,
        );

        setState(() {
          _parties = parties;
          _availableItems = items;
          _bankAccounts = accounts;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading data: $e')),
          );
        }
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
          'Create Credit Note',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save Credit Note'),
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
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill To
                    const Text(
                      'Bill To',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showPartySelectionDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _selectedPartyName ?? '+ Add Party',
                            style: TextStyle(
                              color: _selectedPartyName == null
                                  ? Colors.blue[700]
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Items Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 40, child: Text('NO')),
                                Expanded(
                                    flex: 3, child: Text('ITEMS/ SERVICES')),
                                Expanded(child: Text('HSN/ SAC')),
                                Expanded(child: Text('QTY')),
                                Expanded(child: Text('PRICE/ITEM (₹)')),
                                Expanded(child: Text('DISCOUNT')),
                                Expanded(child: Text('TAX')),
                                Expanded(child: Text('AMOUNT (₹)')),
                                SizedBox(width: 40),
                              ],
                            ),
                          ),
                          // Items
                          ..._items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return _buildItemRow(index, item);
                          }),
                          // Add Item Button
                          InkWell(
                            onTap: _showAddItemDialog,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  '+ Add Item',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Subtotal
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Colors.grey[300]!)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('SUBTOTAL'),
                                const SizedBox(width: 100),
                                Text('₹ ${_subtotal.toStringAsFixed(2)}'),
                                const SizedBox(width: 100),
                                Text('₹ ${_discount.toStringAsFixed(2)}'),
                                const SizedBox(width: 100),
                                Text('₹ ${_tax.toStringAsFixed(2)}'),
                                const SizedBox(width: 100),
                                Text('₹ ${_totalAmount.toStringAsFixed(2)}'),
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notes and Payment Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Notes'),
                              ),
                              const SizedBox(height: 16),
                              const Text('Terms and Conditions'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '1. Goods once sold will not be taken back or exchanged'),
                                    Text(
                                        '2. All disputes are subject to [ENTER_YOUR_CITY_NAME] jurisdiction only'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Additional Charges'),
                                  ),
                                  const Text('₹ 0'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Discount'),
                                  ),
                                  Text('- ₹ ${_discount.toStringAsFixed(2)}'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Taxable Amount'),
                                  Text('₹ ${_totalAmount.toStringAsFixed(2)}'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: false,
                                    onChanged: (value) {},
                                  ),
                                  const Text('Auto Round Off'),
                                  const Spacer(),
                                  const Text('0'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹ ${_totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _amountReceivedController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter Payment amount',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isFullyPaid,
                                    onChanged: (value) {
                                      setState(() {
                                        _isFullyPaid = value ?? false;
                                        if (_isFullyPaid) {
                                          _amountReceivedController.text =
                                              _totalAmount.toStringAsFixed(2);
                                        }
                                      });
                                    },
                                  ),
                                  const Text('Mark as fully paid'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Text('Amount Received'),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountReceivedController,
                                      decoration: const InputDecoration(
                                        prefixText: '₹ ',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  DropdownButton<String>(
                                    value: _paymentMode,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Cash', child: Text('Cash')),
                                      DropdownMenuItem(
                                          value: 'Card', child: Text('Card')),
                                      DropdownMenuItem(
                                          value: 'UPI', child: Text('UPI')),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _paymentMode = value;
                                          if (value == 'Cash') {
                                            _selectedBankAccountId = null;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              // Bank Account Selection (if not cash)
                              if (_paymentMode != 'Cash' &&
                                  _bankAccounts.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Text('Bank Account: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 16),
                                    DropdownButton<int>(
                                      value: _selectedBankAccountId,
                                      hint: const Text('Select Account'),
                                      items: _bankAccounts.map((account) {
                                        return DropdownMenuItem(
                                          value: account.id,
                                          child: Text(
                                            '${account.accountName} - ₹${account.currentBalance.toStringAsFixed(2)}',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() =>
                                            _selectedBankAccountId = value);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Text('Balance Amount'),
                                  const Spacer(),
                                  Text(
                                    '₹ 0',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Side
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Credit Note No
                    const Text(
                      'Credit Note No.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _creditNoteNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Credit Note Date
                    const Text(
                      'Credit Note Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _creditNoteDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _creditNoteDate = date);
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
                            Text(
                              '${_creditNoteDate.day} ${_getMonthName(_creditNoteDate.month)} ${_creditNoteDate.year}',
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Link to Invoice
                    Row(
                      children: [
                        const Text(
                          'Link to Invoice',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'New',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _invoiceSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search invoices',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Scan Barcode Button
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Barcode'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey[300]!),
                        minimumSize: const Size(double.infinity, 48),
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
