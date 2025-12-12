import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/item_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/item_model.dart';
import '../../utils/barcode_generator.dart';

class CreateItemScreen extends StatefulWidget {
  final ItemModel? item;

  const CreateItemScreen({super.key, this.item});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  int _selectedSection = 0;
  bool _isSaving = false;

  // Controllers for Basic Details
  final _itemNameController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _hsnCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Controllers for Stock Details
  final _openingStockController = TextEditingController();
  DateTime? _openingStockDate;
  String _selectedUnit = 'PCS';
  String? _alternativeUnit;
  final _alternativeConversionController = TextEditingController();
  bool _enableLowStockWarning = false;
  final _lowStockAlertController = TextEditingController(text: '10');

  // Controllers for Pricing Details
  final _sellingPriceController = TextEditingController();
  bool _sellingPriceWithTax = false;
  final _purchasePriceController = TextEditingController();
  bool _purchasePriceWithTax = false;
  final _mrpController = TextEditingController();
  double _gstRate = 0;

  // Party Prices and Custom Fields
  List<ItemPartyPrice> _partyPrices = [];
  List<ItemCustomField> _customFields = [];

  final List<String> _units = ['PCS', 'KG', 'LITER', 'METER', 'BOX', 'DOZEN'];
  final List<double> _gstRates = [0, 5, 12, 18, 28];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _loadItemData();
    }
    _openingStockDate = DateTime.now();
  }

  void _loadItemData() {
    final item = widget.item!;
    _itemNameController.text = item.itemName;
    _itemCodeController.text = item.itemCode;
    _barcodeController.text = item.barcode ?? '';
    _hsnCodeController.text = item.hsnCode ?? '';
    _descriptionController.text = item.description ?? '';
    _openingStockController.text = item.openingStock.toString();
    _openingStockDate = item.openingStockDate ?? DateTime.now();
    _selectedUnit = item.unit;
    _alternativeUnit = item.alternativeUnit;
    _alternativeConversionController.text =
        item.alternativeUnitConversion?.toString() ?? '';
    _enableLowStockWarning = item.enableLowStockWarning;
    _lowStockAlertController.text = item.lowStockAlert.toString();
    _sellingPriceController.text = item.sellingPrice.toString();
    _sellingPriceWithTax = item.sellingPriceWithTax;
    _purchasePriceController.text = item.purchasePrice.toString();
    _purchasePriceWithTax = item.purchasePriceWithTax;
    _mrpController.text = item.mrp.toString();
    _gstRate = item.gstRate;
    _partyPrices = item.partyPrices ?? [];
    _customFields = item.customFields ?? [];
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCodeController.dispose();
    _barcodeController.dispose();
    _hsnCodeController.dispose();
    _descriptionController.dispose();
    _openingStockController.dispose();
    _alternativeConversionController.dispose();
    _lowStockAlertController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    _mrpController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_itemNameController.text.isEmpty || _itemCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    final itemData = {
      'organization_id': orgProvider.selectedOrganization!.id,
      'item_name': _itemNameController.text,
      'item_code': _itemCodeController.text,
      'barcode': _barcodeController.text,
      'hsn_code': _hsnCodeController.text,
      'description': _descriptionController.text,
      'opening_stock': double.tryParse(_openingStockController.text) ?? 0,
      'opening_stock_date': _openingStockDate?.toIso8601String(),
      'unit': _selectedUnit,
      'alternative_unit': _alternativeUnit,
      'alternative_unit_conversion':
          double.tryParse(_alternativeConversionController.text),
      'enable_low_stock_warning': _enableLowStockWarning,
      'low_stock_alert': int.tryParse(_lowStockAlertController.text) ?? 10,
      'selling_price': double.tryParse(_sellingPriceController.text) ?? 0,
      'selling_price_with_tax': _sellingPriceWithTax,
      'purchase_price': double.tryParse(_purchasePriceController.text) ?? 0,
      'purchase_price_with_tax': _purchasePriceWithTax,
      'mrp': double.tryParse(_mrpController.text) ?? 0,
      'gst_rate': _gstRate,
      'party_prices': _partyPrices.map((e) => e.toJson()).toList(),
      'custom_fields': _customFields.map((e) => e.toJson()).toList(),
    };

    try {
      if (widget.item == null) {
        await Provider.of<ItemProvider>(context, listen: false)
            .createItem(itemData);
      } else {
        await Provider.of<ItemProvider>(context, listen: false)
            .updateItem(widget.item!.id, itemData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.item == null
                ? 'Item created successfully'
                : 'Item updated successfully'),
          ),
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
        title: Text(
          widget.item == null ? 'Create New Item' : 'Edit Item',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                right: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: _buildSidebar(),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSidebarItem(
          icon: Icons.info_outline,
          label: 'Basic Details',
          isRequired: true,
          isActive: _selectedSection == 0,
          onTap: () => setState(() => _selectedSection = 0),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
          child: Text(
            'Advance Details',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildSidebarItem(
          icon: Icons.inventory_outlined,
          label: 'Stock Details',
          isActive: _selectedSection == 1,
          onTap: () => setState(() => _selectedSection = 1),
        ),
        _buildSidebarItem(
          icon: Icons.attach_money,
          label: 'Pricing Details',
          isActive: _selectedSection == 2,
          onTap: () => setState(() => _selectedSection = 2),
        ),
        _buildSidebarItem(
          icon: Icons.people_outline,
          label: 'Party Wise Prices',
          isActive: _selectedSection == 3,
          onTap: () => setState(() => _selectedSection = 3),
        ),
        _buildSidebarItem(
          icon: Icons.dashboard_customize_outlined,
          label: 'Custom Fields',
          isActive: _selectedSection == 4,
          onTap: () => setState(() => _selectedSection = 4),
        ),
      ],
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    bool isRequired = false,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
          size: 20,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      isActive ? AppColors.primaryDark : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(color: Colors.red[600], fontSize: 16),
              ),
          ],
        ),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedSection) {
      case 0:
        return _buildBasicDetails();
      case 1:
        return _buildStockDetails();
      case 2:
        return _buildPricingDetails();
      case 3:
        return _buildPartyWisePrices();
      case 4:
        return _buildCustomFields();
      default:
        return _buildBasicDetails();
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _itemNameController,
          decoration: InputDecoration(
            labelText: 'Item Name *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _itemCodeController,
                decoration: InputDecoration(
                  labelText: 'Item Code *',
                  hintText: 'ex: ITM12549',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // Generate barcode and item code
                final barcode = BarcodeGenerator.generateEAN13();
                final itemCode = BarcodeGenerator.generateItemCode();

                _barcodeController.text = barcode;
                _itemCodeController.text = itemCode;

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Generated Barcode: $barcode'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[700],
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Text('Generate Barcode'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _hsnCodeController,
                decoration: InputDecoration(
                  labelText: 'HSN code',
                  hintText: 'ex: 4010',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                // Open HSN lookup dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('HSN Code lookup coming soon')),
                );
              },
              child: const Text('Find HSN Code'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Enter Description',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildStockDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedUnit,
          decoration: InputDecoration(
            labelText: 'Measuring Unit',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: _units.map((unit) {
            return DropdownMenuItem(value: unit, child: Text(unit));
          }).toList(),
          onChanged: (value) => setState(() => _selectedUnit = value!),
        ),
        const SizedBox(height: 16),
        if (_alternativeUnit != null) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Alternative Unit',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  controller: TextEditingController(text: _alternativeUnit),
                  onChanged: (value) => _alternativeUnit = value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _alternativeConversionController,
                  decoration: InputDecoration(
                    labelText: 'Conversion Rate',
                    hintText: 'e.g., 12',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _alternativeUnit = null;
                  _alternativeConversionController.clear();
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        TextButton.icon(
          onPressed: () => setState(() => _alternativeUnit = ''),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Alternative Unit'),
          style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _openingStockController,
                decoration: InputDecoration(
                  labelText: 'Opening Stock',
                  hintText: 'ex: 150',
                  suffixText: _selectedUnit,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _openingStockDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _openingStockDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'As of Date',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_openingStockDate != null
                          ? '${_openingStockDate!.day} ${_getMonthName(_openingStockDate!.month)} ${_openingStockDate!.year}'
                          : 'Select Date'),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _enableLowStockWarning,
              onChanged: (value) =>
                  setState(() => _enableLowStockWarning = value!),
            ),
            const Text('Enable Low stock quantity warning'),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 18),
              onPressed: () {},
              color: AppColors.textSecondary,
            ),
          ],
        ),
        if (_enableLowStockWarning) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _lowStockAlertController,
            decoration: InputDecoration(
              labelText: 'Low Stock Alert Level',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }

  Widget _buildPricingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _sellingPriceController,
                decoration: InputDecoration(
                  labelText: 'Sales Price',
                  hintText: 'ex: ₹200',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<bool>(
                value: _sellingPriceWithTax,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: false, child: Text('With Tax')),
                  DropdownMenuItem(value: true, child: Text('Without Tax')),
                ],
                onChanged: (value) =>
                    setState(() => _sellingPriceWithTax = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _purchasePriceController,
                decoration: InputDecoration(
                  labelText: 'Purchase Price',
                  hintText: 'ex: ₹200',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<bool>(
                value: _purchasePriceWithTax,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: false, child: Text('With Tax')),
                  DropdownMenuItem(value: true, child: Text('Without Tax')),
                ],
                onChanged: (value) =>
                    setState(() => _purchasePriceWithTax = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mrpController,
                decoration: InputDecoration(
                  labelText: 'Maximum Retail Price (MRP)',
                  hintText: 'ex: ₹200',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<double>(
                value: _gstRate,
                decoration: InputDecoration(
                  labelText: 'GST Tax Rate(%)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _gstRates.map((rate) {
                  return DropdownMenuItem(
                    value: rate,
                    child: Text(rate == 0 ? 'None' : '$rate%'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _gstRate = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartyWisePrices() {
    if (widget.item == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'To enable Party Wise Prices and set custom prices for parties,',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            Text(
              'please save the item first',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Add party price dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Party price selection coming soon')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Party Price'),
        ),
        const SizedBox(height: 16),
        if (_partyPrices.isEmpty)
          Center(
            child: Text(
              'No party-specific prices added yet',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _partyPrices.length,
            itemBuilder: (context, index) {
              final partyPrice = _partyPrices[index];
              return Card(
                child: ListTile(
                  title: Text('Party ID: ${partyPrice.partyId}'),
                  subtitle: Text('Price: ₹${partyPrice.sellingPrice}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _partyPrices.removeAt(index));
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCustomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _customFields.add(ItemCustomField(
                fieldName: 'New Field',
                fieldValue: '',
                fieldType: 'text',
              ));
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Custom Field'),
        ),
        const SizedBox(height: 16),
        if (_customFields.isEmpty)
          Center(
            child: Text(
              'No custom fields added yet',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _customFields.length,
            itemBuilder: (context, index) {
              final field = _customFields[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Field Name',
                                border: OutlineInputBorder(),
                              ),
                              controller:
                                  TextEditingController(text: field.fieldName),
                              onChanged: (value) {
                                _customFields[index] = ItemCustomField(
                                  id: field.id,
                                  fieldName: value,
                                  fieldValue: field.fieldValue,
                                  fieldType: field.fieldType,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: DropdownButtonFormField<String>(
                              value: field.fieldType,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'text', child: Text('Text')),
                                DropdownMenuItem(
                                    value: 'number', child: Text('Number')),
                                DropdownMenuItem(
                                    value: 'date', child: Text('Date')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _customFields[index] = ItemCustomField(
                                    id: field.id,
                                    fieldName: field.fieldName,
                                    fieldValue: field.fieldValue,
                                    fieldType: value!,
                                  );
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => _customFields.removeAt(index));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Field Value',
                          border: OutlineInputBorder(),
                        ),
                        controller:
                            TextEditingController(text: field.fieldValue),
                        onChanged: (value) {
                          _customFields[index] = ItemCustomField(
                            id: field.id,
                            fieldName: field.fieldName,
                            fieldValue: value,
                            fieldType: field.fieldType,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
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
}
