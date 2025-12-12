import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../models/bank_account_model.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../services/bank_account_service.dart';
import '../../services/quotation_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../utils/barcode_scanner.dart';
import '../../widgets/dialog_scaffold.dart';

class QuotationItem {
  final ItemModel item;
  double quantity;
  double pricePerUnit;
  double discountPercent;
  double taxPercent;

  QuotationItem({
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

class CreateQuotationScreen extends StatefulWidget {
  final int? quotationId;
  final Map<String, dynamic>? quotationData;

  const CreateQuotationScreen({
    super.key,
    this.quotationId,
    this.quotationData,
  });

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final TextEditingController _quotationNumberController =
      TextEditingController(text: '1');
  final TextEditingController _validForController =
      TextEditingController(text: '30');

  DateTime _quotationDate = DateTime.now();
  DateTime _validityDate = DateTime.now().add(const Duration(days: 30));
  bool _showBankDetails = true;
  bool _autoRoundOff = false;

  // Party and Items
  PartyModel? _selectedParty;
  List<QuotationItem> _quotationItems = [];

  // Bank Accounts
  BankAccount? _selectedBankAccount;
  List<BankAccount> _bankAccounts = [];

  // Discount and Charges
  double _discountAmount = 0;
  double _additionalCharges = 0;

  bool _isLoading = false;

  bool get _isEditMode =>
      widget.quotationId != null || widget.quotationData != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadBankAccounts();
    _loadNextQuotationNumber();
  }

  Future<void> _loadInitialData() async {
    if (widget.quotationId != null) {
      // Fetch full quotation data from API using ID
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);
      if (orgProvider.selectedOrganization == null) return;

      try {
        final quotationService = QuotationService();
        final quotation = await quotationService.getQuotation(
          widget.quotationId!,
          orgProvider.selectedOrganization!.id,
        );

        debugPrint('📦 Quotation loaded: ${quotation.quotationNumber}');
        debugPrint('📦 Items count: ${quotation.items?.length ?? 0}');
        if (quotation.items != null) {
          for (var item in quotation.items!) {
            debugPrint(
                '  - Item: ${item.itemName}, Qty: ${item.quantity}, Price: ${item.pricePerUnit}');
          }
        }

        setState(() {
          _quotationNumberController.text = quotation.quotationNumber;
          _quotationDate = quotation.quotationDate;
          _validityDate = quotation.validityDate;
          if (quotation.party != null) {
            _selectedParty = PartyModel(
              id: quotation.party!.id,
              name: quotation.party!.name,
              phone: quotation.party!.phone ?? '',
              email: quotation.party!.email,
              gstNo: '',
              billingAddress: '',
              shippingAddress: '',
              partyType: 'customer',
              isActive: true,
              organizationId: quotation.organizationId,
              createdAt: DateTime.now(),
            );
          }
          // Load items
          if (quotation.items != null && quotation.items!.isNotEmpty) {
            _quotationItems = quotation.items!.map((apiItem) {
              // Create a minimal ItemModel from API data
              final itemModel = ItemModel(
                id: apiItem.itemId,
                organizationId: quotation.organizationId,
                itemName: apiItem.itemName,
                itemCode: apiItem.itemCode ?? '',
                sellingPrice: apiItem.pricePerUnit,
                sellingPriceWithTax: false,
                purchasePrice: 0,
                purchasePriceWithTax: false,
                mrp: apiItem.mrp ?? 0,
                stockQty: 0,
                openingStock: 0,
                unit: apiItem.unit,
                lowStockAlert: 0,
                enableLowStockWarning: false,
                hsnCode: apiItem.hsnSac,
                gstRate: apiItem.taxPercent,
                isActive: true,
                createdAt: DateTime.now(),
              );

              // Create QuotationItem with the ItemModel
              return QuotationItem(
                item: itemModel,
                quantity: apiItem.quantity,
                pricePerUnit: apiItem.pricePerUnit,
                discountPercent: apiItem.discountPercent,
                taxPercent: apiItem.taxPercent,
              );
            }).toList();
            debugPrint(
                '✅ Loaded ${_quotationItems.length} items into _quotationItems list');
          }
        });

        // Debug after setState
        debugPrint(
            '🎯 After setState: _quotationItems has ${_quotationItems.length} items');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading quotation: $e')),
          );
        }
      }
    } else if (widget.quotationData != null) {
      // Fallback to basic data if only data map is provided
      setState(() {
        if (widget.quotationData!['quotation_number'] != null) {
          _quotationNumberController.text =
              widget.quotationData!['quotation_number'].toString();
        }
        if (widget.quotationData!['quotation_date'] != null) {
          _quotationDate =
              DateTime.parse(widget.quotationData!['quotation_date']);
        }
        if (widget.quotationData!['validity_date'] != null) {
          _validityDate =
              DateTime.parse(widget.quotationData!['validity_date']);
        }
      });
    }
  }

  Future<void> _loadNextQuotationNumber() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) return;

    // Don't load next number if in edit mode
    if (_isEditMode) return;

    try {
      final quotationService = QuotationService();
      final result = await quotationService.getNextQuotationNumber(
        orgProvider.selectedOrganization!.id,
      );
      setState(() {
        _quotationNumberController.text = result['next_number'].toString();
      });
    } catch (e) {
      // If error, keep default value
      debugPrint('Error loading next quotation number: $e');
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
      _quotationItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get _totalDiscount =>
      _quotationItems.fold(0.0, (sum, item) => sum + item.discountAmount) +
      _discountAmount;

  double get _totalTax =>
      _quotationItems.fold(0.0, (sum, item) => sum + item.taxAmount);

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
          _quotationItems.add(QuotationItem(item: selectedItem));
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

  Future<void> _saveQuotation({bool saveAndNew = false}) async {
    // Validation
    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
      return;
    }

    if (_quotationItems.isEmpty) {
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

      final quotationData = {
        'party_id': _selectedParty!.id,
        'quotation_number': _quotationNumberController.text,
        'quotation_date': _quotationDate.toIso8601String().split('T')[0],
        'valid_for': int.tryParse(_validForController.text) ?? 30,
        'validity_date': _validityDate.toIso8601String().split('T')[0],
        'subtotal': _subtotal,
        'discount_amount': _discountAmount,
        'tax_amount': _totalTax,
        'additional_charges': _additionalCharges,
        'total_amount': _totalAmount,
        'bank_account_id': _selectedBankAccount?.id,
        'items': _quotationItems.map((item) {
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
          };
        }).toList(),
      };

      final quotationService = QuotationService();
      await quotationService.createQuotation(
        orgProvider.selectedOrganization!.id,
        quotationData,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quotation saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        if (saveAndNew) {
          // Reset form
          setState(() {
            _selectedParty = null;
            _quotationItems.clear();
            _discountAmount = 0;
            _additionalCharges = 0;
            _quotationDate = DateTime.now();
            _validityDate = DateTime.now().add(const Duration(days: 30));
            _validForController.text = '30';
          });
          _loadNextQuotationNumber();
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving quotation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 Building UI with ${_quotationItems.length} items');
    return DialogScaffold(
      title: _isEditMode ? 'Edit Quotation' : 'Create Quotation',
      onSave: _saveQuotation,
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

              // Right Side - Quotation Details
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuotationDetailsCard(),
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
          ..._quotationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final quotationItem = entry.value;
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
                    child: Text(quotationItem.item.itemName),
                  ),
                  Expanded(
                    child: Text(quotationItem.item.hsnCode ?? '-'),
                  ),
                  Expanded(
                    child: Text(quotationItem.item.itemCode),
                  ),
                  Expanded(
                    child: Text('₹${quotationItem.item.sellingPrice}'),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: quotationItem.quantity.toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          quotationItem.quantity = double.tryParse(value) ?? 1;
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
                        text: quotationItem.pricePerUnit.toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          quotationItem.pricePerUnit =
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
                        text: quotationItem.discountPercent.toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          quotationItem.discountPercent =
                              double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Text('${quotationItem.taxPercent}%'),
                  ),
                  Expanded(
                    child:
                        Text('₹${quotationItem.lineTotal.toStringAsFixed(2)}'),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () {
                        setState(() {
                          _quotationItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
          _buildDetailRow(
              'Bank Name:', _selectedBankAccount!.bankName ?? 'N/A'),
          _buildDetailRow(
              'Account Number:', _selectedBankAccount!.bankAccountNo ?? 'N/A'),
          _buildDetailRow(
              'IFSC Code:', _selectedBankAccount!.ifscCode ?? 'N/A'),
          _buildDetailRow('Account Holder:',
              _selectedBankAccount!.accountHolderName ?? 'N/A'),
          if (_selectedBankAccount!.branchName != null)
            _buildDetailRow('Branch:', _selectedBankAccount!.branchName!),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_bankAccounts.length > 1)
                PopupMenuButton<BankAccount>(
                  child: TextButton(
                    onPressed: null,
                    child: const Text('Change Bank Account'),
                  ),
                  itemBuilder: (context) => _bankAccounts
                      .map((account) => PopupMenuItem<BankAccount>(
                            value: account,
                            child: Text(
                                '${account.bankName ?? 'N/A'} - ${account.bankAccountNo ?? 'N/A'}'),
                          ))
                      .toList(),
                  onSelected: (account) {
                    setState(() => _selectedBankAccount = account);
                  },
                ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _showBankDetails = false);
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

  Widget _buildQuotationDetailsCard() {
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
                        'Quotation No.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _quotationNumberController,
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
              'Quotation Date',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _quotationDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _quotationDate = date);
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
                      '${_quotationDate.day} ${_getMonthName(_quotationDate.month)} ${_quotationDate.year}',
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
                        'Valid For',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _validForController,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final days = int.tryParse(value) ?? 30;
                                setState(() {
                                  _validityDate =
                                      _quotationDate.add(Duration(days: days));
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validity Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _validityDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _validityDate = date);
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
                                '${_validityDate.day} ${_getMonthName(_validityDate.month)} ${_validityDate.year}',
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
            const Text(
              'Authorized signatory for Shivoham Interprice',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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

  @override
  void dispose() {
    _quotationNumberController.dispose();
    _validForController.dispose();
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
