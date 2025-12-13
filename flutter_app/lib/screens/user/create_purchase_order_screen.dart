import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/item_model.dart';
import '../../models/party_model.dart';
import '../../models/bank_account_model.dart';
import '../../providers/organization_provider.dart';
import '../../services/purchase_order_service.dart';
import '../../services/item_service.dart';
import '../../services/party_service.dart';
import '../../services/bank_account_service.dart';
import '../../core/utils/token_storage.dart';
import '../../widgets/dialog_scaffold.dart';
import 'parties_screen.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  final int? orderId;

  const CreatePurchaseOrderScreen({super.key, this.orderId});

  @override
  State<CreatePurchaseOrderScreen> createState() =>
      _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  final PurchaseOrderService _orderService = PurchaseOrderService();
  final ItemService _itemService = ItemService();
  final PartyService _partyService = PartyService();
  final BankAccountService _bankAccountService = BankAccountService();

  final TextEditingController _poNumberController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _additionalChargesController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();

  List<PartyModel> _parties = [];
  List<ItemModel> _items = [];
  List<BankAccount> _bankAccounts = [];
  List<OrderItem> _orderItems = [];

  PartyModel? _selectedParty;
  BankAccount? _selectedBankAccount;
  String? _paymentMode;
  DateTime _orderDate = DateTime.now();
  DateTime? _validTill;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _autoRoundOff = false;
  bool _fullyPaid = false;

  final List<String> _paymentModes = ['Cash', 'Card', 'UPI', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isLoading = true);

    try {
      // Load parties
      _parties =
          await _partyService.getParties(orgProvider.selectedOrganization!.id);

      // Load items
      final items =
          await _itemService.getItems(orgProvider.selectedOrganization!.id);
      _items = items;

      // Load bank accounts
      final token = await TokenStorage.getToken();
      if (token != null) {
        try {
          _bankAccounts = await _bankAccountService.getBankAccounts(
              token, orgProvider.selectedOrganization!.id);

          // Auto-select if only one bank account exists
          if (_bankAccounts.length == 1) {
            _selectedBankAccount = _bankAccounts[0];
          }
        } catch (e) {
          print('Error loading bank accounts: $e');
          // Continue without bank accounts
          _bankAccounts = [];
        }
      } else {
        print('No token found, skipping bank accounts');
        _bankAccounts = [];
      }

      // If editing, load order data
      if (widget.orderId != null) {
        final order = await _orderService.getPurchaseOrder(widget.orderId!);
        _loadOrderData(order);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _loadOrderData(Map<String, dynamic> orderData) {
    // Implementation for editing existing order
    // Will be populated when editing
  }

  double get _subtotal {
    return _orderItems.fold(
        0.0, (sum, item) => sum + (item.quantity * item.rate));
  }

  double get _taxAmount {
    return _orderItems.fold(
        0.0,
        (sum, item) =>
            sum + ((item.quantity * item.rate * item.taxRate) / 100));
  }

  double get _discount {
    return double.tryParse(_discountController.text) ?? 0.0;
  }

  double get _additionalCharges {
    return double.tryParse(_additionalChargesController.text) ?? 0.0;
  }

  double get _totalBeforeRound {
    return _subtotal + _taxAmount - _discount + _additionalCharges;
  }

  double get _roundOff {
    if (!_autoRoundOff) return 0.0;
    return _totalBeforeRound.roundToDouble() - _totalBeforeRound;
  }

  double get _totalAmount {
    return _totalBeforeRound + _roundOff;
  }

  void _addItem(ItemModel item) {
    setState(() {
      final existingIndex =
          _orderItems.indexWhere((oi) => oi.itemId == item.id);
      if (existingIndex >= 0) {
        _orderItems[existingIndex].quantity++;
      } else {
        _orderItems.add(OrderItem(
          itemId: item.id,
          itemName: item.itemName,
          itemCode: item.itemCode,
          hsnSac: item.hsnCode ?? '',
          quantity: 1,
          unit: item.unit ?? '',
          rate: item.purchasePrice,
          taxRate: item.gstRate,
        ));
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, double quantity) {
    if (quantity > 0) {
      setState(() {
        _orderItems[index].quantity = quantity;
      });
    }
  }

  void _updateRate(int index, double rate) {
    setState(() {
      _orderItems[index].rate = rate;
    });
  }

  Future<void> _savePurchaseOrder() async {
    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
      return;
    }

    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    if (_fullyPaid && _paymentMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment mode')),
      );
      return;
    }

    if (_fullyPaid &&
        _paymentMode != null &&
        _paymentMode != 'Cash' &&
        _selectedBankAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please select a bank account for $_paymentMode payment')),
      );
      return;
    }

    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization == null) return;

    setState(() => _isSaving = true);

    try {
      final items = _orderItems.map((item) {
        return {
          'item_id': item.itemId,
          'quantity': item.quantity,
          'unit': item.unit,
          'rate': item.rate,
          'tax_rate': item.taxRate,
          'discount_rate': 0,
        };
      }).toList();

      await _orderService.createPurchaseOrder(
        organizationId: orgProvider.selectedOrganization!.id,
        partyId: _selectedParty!.id,
        orderDate: DateFormat('yyyy-MM-dd').format(_orderDate),
        expectedDeliveryDate: _validTill != null
            ? DateFormat('yyyy-MM-dd').format(_validTill!)
            : null,
        items: items,
        discountAmount: _discount,
        additionalCharges: _additionalCharges,
        autoRoundOff: _autoRoundOff,
        fullyPaid: _fullyPaid,
        bankAccountId: _selectedBankAccount?.id,
        paymentMode: _paymentMode,
        paymentAmount: _paymentAmountController.text.isNotEmpty
            ? double.tryParse(_paymentAmountController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase order created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DialogScaffold(
      title: widget.orderId == null
          ? 'Create Purchase Order'
          : 'Edit Purchase Order',
      onSave: _savePurchaseOrder,
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
              // Left Side - Main Form
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPartySection(),
                    const SizedBox(height: 24),
                    _buildItemsSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    // Show bank details section when non-cash payment mode is selected
                    if (_paymentMode != null && _paymentMode != 'Cash') ...[
                      const SizedBox(height: 24),
                      _buildBankDetailsSection(),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Side - Order Details
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 16),
                    _buildTotalsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PO No.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _poNumberController,
              decoration: const InputDecoration(
                hintText: 'Auto-generated',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            const Text(
              'PO Date',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _orderDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _orderDate = date);
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
                      '${_orderDate.day} ${_getMonthName(_orderDate.month)} ${_orderDate.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Valid Till',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _validTill ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _validTill = date);
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
                      _validTill != null
                          ? '${_validTill!.day} ${_getMonthName(_validTill!.month)} ${_validTill!.year}'
                          : 'Select date',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildOldHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PO No.', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _poNumberController,
                  decoration: InputDecoration(
                    hintText: 'Auto-generated',
                    enabled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PO Date:', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _orderDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _orderDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd MMM yyyy').format(_orderDate)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Valid Till:', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _validTill ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _validTill = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _validTill != null
                              ? DateFormat('dd MMM yyyy').format(_validTill!)
                              : 'Select date',
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

  Widget _buildPartySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill From', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          if (_selectedParty == null)
            InkWell(
              onTap: () => _showPartySelector(),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.blue, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '+ Add Party',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedParty!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (_selectedParty!.phone != null)
                          Text(_selectedParty!.phone!),
                        if (_selectedParty!.email != null)
                          Text(_selectedParty!.email!),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showPartySelector(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showPartySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Party'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PartiesScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Party'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _parties.length,
                  itemBuilder: (context, index) {
                    final party = _parties[index];
                    return ListTile(
                      title: Text(party.name),
                      subtitle: Text(party.phone ?? ''),
                      onTap: () {
                        setState(() => _selectedParty = party);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Items Table Header
          Row(
            children: [
              const SizedBox(width: 40, child: Text('NO')),
              const Expanded(flex: 3, child: Text('ITEMS/SERVICES')),
              const Expanded(flex: 2, child: Text('HSN/SAC')),
              const Expanded(flex: 1, child: Text('QTY')),
              const Expanded(flex: 2, child: Text('PRICE/ITEM (₹)')),
              const Expanded(flex: 1, child: Text('DISCOUNT')),
              const Expanded(flex: 1, child: Text('TAX')),
              const Expanded(flex: 2, child: Text('AMOUNT (₹)')),
              const SizedBox(width: 80),
            ],
          ),
          const Divider(),
          // Items List
          if (_orderItems.isEmpty)
            InkWell(
              onTap: () => _showItemSelector(),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.blue, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '+ Add Item',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            )
          else
            ..._orderItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemRow(index, item);
            }),
          // Add Item Button
          if (_orderItems.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showItemSelector(),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          const SizedBox(height: 16),
          // Scan Barcode Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Barcode scanning functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barcode scanning coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('${index + 1}')),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(item.itemCode,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(item.hsnSac)),
          Expanded(
            flex: 1,
            child: TextField(
              controller: TextEditingController(text: item.quantity.toString()),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              onChanged: (value) {
                final qty = double.tryParse(value);
                if (qty != null) _updateQuantity(index, qty);
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller:
                  TextEditingController(text: item.rate.toStringAsFixed(2)),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              onChanged: (value) {
                final rate = double.tryParse(value);
                if (rate != null) _updateRate(index, rate);
              },
            ),
          ),
          const Expanded(flex: 1, child: Text('0%')),
          Expanded(flex: 1, child: Text('${item.taxRate}%')),
          Expanded(
            flex: 2,
            child: Text(
              '₹${(item.quantity * item.rate * (1 + item.taxRate / 100)).toStringAsFixed(2)}',
            ),
          ),
          SizedBox(
            width: 80,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeItem(index),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                title: Text(item.itemName),
                subtitle: Text('${item.itemCode} - ₹${item.purchasePrice}'),
                onTap: () {
                  _addItem(item);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalRow('SUBTOTAL', '₹${_subtotal.toStringAsFixed(2)}'),
            _buildTotalRow('TAX', '₹${_taxAmount.toStringAsFixed(2)}'),
            const Divider(height: 24),
            // Discount
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Discount'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: '- ₹ ',
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildTotalRow('Taxable Amount',
                '₹${(_subtotal - _discount).toStringAsFixed(2)}'),
            const Divider(height: 24),
            // Additional Charges
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Additional Charges'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _additionalChargesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Auto Round Off
            Row(
              children: [
                Checkbox(
                  value: _autoRoundOff,
                  onChanged: (value) {
                    setState(() => _autoRoundOff = value!);
                  },
                ),
                const Text('Auto Round Off'),
                const Spacer(),
                Text(
                  '₹ ${_roundOff.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            _buildTotalRow(
              'Total Amount',
              '₹${_totalAmount.toStringAsFixed(2)}',
              isBold: true,
            ),
            const SizedBox(height: 16),
            // Fully Paid Checkbox
            Row(
              children: [
                Checkbox(
                  value: _fullyPaid,
                  onChanged: (value) {
                    setState(() {
                      _fullyPaid = value!;
                      // Auto-fill payment amount with total when fully paid is checked
                      if (_fullyPaid) {
                        _paymentAmountController.text =
                            _totalAmount.toStringAsFixed(2);
                      }
                    });
                  },
                ),
                const Text('Fully Paid'),
              ],
            ),
            // Payment Mode Selection - Always visible
            const SizedBox(height: 16),
            const Text(
              'Mode of Payment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _paymentMode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Select payment mode',
              ),
              items: _paymentModes.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _paymentMode = value);
              },
            ),
            // Payment Amount Field - Always visible
            const SizedBox(height: 16),
            const Text(
              'Enter Payment amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _paymentAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, top: 12),
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintText: '',
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to show balance
              },
            ),
            // Show remaining balance if payment amount is different from total
            if (_paymentAmountController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final paymentAmount =
                      double.tryParse(_paymentAmountController.text) ?? 0.0;
                  final balance = _totalAmount - paymentAmount;
                  if (balance.abs() > 0.01) {
                    // Show balance if difference is more than 1 paisa
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: balance > 0
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: balance > 0 ? Colors.orange : Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            balance > 0 ? 'Balance Due:' : 'Excess Payment:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: balance > 0 ? Colors.orange : Colors.green,
                            ),
                          ),
                          Text(
                            '₹${balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: balance > 0 ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            // Bank Account Selection - Show for non-cash payments
            if (_paymentMode != null && _paymentMode != 'Cash') ...[
              const SizedBox(height: 8),
              if (_selectedBankAccount == null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showBankAccountSelector(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Bank Account'),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedBankAccount!.accountName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _selectedBankAccount!.bankAccountNo ?? 'N/A',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedBankAccount = null);
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showBankAccountSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bank Account'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _bankAccounts.length,
            itemBuilder: (context, index) {
              final account = _bankAccounts[index];
              return ListTile(
                title: Text(account.accountName),
                subtitle: Text(account.bankAccountNo ?? 'N/A'),
                onTap: () {
                  setState(() => _selectedBankAccount = account);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter any additional notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedBankAccount != null) ...[
            // Bank account details
            _buildBankDetailRow(
                'Bank Name:', _selectedBankAccount!.bankName ?? 'N/A'),
            const SizedBox(height: 8),
            _buildBankDetailRow('Account Number:',
                _selectedBankAccount!.bankAccountNo ?? 'N/A'),
            const SizedBox(height: 8),
            _buildBankDetailRow(
                'IFSC Code:', _selectedBankAccount!.ifscCode ?? 'N/A'),
            const SizedBox(height: 8),
            _buildBankDetailRow(
                'Account Holder:', _selectedBankAccount!.accountName),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                if (_bankAccounts.length > 1)
                  TextButton(
                    onPressed: () => _showBankAccountSelector(),
                    child: const Text('Change Bank Account'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedBankAccount = null);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Remove Bank Account'),
                ),
              ],
            ),
          ] else ...[
            // No bank account selected
            Center(
              child: Column(
                children: [
                  const Text(
                    'No bank account selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showBankAccountSelector(),
                    icon: const Icon(Icons.add),
                    label: const Text('Select Bank Account'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class OrderItem {
  final int itemId;
  final String itemName;
  final String itemCode;
  final String hsnSac;
  double quantity;
  final String unit;
  double rate;
  final double taxRate;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.hsnSac,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.taxRate,
  });
}
