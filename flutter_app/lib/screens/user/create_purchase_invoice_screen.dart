import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../models/bank_account_model.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../services/bank_account_service.dart';
import '../../services/purchase_invoice_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../widgets/dialog_scaffold.dart';

class PurchaseInvoiceItem {
  final ItemModel item;
  double quantity;
  double pricePerUnit;
  double discountPercent;
  double taxPercent;

  PurchaseInvoiceItem({
    required this.item,
    this.quantity = 1,
    double? pricePerUnit,
    this.discountPercent = 0,
    double? taxPercent,
  })  : pricePerUnit = pricePerUnit ?? item.purchasePrice,
        taxPercent = taxPercent ?? item.gstRate;

  double get subtotal => quantity * pricePerUnit;
  double get discountAmount => subtotal * (discountPercent / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxPercent / 100);
  double get lineTotal => taxableAmount + taxAmount;
}

class CreatePurchaseInvoiceScreen extends StatefulWidget {
  final int? invoiceId;
  final Map<String, dynamic>? invoiceData;

  const CreatePurchaseInvoiceScreen({
    super.key,
    this.invoiceId,
    this.invoiceData,
  });

  @override
  State<CreatePurchaseInvoiceScreen> createState() =>
      _CreatePurchaseInvoiceScreenState();
}

