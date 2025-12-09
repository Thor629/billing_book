import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/debit_note_service.dart';
import '../../services/party_service.dart';
import '../../services/bank_account_service.dart';
import '../../models/party_model.dart';
import '../../models/bank_account_model.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';

class CreateDebitNoteScreen extends StatefulWidget {
  const CreateDebitNoteScreen({super.key});

  @override
  State<CreateDebitNoteScreen> createState() => _CreateDebitNoteScreenState();
}

class _CreateDebitNoteScreenState extends State<CreateDebitNoteScreen> {
  final DebitNoteService _debitNoteService = DebitNoteService();
  final PartyService _partyService = PartyService();
  final BankAccountService _bankAccountService = BankAccountService();

  final TextEditingController _debitNoteNumberController =
      TextEditingController(text: 'DN-000001');
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  DateTime _debitNoteDate = DateTime.now();
  int? _selectedPartyId;
  String? _selectedPartyName;
  bool _isSaving = false;
  bool _isFullyPaid = false;
  String _paymentMode = 'Cash';

  List<DebitNoteItemRow> _items = [];
  List<PartyModel> _parties = [];
  List<BankAccount> _bankAccounts = [];
  int? _selectedBankAccountId;

  double get _subtotal => _items.fold(0, (sum, item) {
        final itemSubtotal = item.rate * item.quantity;
        return sum + itemSubtotal;
      });

  double get _tax => _items.fold(0, (sum, item) {
        final itemSubtotal = item.rate * item.quantity;
        final itemTax = itemSubtotal * (item.taxRate / 100);
        return sum + itemTax;
      });

  double get _totalAmount => _subtotal + _tax;

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
        final accounts = await _bankAccountService.getBankAccounts(
          token,
          orgProvider.selectedOrganization!.id,
        );

        // Get next debit note number
        final nextNumberData = await _debitNoteService
            .getNextDebitNoteNumber(orgProvider.selectedOrganization!.id);

        setState(() {
          _parties = parties;
          _bankAccounts = accounts;
          _debitNoteNumberController.text =
              nextNumberData['next_number'] ?? 'DN-000001';
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
          'Create Debit Note',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          ElevatedButton(
            onPressed: _isSaving ? null : _saveDebitNote,
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
                    // Supplier Selection
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
                            _selectedPartyName ?? '+ Add Supplier',
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

                    // Reason
                    const Text(
                      'Reason for Debit Note',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Additional charges, Quality issues',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
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
                                Expanded(flex: 3, child: Text('DESCRIPTION')),
                                Expanded(child: Text('QTY')),
                                Expanded(child: Text('RATE (₹)')),
                                Expanded(child: Text('TAX %')),
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

                    // Notes Section
                    const Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
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
                    // Debit Note No
                    const Text(
                      'Debit Note No.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _debitNoteNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Debit Note Date
                    const Text(
                      'Debit Note Date',
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
                          initialDate: _debitNoteDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _debitNoteDate = date);
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
                              '${_debitNoteDate.day} ${_getMonthName(_debitNoteDate.month)} ${_debitNoteDate.year}',
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '₹ ${_totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text(
                            'Amount Paid',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _amountPaidController,
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              hintText: '0.00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                                  });
                                },
                              ),
                              const Text('Mark as fully paid'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Payment Mode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _paymentMode,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Cash', child: Text('Cash')),
                              DropdownMenuItem(
                                  value: 'Bank Transfer',
                                  child: Text('Bank Transfer')),
                              DropdownMenuItem(
                                  value: 'Cheque', child: Text('Cheque')),
                              DropdownMenuItem(
                                  value: 'UPI', child: Text('UPI')),
                              DropdownMenuItem(
                                  value: 'Card', child: Text('Card')),
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
                          // Bank Account Selection (if not cash)
                          if (_paymentMode != 'Cash' &&
                              _bankAccounts.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Bank Account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _selectedBankAccountId,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
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
                                setState(() => _selectedBankAccountId = value);
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: Colors.orange[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Payment will decrease your balance',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildItemRow(int index, DebitNoteItemRow item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('${index + 1}')),
          Expanded(flex: 3, child: Text(item.description)),
          Expanded(child: Text(item.quantity.toStringAsFixed(2))),
          Expanded(child: Text(item.rate.toStringAsFixed(2))),
          Expanded(child: Text('${item.taxRate.toStringAsFixed(0)}%')),
          Expanded(
              child: Text(
                  ((item.rate * item.quantity) * (1 + item.taxRate / 100))
                      .toStringAsFixed(2))),
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
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final rateController = TextEditingController();
    final taxRateController = TextEditingController(text: '0');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Item',
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
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: rateController,
                      decoration: const InputDecoration(
                        labelText: 'Rate (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: taxRateController,
                decoration: const InputDecoration(
                  labelText: 'Tax Rate (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (descriptionController.text.isEmpty ||
                          rateController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all fields')),
                        );
                        return;
                      }
                      Navigator.pop(context, {
                        'description': descriptionController.text,
                        'quantity':
                            double.tryParse(quantityController.text) ?? 1,
                        'rate': double.tryParse(rateController.text) ?? 0,
                        'tax_rate':
                            double.tryParse(taxRateController.text) ?? 0,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _items.add(DebitNoteItemRow(
          description: result['description'],
          quantity: result['quantity'],
          unit: 'pcs',
          rate: result['rate'],
          taxRate: result['tax_rate'],
        ));
      });
    }
  }

  Future<void> _saveDebitNote() async {
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

    // Validate bank account for non-cash payments
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    if (amountPaid > 0 &&
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
      final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
      final status = amountPaid >= _totalAmount ? 'issued' : 'draft';

      final debitNoteData = {
        'party_id': _selectedPartyId,
        'debit_note_number': _debitNoteNumberController.text,
        'debit_note_date': _debitNoteDate.toIso8601String().split('T')[0],
        'payment_mode': _paymentMode.toLowerCase().replaceAll(' ', '_'),
        if (_selectedBankAccountId != null)
          'bank_account_id': _selectedBankAccountId,
        'amount_paid': amountPaid,
        'status': status,
        'reason':
            _reasonController.text.isEmpty ? null : _reasonController.text,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'items': _items.map((item) => item.toJson()).toList(),
      };

      await _debitNoteService.createDebitNote(
        orgProvider.selectedOrganization!.id,
        debitNoteData,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debit note created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating debit note: $e')),
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
    _debitNoteNumberController.dispose();
    _notesController.dispose();
    _amountPaidController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}

class DebitNoteItemRow {
  final String description;
  double quantity;
  final String unit;
  final double rate;
  final double taxRate;

  DebitNoteItemRow({
    required this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.taxRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'tax_rate': taxRate,
    };
  }
}
