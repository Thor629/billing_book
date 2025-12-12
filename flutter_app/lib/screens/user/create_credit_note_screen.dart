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
import '../../widgets/dialog_scaffold.dart';

class CreateCreditNoteScreen extends StatefulWidget {
  final int? creditNoteId;
  final Map<String, dynamic>? creditNoteData;

  const CreateCreditNoteScreen({
    super.key,
    this.creditNoteId,
    this.creditNoteData,
  });

  @override
  State<CreateCreditNoteScreen> createState() => _CreateCreditNoteScreenState();
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

  double _discountAmount = 0.0;
  double _additionalCharges = 0.0;

  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get _discount => _discountAmount;
  double get _tax => _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get _totalAmount =>
      (_subtotal - _discount + _tax + _additionalCharges);

  bool get _isEditMode =>
      widget.creditNoteId != null || widget.creditNoteData != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // If in edit mode, fetch full credit note data from API
    if (widget.creditNoteId != null) {
      try {
        final creditNote =
            await _creditNoteService.getCreditNote(widget.creditNoteId!);

        setState(() {
          _creditNoteNumberController.text =
              creditNote.creditNoteNumber.toString();
          _creditNoteDate = creditNote.creditNoteDate;
          _selectedPartyId = creditNote.partyId;
          _selectedPartyName = creditNote.partyName;
          _invoiceSearchController.text =
              creditNote.invoiceNumber?.toString() ?? '';
          _linkedInvoiceNumber = creditNote.invoiceNumber;
          _notesController.text = creditNote.notes ?? '';
          _selectedBankAccountId = creditNote.bankAccountId;

          // Normalize payment mode to match dropdown values
          final mode = creditNote.paymentMode ?? 'cash';
          _paymentMode =
              mode[0].toUpperCase() + mode.substring(1).toLowerCase();
          _amountReceivedController.text = creditNote.amountReceived.toString();
          _isFullyPaid = creditNote.status == 'applied';

          // Load items from credit note
          if (creditNote.items != null && creditNote.items!.isNotEmpty) {
            _items = creditNote.items!.map((item) {
              return CreditNoteItemRow(
                itemId: item.itemId,
                itemName: item.itemName ?? 'Unknown Item',
                hsnSac: item.hsnSac,
                itemCode: item.itemCode,
                quantity: item.quantity,
                price: item.price,
                discount: item.discount,
                taxRate: item.taxRate,
                taxAmount: item.taxAmount,
              );
            }).toList();
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading credit note: $e')),
          );
        }
      }
    }

    // Load supporting data (parties, items, accounts)
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (orgProvider.selectedOrganization != null) {
      try {
        final token = await authProvider.token;
        if (token == null) return;

        // Get next credit note number only if not in edit mode
        if (!_isEditMode) {
          final nextNumberData = await _creditNoteService
              .getNextCreditNoteNumber(orgProvider.selectedOrganization!.id);
          _creditNoteNumberController.text =
              nextNumberData['next_number'].toString();
        }

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
    return DialogScaffold(
      title: _isEditMode ? 'Edit Credit Note' : 'Create Credit Note',
      onSave: _saveCreditNote,
      onSettings: () {
        Navigator.pushNamed(context, '/settings');
      },
      isSaving: _isSaving,
      saveButtonText: 'Save',
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
                                    onPressed: _showAdditionalChargesDialog,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Additional Charges'),
                                  ),
                                  Text(
                                      '₹ ${_additionalCharges.toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: _showDiscountDialog,
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
                                        // When unchecked, keep the current value
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
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _creditNoteNumberController,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Credit Note Date
                    const Text(
                      'Credit Note Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${_creditNoteDate.day} ${_getMonthName(_creditNoteDate.month)} ${_creditNoteDate.year}',
                            ),
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
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    const SizedBox(height: 4),
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

  Widget _buildItemRow(int index, CreditNoteItemRow item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('${index + 1}')),
          Expanded(flex: 3, child: Text(item.itemName)),
          Expanded(child: Text(item.hsnSac ?? '-')),
          Expanded(child: Text(item.quantity.toStringAsFixed(0))),
          Expanded(child: Text(item.price.toStringAsFixed(2))),
          Expanded(child: Text(item.discount.toStringAsFixed(2))),
          Expanded(child: Text('${item.taxRate.toStringAsFixed(0)}%')),
          Expanded(
              child: Text((item.price * item.quantity).toStringAsFixed(2))),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () {
                setState(() {
                  _items.removeAt(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPartySelectionDialog() async {
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
  }

  Future<void> _showAddItemDialog() async {
    final selectedItem = await showDialog<ItemModel>(
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
                    'Select Item',
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
                child: _availableItems.isEmpty
                    ? const Center(child: Text('No items found'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableItems.length,
                        itemBuilder: (context, index) {
                          final item = _availableItems[index];
                          return ListTile(
                            title: Text(item.itemName),
                            subtitle: Text('₹${item.sellingPrice}'),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedItem != null) {
      setState(() {
        _items.add(CreditNoteItemRow(
          itemId: selectedItem.id,
          itemName: selectedItem.itemName,
          hsnSac: selectedItem.hsnCode,
          itemCode: selectedItem.itemCode,
          quantity: 1,
          price: selectedItem.sellingPrice,
          discount: 0,
          taxRate: selectedItem.gstRate,
          taxAmount: (selectedItem.sellingPrice * selectedItem.gstRate) / 100,
        ));
      });
    }
  }

  void _showDiscountDialog() {
    final controller = TextEditingController(text: _discountAmount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Discount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Discount Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _discountAmount = double.tryParse(controller.text) ?? 0.0;
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAdditionalChargesDialog() {
    final controller =
        TextEditingController(text: _additionalCharges.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Additional Charges'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Additional Charges',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _additionalCharges = double.tryParse(controller.text) ?? 0.0;
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCreditNote() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an organization first')),
        );
      }
      return;
    }

    if (_selectedPartyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // Validate bank account for non-cash payments
    final amountReceived = double.tryParse(_amountReceivedController.text) ?? 0;
    if (amountReceived > 0 &&
        _paymentMode != 'Cash' &&
        _selectedBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a bank account for non-cash payment')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amountReceived =
          double.tryParse(_amountReceivedController.text) ?? 0;
      final status = amountReceived >= _totalAmount ? 'issued' : 'draft';

      final creditNoteData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedPartyId,
        // Only send credit_note_number when creating, not updating
        if (!_isEditMode)
          'credit_note_number': _creditNoteNumberController.text,
        'credit_note_date': _creditNoteDate.toIso8601String().split('T')[0],
        'invoice_number': _linkedInvoiceNumber,
        'subtotal': _subtotal,
        'discount': _discount,
        'tax': _tax,
        'total_amount': _totalAmount,
        'payment_mode': _paymentMode.toLowerCase(),
        if (_selectedBankAccountId != null)
          'bank_account_id': _selectedBankAccountId,
        'amount_received': amountReceived,
        'status': status,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'terms_conditions':
            '1. Goods once sold will not be taken back or exchanged\n2. All disputes are subject to [ENTER_YOUR_CITY_NAME] jurisdiction only',
        'items': _items.map((item) => item.toJson()).toList(),
      };

      // Debug logging
      print('=== CREDIT NOTE SAVE DEBUG ===');
      print('Is Edit Mode: $_isEditMode');
      print('Credit Note ID: ${widget.creditNoteId}');
      print('Credit Note Number: ${_creditNoteNumberController.text}');

      // Call update or create based on edit mode
      if (_isEditMode && widget.creditNoteId != null) {
        print('Calling UPDATE endpoint with ID: ${widget.creditNoteId}');
        await _creditNoteService.updateCreditNote(
            widget.creditNoteId!, creditNoteData);
      } else {
        print('Calling CREATE endpoint');
        await _creditNoteService.createCreditNote(creditNoteData);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditMode
                  ? 'Credit note updated successfully'
                  : 'Credit note created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating credit note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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

  @override
  void dispose() {
    _creditNoteNumberController.dispose();
    _invoiceSearchController.dispose();
    _notesController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }
}

class CreditNoteItemRow {
  final int itemId;
  final String itemName;
  final String? hsnSac;
  final String? itemCode;
  double quantity;
  final double price;
  final double discount;
  final double taxRate;
  final double taxAmount;

  CreditNoteItemRow({
    required this.itemId,
    required this.itemName,
    this.hsnSac,
    this.itemCode,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.taxRate,
    required this.taxAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'hsn_sac': hsnSac,
      'item_code': itemCode,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total': price * quantity,
    };
  }
}
