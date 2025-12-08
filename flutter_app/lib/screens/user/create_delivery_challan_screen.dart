import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/delivery_challan_service.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';

class CreateDeliveryChallanScreen extends StatefulWidget {
  const CreateDeliveryChallanScreen({super.key});

  @override
  State<CreateDeliveryChallanScreen> createState() =>
      _CreateDeliveryChallanScreenState();
}

class _CreateDeliveryChallanScreenState
    extends State<CreateDeliveryChallanScreen> {
  final DeliveryChallanService _challanService = DeliveryChallanService();
  final PartyService _partyService = PartyService();
  final ItemService _itemService = ItemService();

  final TextEditingController _challanNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _challanDate = DateTime.now();
  int? _selectedPartyId;
  String? _selectedPartyName;
  bool _isSaving = false;

  List<PartyModel> _parties = [];
  List<ItemModel> _availableItems = [];
  List<ChallanItemData> _items = [];

  String _termsConditions =
      '1. Goods once sold will not be taken back or exchanged\n2. All disputes are subject to [ENTER_YOUR_CITY_NAME] jurisdiction only';

  double get _subtotal {
    return _items.fold(0.0, (sum, item) {
      final itemTotal = item.quantity * item.price;
      final discount = itemTotal * (item.discountPercent / 100);
      return sum + (itemTotal - discount);
    });
  }

  double get _taxAmount {
    return _items.fold(0.0, (sum, item) {
      final itemTotal = item.quantity * item.price;
      final discount = itemTotal * (item.discountPercent / 100);
      final taxableAmount = itemTotal - discount;
      return sum + (taxableAmount * (item.taxPercent / 100));
    });
  }

  double get _totalAmount => _subtotal + _taxAmount;

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
      final nextNumber = await _challanService
          .getNextChallanNumber(orgProvider.selectedOrganization!.id);
      _challanNumberController.text = nextNumber.toString();

      final items =
          await _itemService.getItems(orgProvider.selectedOrganization!.id);
      setState(() {
        _availableItems = items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _showPartyDialog() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization == null) return;

    try {
      _parties =
          await _partyService.getParties(orgProvider.selectedOrganization!.id);

      if (!mounted) return;

      final party = await showDialog<PartyModel>(
        context: context,
        builder: (context) => _PartySelectionDialog(parties: _parties),
      );

      if (party != null) {
        setState(() {
          _selectedPartyId = party.id;
          _selectedPartyName = party.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        availableItems: _availableItems,
        onAdd: (item) {
          setState(() => _items.add(item));
        },
      ),
    );
  }

  Future<void> _save() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

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
      final data = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedPartyId,
        'challan_number': _challanNumberController.text,
        'challan_date': _challanDate.toIso8601String().split('T')[0],
        'subtotal': _subtotal,
        'tax_amount': _taxAmount,
        'total_amount': _totalAmount,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'terms_conditions': _termsConditions,
        'items': _items
            .map((item) => {
                  'item_id': item.itemId,
                  'item_name': item.itemName,
                  'hsn_sac': item.hsnSac,
                  'quantity': item.quantity,
                  'price': item.price,
                  'discount_percent': item.discountPercent,
                  'tax_percent': item.taxPercent,
                  'amount': item.amount,
                })
            .toList(),
      };

      print('DEBUG: Sending delivery challan data: $data');
      await _challanService.createDeliveryChallan(data);
      print('DEBUG: Delivery challan created successfully');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Delivery challan created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          'Create Delivery Challan',
          style: TextStyle(color: Colors.black),
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
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
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
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Delivery Challan'),
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
                    // Bill To
                    const Text('Bill To',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showPartyDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedPartyName ?? '+ Add Party',
                          style: TextStyle(
                            color: _selectedPartyName == null
                                ? AppColors.primaryDark
                                : Colors.black,
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
                          // Header
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
                                Expanded(child: Text('ITEMS/SERVICES')),
                                SizedBox(width: 80, child: Text('HSN/SAC')),
                                SizedBox(width: 60, child: Text('QTY')),
                                SizedBox(width: 100, child: Text('PRICE/ITEM')),
                                SizedBox(width: 80, child: Text('DISCOUNT')),
                                SizedBox(width: 60, child: Text('TAX')),
                                SizedBox(width: 100, child: Text('AMOUNT')),
                              ],
                            ),
                          ),
                          // Items
                          if (_items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(48),
                              child: TextButton.icon(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add),
                                label: const Text('+ Add Item'),
                              ),
                            )
                          else
                            ..._items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 40, child: Text('${index + 1}')),
                                    Expanded(child: Text(item.itemName)),
                                    SizedBox(
                                        width: 80,
                                        child: Text(item.hsnSac ?? '-')),
                                    SizedBox(
                                        width: 60,
                                        child: Text('${item.quantity}')),
                                    SizedBox(
                                        width: 100,
                                        child: Text('₹${item.price}')),
                                    SizedBox(
                                        width: 80,
                                        child:
                                            Text('${item.discountPercent}%')),
                                    SizedBox(
                                        width: 60,
                                        child: Text('${item.taxPercent}%')),
                                    SizedBox(
                                        width: 100,
                                        child: Text(
                                            '₹${NumberFormat('#,##,###.##').format(item.amount)}')),
                                  ],
                                ),
                              );
                            }),
                          if (_items.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _addItem,
                                  icon: const Icon(Icons.add),
                                  label: const Text('+ Add Item'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                'SUBTOTAL: ₹${NumberFormat('#,##,###.##').format(_subtotal)}'),
                            Text(
                                'TAX: ₹${NumberFormat('#,##,###.##').format(_taxAmount)}'),
                            const Divider(),
                            Text(
                              'TOTAL: ₹${NumberFormat('#,##,###.##').format(_totalAmount)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Side
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challan No
                    const Text('Challan No.'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _challanNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date
                    const Text('Challan Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _challanDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _challanDate = date);
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
                            Text(DateFormat('d MMM yyyy').format(_challanDate)),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add Notes'),
                    ),
                    const SizedBox(height: 16),

                    // Terms
                    const Text('Terms and Conditions'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_termsConditions),
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
    _challanNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class ChallanItemData {
  final int? itemId;
  final String itemName;
  final String? hsnSac;
  final double quantity;
  final double price;
  final double discountPercent;
  final double taxPercent;
  final double amount;

  ChallanItemData({
    this.itemId,
    required this.itemName,
    this.hsnSac,
    required this.quantity,
    required this.price,
    required this.discountPercent,
    required this.taxPercent,
    required this.amount,
  });
}

class _PartySelectionDialog extends StatelessWidget {
  final List<PartyModel> parties;

  const _PartySelectionDialog({required this.parties});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Party',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...parties.map((party) => ListTile(
                  title: Text(party.name),
                  subtitle: Text(party.phone),
                  onTap: () => Navigator.pop(context, party),
                )),
          ],
        ),
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final List<ItemModel> availableItems;
  final Function(ChallanItemData) onAdd;

  const _AddItemDialog({required this.availableItems, required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');
  ItemModel? _selectedItem;

  double get _amount {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final tax = double.tryParse(_taxController.text) ?? 0;
    final subtotal = qty * price;
    final afterDiscount = subtotal - (subtotal * discount / 100);
    return afterDiscount + (afterDiscount * tax / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<ItemModel>(
              value: _selectedItem,
              decoration: const InputDecoration(
                labelText: 'Select Item',
                border: OutlineInputBorder(),
              ),
              items: widget.availableItems
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.itemName),
                      ))
                  .toList(),
              onChanged: (item) {
                setState(() {
                  _selectedItem = item;
                  if (item != null) {
                    _priceController.text = item.sellingPrice.toString();
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _taxController,
                    decoration: const InputDecoration(
                      labelText: 'Tax %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Amount: ₹${NumberFormat('#,##,###.##').format(_amount)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedItem == null) return;
                    widget.onAdd(ChallanItemData(
                      itemId: _selectedItem!.id,
                      itemName: _selectedItem!.itemName,
                      hsnSac: _selectedItem!.hsnCode,
                      quantity: double.parse(_qtyController.text),
                      price: double.parse(_priceController.text),
                      discountPercent: double.parse(_discountController.text),
                      taxPercent: double.parse(_taxController.text),
                      amount: _amount,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
