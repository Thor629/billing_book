import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../models/bank_account_model.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../services/bank_account_service.dart';
import '../../services/sales_invoice_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';

class CreateSalesInvoiceScreen extends StatefulWidget {
  const CreateSalesInvoiceScreen({super.key});

  @override
  State<CreateSalesInvoiceScreen> createState() =>
      _CreateSalesInvoiceScreenState();
}

class InvoiceItem {
  final ItemModel item;
  double quantity;
  double pricePerUnit;
  double discountPercent;
  double taxPercent;

  InvoiceItem({
    required this.item,
    this.quantity = 1,
    double? pricePerUnit,
    this.discountPercent = 0,
    double? taxPercent,
  })  : pricePerUnit = pricePerUnit ?? item.sellingPrice,
        taxPercent = taxPercent ?? item.gstRate;

  double get subtotal => quantity * pricePerUnit;
  double get discountAmount => subtotal * (discountPercent / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxPercent / 100);
  double get lineTotal => taxableAmount + taxAmount;
}

class _CreateSalesInvoiceScreenState extends State<CreateSalesInvoiceScreen> {
  final TextEditingController _invoicePrefixController =
      TextEditingController(text: 'SHI');
  final TextEditingController _invoiceNumberController =
      TextEditingController(text: '101');
  final TextEditingController _paymentTermsController =
      TextEditingController(text: '30');
  final TextEditingController _amountReceivedController =
      TextEditingController(text: '0');

  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _showBankDetails = true;
  bool _autoRoundOff = false;
  bool _markAsFullyPaid = false;
  String _paymentMode = 'Cash';

