import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/purchase_return_service.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../services/bank_account_service.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../models/bank_account_model.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';

class CreatePurchaseReturnScreen extends StatefulWidget {
  const CreatePurchaseReturnScreen({super.key});

  @override
  State<CreatePurchaseReturnScreen> createState() =>
      _CreatePurchaseReturnScreenState();
}

class _CreatePurchaseReturnScreenState
    extends State<CreatePurchaseReturnScreen> {
  final PurchaseReturnService _returnService = PurchaseReturnService();
  final PartyService _partyService = PartyService();
  final ItemService _itemService = ItemService();
  final BankAccountService _bankAccountService = BankAccountService();

  final TextEditingController _returnNumberController =
      TextEditingController(text: '10');
  final TextEditingController _invoiceSearchController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _amountReceivedController =
      TextEditingController();

  DateTime _returnDate = DateTime.now();
  int? _selectedPartyId;
  String? _selectedPartyName;
  String? _linkedInvoiceNumber;
  bool _isSaving = false;
  bool _isFullyReceived = false;
  String _paymentMode = 'Cash';

  List<ReturnItem> _items = [];
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

        // Get next return number
        final nextNumber = await _returnService
            .getNextReturnNumber(orgProvider.selectedOrganization!.id);

        setState(() {
          _parties = parties;
          _availableItems = items;
          _bankAccounts = accounts;
          _returnNumberController.text = nextNumber;
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
          'Create Purchase Return',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save & New'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveReturn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
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
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier
                    const Text(
                      'Supplier',
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
                                    onPressed: () {},
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
                                    onPressed: () {},
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Additional Charges'),
                                  ),
                                  const Text('₹ 0'),
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
                                  labelText: 'Enter Refund amount',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isFullyReceived,
                                    onChanged: (value) {
                                      setState(() {
                                        _isFullyReceived = value ?? false;
                                        if (_isFullyReceived) {
                                          _amountReceivedController.text =
                                              _totalAmount.toStringAsFixed(2);
                                        }
                                      });
                                    },
                                  ),
                                  const Text('Mark as fully received'),
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
                    // Purchase Return No
                    const Text(
                      'Purchase Return No.',
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

                    // Purchase Return Date
                    const Text(
                      'Purchase Return Date',
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
                    'Select Supplier',
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
                    ? const Center(child: Text('No suppliers found'))
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
                            subtitle: Text('₹${item.purchasePrice}'),
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
          price: selectedItem.purchasePrice,
          discount: 0,
          taxRate: selectedItem.gstRate,
          taxAmount: (selectedItem.purchasePrice * selectedItem.gstRate) / 100,
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
        const SnackBar(content: Text('Please select a supplier')),
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
      final amountReceived =
          double.tryParse(_amountReceivedController.text) ?? 0;
      final status = amountReceived >= _totalAmount ? 'approved' : 'pending';

      final returnData = {
        'party_id': _selectedPartyId,
        'return_number': _returnNumberController.text,
        'return_date': _returnDate.toIso8601String().split('T')[0],
        'status': status,
        'payment_mode': _paymentMode.toLowerCase(),
        if (_selectedBankAccountId != null)
          'bank_account_id': _selectedBankAccountId,
        'amount_received': amountReceived,
        'reason': _notesController.text.isEmpty ? null : _notesController.text,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'items': _items
            .map((item) => {
                  'item_id': item.itemId,
                  'quantity': item.quantity,
                  'rate': item.price,
                  'tax_rate': item.taxRate,
                  'unit': 'pcs',
                })
            .toList(),
      };

      await _returnService.createPurchaseReturn(
        orgProvider.selectedOrganization!.id,
        returnData,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase return created successfully')),
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
    _amountReceivedController.dispose();
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
