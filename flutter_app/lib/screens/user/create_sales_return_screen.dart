import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sales_return_service.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../services/bank_account_service.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../models/bank_account_model.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dialog_scaffold.dart';

class CreateSalesReturnScreen extends StatefulWidget {
  final int? returnId;
  final Map<String, dynamic>? returnData;

  const CreateSalesReturnScreen({
    super.key,
    this.returnId,
    this.returnData,
  });

  @override
  State<CreateSalesReturnScreen> createState() =>
      _CreateSalesReturnScreenState();
}

class _CreateSalesReturnScreenState extends State<CreateSalesReturnScreen> {
  final SalesReturnService _returnService = SalesReturnService();

  final TextEditingController _returnNumberController =
      TextEditingController(text: '10');
  final TextEditingController _invoiceSearchController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();

  DateTime _returnDate = DateTime.now();
  int? _selectedPartyId;
  String? _selectedPartyName;
  String? _linkedInvoiceNumber;
  bool _isSaving = false;
  bool _isFullyPaid = false;
  String _paymentMode = 'Cash';

  List<ReturnItem> _items = [];
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

  bool get _isEditMode => widget.returnId != null || widget.returnData != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadNextReturnNumber();
  }

  Future<void> _loadInitialData() async {
    // Load parties, items, and bank accounts for selection dialogs
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (orgProvider.selectedOrganization != null) {
      try {
        final token = await authProvider.token;
        if (token == null) return;

        final partyService = PartyService();
        final itemService = ItemService();
        final bankAccountService = BankAccountService();

        final parties =
            await partyService.getParties(orgProvider.selectedOrganization!.id);
        final items =
            await itemService.getItems(orgProvider.selectedOrganization!.id);
        final accounts = await bankAccountService.getBankAccounts(
          token,
          orgProvider.selectedOrganization!.id,
        );

        debugPrint('📋 Loaded ${parties.length} parties');
        debugPrint('📋 Loaded ${items.length} items');
        debugPrint('📋 Loaded ${accounts.length} bank accounts');

        setState(() {
          _parties = parties;
          _availableItems = items;
          _bankAccounts = accounts;
        });

        debugPrint(
            '✅ Data set in state: parties=${_parties.length}, items=${_availableItems.length}');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading data: $e')),
          );
        }
      }
    }

    // Load existing return data if in edit mode
    if (widget.returnId != null) {
      // Fetch full return data from API using ID
      try {
        final result = await _returnService.getReturn(widget.returnId!);

        debugPrint('📦 Return loaded: ${result.returnNumber}');
        debugPrint('📦 Items count: ${result.items?.length ?? 0}');
        if (result.items != null) {
          for (var item in result.items!) {
            debugPrint(
                '  - Item: ${item.itemName ?? "Unknown"}, Qty: ${item.quantity}, Price: ${item.price}');
          }
        }

        setState(() {
          _returnNumberController.text = result.returnNumber;
          _returnDate = result.returnDate;
          _selectedPartyId = result.partyId;
          _selectedPartyName = result.partyName;
          _linkedInvoiceNumber = result.invoiceNumber;
          // Normalize payment mode to match dropdown values
          final mode = result.paymentMode ?? 'cash';
          _paymentMode =
              mode[0].toUpperCase() + mode.substring(1).toLowerCase();
          _amountPaidController.text = result.amountPaid.toString();
          _isFullyPaid = result.status == 'refunded';
          // Load items
          if (result.items != null && result.items!.isNotEmpty) {
            _items = result.items!.map((item) {
              return ReturnItem(
                itemId: item.itemId,
                itemName: item.itemName ?? 'Unknown Item',
                hsnSac: item.hsnSac ?? '',
                itemCode: item.itemCode ?? '',
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
            SnackBar(content: Text('Error loading return: $e')),
          );
        }
      }
    } else if (widget.returnData != null) {
      // Fallback to basic data
      setState(() {
        if (widget.returnData!['return_number'] != null) {
          _returnNumberController.text =
              widget.returnData!['return_number'].toString();
        }
        if (widget.returnData!['return_date'] != null) {
          _returnDate = DateTime.parse(widget.returnData!['return_date']);
        }
        if (widget.returnData!['party_id'] != null) {
          _selectedPartyId = widget.returnData!['party_id'];
        }
        if (widget.returnData!['party_name'] != null) {
          _selectedPartyName = widget.returnData!['party_name'];
        }
        if (widget.returnData!['invoice_number'] != null) {
          _linkedInvoiceNumber = widget.returnData!['invoice_number'];
        }
        if (widget.returnData!['payment_mode'] != null) {
          // Normalize payment mode to match dropdown values
          final mode = widget.returnData!['payment_mode'].toString();
          _paymentMode =
              mode[0].toUpperCase() + mode.substring(1).toLowerCase();
        }
        if (widget.returnData!['amount_paid'] != null) {
          _amountPaidController.text =
              widget.returnData!['amount_paid'].toString();
        }
      });
    }
  }

  Future<void> _loadNextReturnNumber() async {
    if (_isEditMode) return;
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    try {
      final nextNumberData = await _returnService.getNextReturnNumber(
        orgProvider.selectedOrganization!.id,
      );
      setState(() {
        _returnNumberController.text =
            nextNumberData['next_number']?.toString() ?? '1';
      });
    } catch (e) {
      // If error, keep default value
      debugPrint('Error loading next return number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: _isEditMode ? 'Edit Sales Return' : 'Create Sales Return',
      onSave: _saveReturn,
      onSettings: () {
        Navigator.pushNamed(context, '/settings');
      },
      isSaving: _isSaving,
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
                                Expanded(child: Text('ITEM CODE')),
                                Expanded(child: Text('MRP')),
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

                    // Notes and Terms
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
                                        '2. All disputes are subject to SURAT jurisdiction only'),
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
                                    onPressed: _showDiscountDialog,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Discount'),
                                  ),
                                  Text('- ₹ ${_discount.toStringAsFixed(2)}'),
                                ],
                              ),
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
                                controller: _amountPaidController,
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
                                          _amountPaidController.text =
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
                                  const Text('Amount Paid'),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountPaidController,
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
                    // Sales Return No
                    const Text(
                      'Sales Return No.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _returnNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sales Return Date
                    const Text(
                      'Sales Return Date',
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
                          initialDate: _returnDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _returnDate = date);
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
                              '${_returnDate.day} ${_getMonthName(_returnDate.month)} ${_returnDate.year}',
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

  Widget _buildItemRow(int index, ReturnItem item) {
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
          Expanded(child: Text(item.itemCode ?? '-')),
          Expanded(child: Text(item.price.toStringAsFixed(2))),
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
    debugPrint(
        '🔍 Opening party dialog. Parties available: ${_parties.length}');
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
        _items.add(ReturnItem(
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

  Future<void> _saveReturn() async {
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

    setState(() => _isSaving = true);

    try {
      final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
      final status = amountPaid >= _totalAmount ? 'refunded' : 'unpaid';

      final returnData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedPartyId,
        'return_number': _returnNumberController.text,
        'return_date': _returnDate.toIso8601String().split('T')[0],
        'invoice_number': _linkedInvoiceNumber,
        'subtotal': _subtotal,
        'discount': _discount,
        'tax': _tax,
        'total_amount': _totalAmount,
        'amount_paid': amountPaid,
        'payment_mode': _paymentMode.toLowerCase(),
        if (_selectedBankAccountId != null)
          'bank_account_id': _selectedBankAccountId,
        'status': status,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'terms_conditions':
            '1. Goods once sold will not be taken back or exchanged\n2. All disputes are subject to SURAT jurisdiction only',
        'items': _items.map((item) => item.toJson()).toList(),
      };

      await _returnService.createReturn(returnData);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sales return created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating return: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                _discountAmount = double.tryParse(controller.text) ?? 0;
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
                _additionalCharges = double.tryParse(controller.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
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

  @override
  void dispose() {
    _returnNumberController.dispose();
    _invoiceSearchController.dispose();
    _notesController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }
}

class ReturnItem {
  final int itemId;
  final String itemName;
  final String? hsnSac;
  final String? itemCode;
  double quantity;
  final double price;
  final double discount;
  final double taxRate;
  final double taxAmount;

  ReturnItem({
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