  // New state variables
  PartyModel? _selectedParty;
  BankAccount? _selectedBankAccount;
  List<InvoiceItem> _invoiceItems = [];
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
    _loadNextInvoiceNumber();
  }

  Future<void> _loadNextInvoiceNumber() async {
    try {
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (orgProvider.selectedOrganization == null) {
        return;
      }

      final invoiceService = SalesInvoiceService();
      final result = await invoiceService.getNextInvoiceNumber(
        organizationId: orgProvider.selectedOrganization!.id,
        prefix: _invoicePrefixController.text,
      );

      if (mounted) {
        setState(() {
          _invoiceNumberController.text = result['next_number'].toString();
        });
      }
    } catch (e) {
      // If error, keep the default value
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch next invoice number: $e')),
        );
      }
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

      // Get the authentication token
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
          _showBankDetails = true;
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
      _invoiceItems.fold(0, (sum, item) => sum + item.subtotal);
  double get _totalDiscount =>
      _invoiceItems.fold(0, (sum, item) => sum + item.discountAmount);
  double get _totalTax =>
      _invoiceItems.fold(0, (sum, item) => sum + item.taxAmount);
  double get _totalAmount =>
      _invoiceItems.fold(0, (sum, item) => sum + item.lineTotal);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          'Create Sales Invoice',
          style: TextStyle(color: Colors.black),
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
            onPressed: _isLoading ? null : _saveAndNew,
            child: const Text('Save & New'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
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
              // Left Side - Main Form
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill To Section
                    _buildBillToSection(),
                    const SizedBox(height: 24),

                    // Items Table
                    _buildItemsTable(),
                    const SizedBox(height: 24),

                    // Notes and Terms
                    _buildNotesSection(),
                    const SizedBox(height: 24),

                    // Bank Details
                    if (_showBankDetails) _buildBankDetails(),
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

  Widget _buildBillToSection() {
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
                'Bill To',
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
                  if (_selectedParty!.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Phone: ${_selectedParty!.phone}'),
                  ],
                  if (_selectedParty!.email != null) ...[
                    const SizedBox(height: 4),
                    Text('Email: ${_selectedParty!.email}'),
                  ],
                  if (_selectedParty!.gstNo != null) ...[
                    const SizedBox(height: 4),
                    Text('GST: ${_selectedParty!.gstNo}'),
                  ],
                  if (_selectedParty!.billingAddress != null) ...[
                    const SizedBox(height: 4),
                    Text('Address: ${_selectedParty!.billingAddress}'),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

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

      if (!mounted) return;

      final selectedParty = await showDialog<PartyModel>(
        context: context,
        builder: (context) => _PartySearchDialog(parties: parties),
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
          // Item Rows
          if (_invoiceItems.isNotEmpty)
            ..._invoiceItems.asMap().entries.map((entry) {
              final index = entry.key;
              final invoiceItem = entry.value;
              return _buildItemRow(index, invoiceItem);
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
                Text('₹${_totalDiscount.toStringAsFixed(2)}'),
                const SizedBox(width: 50),
                Text('₹${_totalTax.toStringAsFixed(2)}'),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, InvoiceItem invoiceItem) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('${index + 1}')),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoiceItem.item.itemName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (invoiceItem.item.description != null)
                  Text(
                    invoiceItem.item.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Expanded(child: Text(invoiceItem.item.hsnCode ?? '-')),
          Expanded(child: Text(invoiceItem.item.itemCode)),
          Expanded(child: Text('₹${invoiceItem.item.mrp.toStringAsFixed(2)}')),
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
                final qty = double.tryParse(value) ?? 1;
                setState(() => invoiceItem.quantity = qty);
              },
            ),
          ),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: invoiceItem.pricePerUnit.toStringAsFixed(2),
              ),
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0;
                setState(() => invoiceItem.pricePerUnit = price);
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
                text: invoiceItem.discountPercent.toStringAsFixed(2),
              ),
              onChanged: (value) {
                final discount = double.tryParse(value) ?? 0;
                setState(() => invoiceItem.discountPercent = discount);
              },
            ),
          ),
          Expanded(
            child: Text('${invoiceItem.taxPercent.toStringAsFixed(0)}%'),
          ),
          Expanded(
            child: Text('₹${invoiceItem.lineTotal.toStringAsFixed(2)}'),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () {
                setState(() => _invoiceItems.removeAt(index));
              },
            ),
          ),
        ],
      ),
    );
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
          _invoiceItems.add(InvoiceItem(item: selectedItem));
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
                '2. All disputes are subject to SURAT jurisdiction only',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetails() {
    if (_selectedBankAccount == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedBankAccount!.bankAccountNo != null)
            _buildDetailRow(
              'Account Number:',
              _selectedBankAccount!.bankAccountNo!,
            ),
          if (_selectedBankAccount!.ifscCode != null)
            _buildDetailRow('IFSC Code:', _selectedBankAccount!.ifscCode!),
          if (_selectedBankAccount!.bankName != null ||
              _selectedBankAccount!.branchName != null)
            _buildDetailRow(
              'Bank & Branch Name:',
              '${_selectedBankAccount!.bankName ?? ''} ${_selectedBankAccount!.branchName != null ? ',${_selectedBankAccount!.branchName}' : ''}',
            ),
          if (_selectedBankAccount!.accountHolderName != null)
            _buildDetailRow(
              'Account Holder\'s Name:',
              _selectedBankAccount!.accountHolderName!,
            ),
          if (_selectedBankAccount!.upiId != null)
            _buildDetailRow('UPI ID:', _selectedBankAccount!.upiId!),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_bankAccounts.length > 1)
                TextButton(
                  onPressed: _showBankAccountSelectionDialog,
                  child: const Text('Change Bank Account'),
                ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showBankDetails = false;
                    _selectedBankAccount = null;
                  });
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove Bank Account'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showBankAccountSelectionDialog() async {
    if (_bankAccounts.isEmpty) return;

    final selectedAccount = await showDialog<BankAccount>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bank Account'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: _bankAccounts.length,
            itemBuilder: (context, index) {
              final account = _bankAccounts[index];
              return ListTile(
                title: Text(account.accountName),
                subtitle: Text(
                  account.bankAccountNo ?? 'Cash Account',
                ),
                trailing: Text(
                  '₹${account.currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pop(context, account),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedAccount != null) {
      setState(() {
        _selectedBankAccount = selectedAccount;
        _showBankDetails = true;
      });
    }
  }

  Widget _buildInvoiceDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice Prefix',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _invoicePrefixController,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice Number',
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sales Invoice Date',
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
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('days'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                style: const TextStyle(fontSize: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    final amountReceived = double.tryParse(_amountReceivedController.text) ?? 0;
    final balanceAmount = _totalAmount - amountReceived;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.qr_code_scanner, size: 40),
                SizedBox(width: 12),
                Text('Scan Barcode'),
              ],
            ),
            const Divider(height: 32),
            _buildTotalRow('SUBTOTAL', '₹${_subtotal.toStringAsFixed(2)}'),
            _buildTotalRow('Discount', '₹${_totalDiscount.toStringAsFixed(2)}'),
            _buildTotalRow('Tax', '₹${_totalTax.toStringAsFixed(2)}'),
            const Divider(height: 24),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Discount'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Additional Charges'),
            ),
            const Divider(height: 24),
            _buildTotalRow(
              'Taxable Amount',
              '₹${(_subtotal - _totalDiscount).toStringAsFixed(2)}',
            ),
            Row(
              children: [
                Checkbox(
                  value: _autoRoundOff,
                  onChanged: (value) {
                    setState(() => _autoRoundOff = value ?? false);
                  },
                ),
                const Text('Auto Round Off'),
                const Spacer(),
                DropdownButton<String>(
                  value: '₹',
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '₹', child: Text('₹')),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(width: 8),
                const Text('0'),
              ],
            ),
            const Divider(height: 24),
            _buildTotalRow(
              'Total Amount',
              '₹${_totalAmount.toStringAsFixed(2)}',
              isBold: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountReceivedController,
              decoration: const InputDecoration(
                labelText: 'Enter Payment amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentMode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'Card', child: Text('Card')),
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      DropdownMenuItem(
                          value: 'Bank Transfer', child: Text('Bank Transfer')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentMode = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _markAsFullyPaid,
                  onChanged: (value) {
                    setState(() {
                      _markAsFullyPaid = value ?? false;
                      if (_markAsFullyPaid) {
                        _amountReceivedController.text =
                            _totalAmount.toStringAsFixed(2);
                      }
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'Mark as fully paid',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildTotalRow(
              'Amount Received',
              '₹${amountReceived.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildTotalRow(
              'Balance Amount',
              '₹${balanceAmount.toStringAsFixed(2)}',
              color: balanceAmount > 0 ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Authorized signatory for ${_selectedParty?.name ?? 'Organization'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
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

  Future<void> _saveAndNew() async {
    await _saveInvoice();
    // If save was successful, reset the form
    if (!_isLoading && mounted) {
      setState(() {
        _selectedParty = null;
        _invoiceItems.clear();
        _invoiceDate = DateTime.now();
        _dueDate = DateTime.now().add(const Duration(days: 30));
        _amountReceivedController.text = '0';
        _markAsFullyPaid = false;
      });
      // Load next invoice number for the new invoice
      await _loadNextInvoiceNumber();
    }
  }

  Future<void> _saveInvoice() async {
    // Validation
    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
      return;
    }

    if (_invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invoiceService = SalesInvoiceService();
      final amountReceived =
          double.tryParse(_amountReceivedController.text) ?? 0;

      // Prepare invoice data
      final invoiceData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'party_id': _selectedParty!.id,
        'invoice_prefix': _invoicePrefixController.text,
        'invoice_number': _invoiceNumberController.text,
        'invoice_date': _invoiceDate.toIso8601String().split('T')[0],
        'due_date': _dueDate.toIso8601String().split('T')[0],
        'payment_terms': int.tryParse(_paymentTermsController.text) ?? 30,
        'subtotal': _subtotal,
        'discount_amount': _totalDiscount,
        'tax_amount': _totalTax,
        'total_amount': _totalAmount,
        'amount_received': amountReceived,
        'balance_amount': _totalAmount - amountReceived,
        'payment_status': amountReceived >= _totalAmount ? 'paid' : 'unpaid',
        'payment_mode': _paymentMode,
        'bank_account_id': _selectedBankAccount?.id,
        'items': _invoiceItems.map((item) {
          return {
            'item_id': item.item.id,
            'item_name': item.item.itemName,
            'hsn_sac': item.item.hsnCode,
            'item_code': item.item.itemCode,
            'mrp': item.item.mrp,
            'unit': item.item.unit,
            'quantity': item.quantity,
            'price_per_unit': item.pricePerUnit,
            'discount_percent': item.discountPercent,
            'tax_percent': item.taxPercent,
            'subtotal': item.subtotal,
            'discount_amount': item.discountAmount,
            'tax_amount': item.taxAmount,
            'line_total': item.lineTotal,
          };
        }).toList(),
      };

      await invoiceService.createInvoice(invoiceData);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _invoicePrefixController.dispose();
    _invoiceNumberController.dispose();
    _paymentTermsController.dispose();
    _amountReceivedController.dispose();
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
      title: const Text('Select Party'),
      content: SizedBox(
        width: 500,
        height: 500,
        child: Column(
          children: [
            // Search Field
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
            // Party List
            Expanded(
              child: _filteredParties.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No parties found'
                            : 'No parties match your search',
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
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              party.partyTypeLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
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
            // Search Field
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
            // Item List
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
                            'Code: ${item.itemCode} | Price: ₹${item.sellingPrice}',
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