class _CreatePurchaseInvoiceScreenState
    extends State<CreatePurchaseInvoiceScreen> {
  final TextEditingController _invoiceNumberController =
      TextEditingController(text: '1');
  final TextEditingController _paymentTermsController =
      TextEditingController(text: '30');

  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  // Party and Items
  PartyModel? _selectedParty;
  List<PurchaseInvoiceItem> _invoiceItems = [];

  // Bank Accounts
  BankAccount? _selectedBankAccount;
  List<BankAccount> _bankAccounts = [];

  // Discount and Charges
  double _discountAmount = 0;
  double _additionalCharges = 0;

  // Payment
  final TextEditingController _paymentAmountController =
      TextEditingController(text: '0');
  bool _markAsFullyPaid = false;

  bool _isLoading = false;

  bool get _isEditMode =>
      widget.invoiceId != null || widget.invoiceData != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadBankAccounts();
    _loadNextInvoiceNumber();
  }

  Future<void> _loadInitialData() async {
    // Load from widget data if in edit mode
    if (widget.invoiceData != null) {
      setState(() {
        if (widget.invoiceData!['invoice_number'] != null) {
          _invoiceNumberController.text =
              widget.invoiceData!['invoice_number'].toString();
        }
        if (widget.invoiceData!['invoice_date'] != null) {
          _invoiceDate = DateTime.parse(widget.invoiceData!['invoice_date']);
        }
        if (widget.invoiceData!['due_date'] != null) {
          _dueDate = DateTime.parse(widget.invoiceData!['due_date']);
        }
      });
    }
  }

  Future<void> _loadNextInvoiceNumber() async {
    if (_isEditMode) return;
    try {
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization == null) return;

      final purchaseInvoiceService = PurchaseInvoiceService();
      final result = await purchaseInvoiceService
          .getNextInvoiceNumber(orgProvider.selectedOrganization!.id);
      setState(() {
        _invoiceNumberController.text = result['next_number'].toString();
      });
    } catch (e) {
      debugPrint('Error loading next invoice number: $e');
    }
  }

  Future<void> _loadBankAccounts() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization == null) {
        setState(() => _isLoading = false);
        return;
      }

      final token = await authProvider.token;
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final bankAccountService = BankAccountService();
      final accounts = await bankAccountService.getBankAccounts(
        token,
        orgProvider.selectedOrganization!.id,
      );

      setState(() {
        _bankAccounts = accounts;
        if (accounts.isNotEmpty) {
          _selectedBankAccount = accounts.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bank accounts: $e')),
        );
      }
    }
  }

  double get _subtotal =>
      _invoiceItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get _totalDiscount =>
      _invoiceItems.fold(0.0, (sum, item) => sum + item.discountAmount) +
      _discountAmount;

  double get _totalTax =>
      _invoiceItems.fold(0.0, (sum, item) => sum + item.taxAmount);

  double get _totalAmount =>
      _subtotal - _discountAmount + _totalTax + _additionalCharges;

  Future<void> _showPartySelectionDialog() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization first')),
      );
      return;
    }

    final partyService = PartyService();

    try {
      final parties = await partyService.getParties(
        orgProvider.selectedOrganization!.id,
      );

      // Filter for vendors only
      final vendors = parties
          .where((party) =>
              party.partyType == 'vendor' || party.partyType == 'both')
          .toList();

      if (!mounted) return;

      final selectedParty = await showDialog<PartyModel>(
        context: context,
        builder: (context) => _PartySearchDialog(parties: vendors),
      );

      if (selectedParty != null) {
        setState(() => _selectedParty = selectedParty);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading parties: $e')),
        );
      }
    }
  }

  Future<void> _showItemSelectionDialog() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization first')),
      );
      return;
    }

    final itemService = ItemService();

    try {
      final items = await itemService.getItems(
        orgProvider.selectedOrganization!.id,
      );

      if (!mounted) return;

      final selectedItem = await showDialog<ItemModel>(
        context: context,
        builder: (context) => _ItemSearchDialog(items: items),
      );

      if (selectedItem != null) {
        setState(() {
          _invoiceItems.add(PurchaseInvoiceItem(item: selectedItem));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  Future<void> _showDiscountDialog() async {
    final controller = TextEditingController(text: _discountAmount.toString());

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Discount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Discount Amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              Navigator.pop(context, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _discountAmount = result);
    }
  }

  Future<void> _showAdditionalChargesDialog() async {
    final controller =
        TextEditingController(text: _additionalCharges.toString());

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Additional Charges'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Additional Charges',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              Navigator.pop(context, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _additionalCharges = result);
    }
  }

  Future<void> _savePurchaseInvoice() async {
    // Validation
    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vendor')),
      );
      return;
    }

    if (_invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization == null) {
        throw Exception('No organization selected');
      }

      final amountPaid = double.tryParse(_paymentAmountController.text) ?? 0;

      final invoiceData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedParty!.id,
        'invoice_number': _invoiceNumberController.text,
        'invoice_date': _invoiceDate.toIso8601String(),
        'payment_terms': int.tryParse(_paymentTermsController.text) ?? 30,
        'due_date': _dueDate.toIso8601String(),
        'subtotal': _subtotal,
        'discount_amount': _discountAmount,
        'tax_amount': _totalTax,
        'additional_charges': _additionalCharges,
        'total_amount': _totalAmount,
        'bank_account_id': _selectedBankAccount?.id,
        'amount_paid': amountPaid,
        'items': _invoiceItems.map((item) {
          return {
            'item_id': item.item.id,
            'quantity': item.quantity,
            'price_per_unit': item.pricePerUnit,
            'discount_percent': item.discountPercent,
            'tax_percent': item.taxPercent,
            'subtotal': item.subtotal,
            'discount_amount': item.discountAmount,
            'taxable_amount': item.taxableAmount,
            'tax_amount': item.taxAmount,
            'line_total': item.lineTotal,
          };
        }).toList(),
      };

      // Debug: Print the data being sent
      debugPrint('Sending invoice data: $invoiceData');

      final purchaseInvoiceService = PurchaseInvoiceService();
      await purchaseInvoiceService.createPurchaseInvoice(invoiceData);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase invoice saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving purchase invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: _isEditMode ? 'Edit Purchase Invoice' : 'Create Purchase Invoice',
      onSave: _savePurchaseInvoice,
      onSettings: () {
        Navigator.pushNamed(context, '/settings');
      },
      isSaving: _isLoading,
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
                    // Bill From Section
                    _buildBillFromSection(),
                    const SizedBox(height: 24),

                    // Items Table
                    _buildItemsTable(),
                    const SizedBox(height: 24),

                    // Notes and Terms
                    _buildNotesSection(),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Side - Invoice Details
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInvoiceDetailsCard(),
                    const SizedBox(height: 16),
                    _buildTotalsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillFromSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bill From',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_selectedParty != null)
                TextButton(
                  onPressed: _showPartySelectionDialog,
                  child: const Text('Change Party'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedParty == null)
            InkWell(
              onTap: _showPartySelectionDialog,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.blue, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '+ Add Party',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedParty!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Phone: ${_selectedParty!.phone}'),
                  if (_selectedParty!.email != null)
                    Text('Email: ${_selectedParty!.email}'),
                  if (_selectedParty!.billingAddress != null)
                    Text('Address: ${_selectedParty!.billingAddress}'),
                  if (_selectedParty!.gstNo != null)
                    Text('GST: ${_selectedParty!.gstNo}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
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
                Expanded(flex: 3, child: Text('ITEMS/ SERVICES')),
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
          // Item Rows
          ..._invoiceItems.asMap().entries.map((entry) {
            final index = entry.key;
            final invoiceItem = entry.value;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text('${index + 1}'),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(invoiceItem.item.itemName),
                  ),
                  Expanded(
                    child: Text(invoiceItem.item.hsnCode ?? '-'),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: invoiceItem.quantity.toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          invoiceItem.quantity = double.tryParse(value) ?? 1;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: invoiceItem.pricePerUnit.toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          invoiceItem.pricePerUnit =
                              double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: invoiceItem.discountPercent.toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          invoiceItem.discountPercent =
                              double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Text('${invoiceItem.taxPercent}%'),
                  ),
                  Expanded(
                    child: Text('₹${invoiceItem.lineTotal.toStringAsFixed(2)}'),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () {
                        setState(() {
                          _invoiceItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          // Add Item Row
          InkWell(
            onTap: _showItemSelectionDialog,
            child: Container(
              padding: const EdgeInsets.all(40),
              child: const Center(
                child: Text(
                  '+ Add Item',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // Subtotal Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('SUBTOTAL'),
                const SizedBox(width: 100),
                Text('₹${_subtotal.toStringAsFixed(2)}'),
                const SizedBox(width: 50),
                Text('₹${_totalTax.toStringAsFixed(2)}'),
                const SizedBox(width: 50),
                Text('₹${(_subtotal + _totalTax).toStringAsFixed(2)}'),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Notes'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Terms and Conditions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Goods once sold will not be taken back or exchanged',
                style: TextStyle(fontSize: 13),
              ),
              const Text(
                '2. All disputes are subject to [CITY] jurisdiction only',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Purchase Inv No.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Purchase Inv Date',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _invoiceDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _invoiceDate = date);
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
                      '${_invoiceDate.day} ${_getMonthName(_invoiceDate.month)} ${_invoiceDate.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Terms',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _paymentTermsController,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final days = int.tryParse(value) ?? 30;
                                setState(() {
                                  _dueDate =
                                      _invoiceDate.add(Duration(days: days));
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('days'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Due Date',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _dueDate = date);
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
                      '${_dueDate.day} ${_getMonthName(_dueDate.month)} ${_dueDate.year}',
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

  Widget _buildTotalsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('SUBTOTAL', '₹${_subtotal.toStringAsFixed(2)}'),
            if (_totalDiscount > 0)
              _buildTotalRow(
                  'Discount', '-₹${_totalDiscount.toStringAsFixed(2)}',
                  color: Colors.red),
            if (_additionalCharges > 0)
              _buildTotalRow('Additional Charges',
                  '₹${_additionalCharges.toStringAsFixed(2)}',
                  color: Colors.green),
            _buildTotalRow('Tax', '₹${_totalTax.toStringAsFixed(2)}'),
            const Divider(height: 24),
            TextButton.icon(
              onPressed: _showDiscountDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(_discountAmount > 0
                  ? 'Discount: ₹${_discountAmount.toStringAsFixed(2)}'
                  : 'Add Discount'),
            ),
            TextButton.icon(
              onPressed: _showAdditionalChargesDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(_additionalCharges > 0
                  ? 'Charges: ₹${_additionalCharges.toStringAsFixed(2)}'
                  : 'Add Additional Charges'),
            ),
            const Divider(height: 24),
            _buildTotalRow('Taxable Amount',
                '₹${(_subtotal - _discountAmount).toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildTotalRow(
              'Total Amount',
              '₹${_totalAmount.toStringAsFixed(2)}',
              isBold: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentAmountController,
              decoration: const InputDecoration(
                labelText: 'Enter Payment amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              enabled: !_markAsFullyPaid,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _markAsFullyPaid,
                  onChanged: (value) {
                    setState(() {
                      _markAsFullyPaid = value ?? false;
                      if (_markAsFullyPaid) {
                        _paymentAmountController.text =
                            _totalAmount.toStringAsFixed(2);
                      }
                      // When unchecked, keep the current value (don't set to 0)
                    });
                  },
                ),
                const Text('Mark as fully paid'),
              ],
            ),
            const SizedBox(height: 16),
            // Bank Account Selection
            if (_bankAccounts.isNotEmpty) ...[
              const Text(
                'Bank Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BankAccount>(
                value: _selectedBankAccount,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _bankAccounts.map((account) {
                  return DropdownMenuItem(
                    value: account,
                    child: Text(
                      '${account.accountName} - ₹${account.currentBalance.toStringAsFixed(2)}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedBankAccount = value);
                },
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
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
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
    _invoiceNumberController.dispose();
    _paymentTermsController.dispose();
    _paymentAmountController.dispose();
    super.dispose();
  }
}

// Searchable Party Selection Dialog
class _PartySearchDialog extends StatefulWidget {
  final List<PartyModel> parties;

  const _PartySearchDialog({required this.parties});

  @override
  State<_PartySearchDialog> createState() => _PartySearchDialogState();
}

class _PartySearchDialogState extends State<_PartySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<PartyModel> _filteredParties = [];

  @override
  void initState() {
    super.initState();
    _filteredParties = widget.parties;
    _searchController.addListener(_filterParties);
  }

  void _filterParties() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParties = widget.parties.where((party) {
        return party.name.toLowerCase().contains(query) ||
            party.phone.toLowerCase().contains(query) ||
            (party.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Vendor'),
      content: SizedBox(
        width: 500,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredParties.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No vendors found'
                            : 'No vendors match your search',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredParties.length,
                      itemBuilder: (context, index) {
                        final party = _filteredParties[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primaryDark.withOpacity(0.1),
                            child: Text(
                              party.name[0].toUpperCase(),
                              style: TextStyle(color: AppColors.primaryDark),
                            ),
                          ),
                          title: Text(
                            party.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(party.phone),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              party.partyTypeLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(context, party),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// Searchable Item Selection Dialog
class _ItemSearchDialog extends StatefulWidget {
  final List<ItemModel> items;

  const _ItemSearchDialog({required this.items});

  @override
  State<_ItemSearchDialog> createState() => _ItemSearchDialogState();
}

class _ItemSearchDialogState extends State<_ItemSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ItemModel> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return item.itemName.toLowerCase().contains(query) ||
            item.itemCode.toLowerCase().contains(query) ||
            (item.hsnCode?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Item'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, code, or HSN...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No items found'
                            : 'No items match your search',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            child: const Icon(Icons.inventory_2,
                                color: Colors.green),
                          ),
                          title: Text(
                            item.itemName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Code: ${item.itemCode} | Purchase Price: ₹${item.purchasePrice}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Stock: ${item.stockQty}',
                                style: TextStyle(
                                  color: item.stockQty > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.hsnCode != null)
                                Text(
                                  'HSN: ${item.hsnCode}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                            ],
                          ),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
