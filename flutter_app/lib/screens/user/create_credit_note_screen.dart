import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/credit_note_service.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../providers/organization_provider.dart';

class CreateCreditNoteScreen extends StatefulWidget {
  const CreateCreditNoteScreen({super.key});

  @override
  State<CreateCreditNoteScreen> createState() => _CreateCreditNoteScreenState();
}

class _CreateCreditNoteScreenState extends State<CreateCreditNoteScreen> {
  final CreditNoteService _creditNoteService = CreditNoteService();
  final PartyService _partyService = PartyService();
  final ItemService _itemService = ItemService();

  final TextEditingController _creditNoteNumberController =
      TextEditingController(text: '1');
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _creditNoteDate = DateTime.now();
  int? _selectedPartyId;
  String? _selectedPartyName;
  String _status = 'draft';
  bool _isSaving = false;

  List<CreditNoteItem> _items = [];
  List<PartyModel> _parties = [];
  List<ItemModel> _availableItems = [];

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
    if (orgProvider.selectedOrganization != null) {
      try {
        final parties = await _partyService
            .getParties(orgProvider.selectedOrganization!.id);
        final items =
            await _itemService.getItems(orgProvider.selectedOrganization!.id);
        setState(() {
          _parties = parties;
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveCreditNote,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Party Selection
              const Text('Party Name',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showPartySelectionDialog,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_selectedPartyName ?? '+ Add Party'),
                ),
              ),
              const SizedBox(height: 16),

              // Credit Note Number
              const Text('Credit Note Number',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _creditNoteNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              // Status
              const Text('Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'issued', child: Text('Issued')),
                  DropdownMenuItem(value: 'applied', child: Text('Applied')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),

              // Reason
              const Text('Reason',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason for credit note',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),

              // Add Item Button
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Items List
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(item.itemName),
                    subtitle: Text('Qty: ${item.quantity} × ₹${item.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _items.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Total
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text('₹${_subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax:'),
                          Text('₹${_tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₹${_totalAmount.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPartySelectionDialog() async {
    final selectedParty = await showDialog<PartyModel>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Select Party',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
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
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Select Item',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
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
        _items.add(CreditNoteItem(
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

    setState(() => _isSaving = true);

    try {
      final creditNoteData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedPartyId,
        'credit_note_number': _creditNoteNumberController.text,
        'credit_note_date': _creditNoteDate.toIso8601String().split('T')[0],
        'subtotal': _subtotal,
        'discount': _discount,
        'tax': _tax,
        'total_amount': _totalAmount,
        'status': _status,
        'reason':
            _reasonController.text.isEmpty ? null : _reasonController.text,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'items': _items.map((item) => item.toJson()).toList(),
      };

      await _creditNoteService.createCreditNote(creditNoteData);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit note created successfully')),
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

  @override
  void dispose() {
    _creditNoteNumberController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class CreditNoteItem {
  final int itemId;
  final String itemName;
  final String? hsnSac;
  final String? itemCode;
  double quantity;
  final double price;
  final double discount;
  final double taxRate;
  final double taxAmount;

  CreditNoteItem({
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
