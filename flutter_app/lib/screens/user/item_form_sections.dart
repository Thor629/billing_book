import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ItemFormSections {
  static Widget buildBasicDetails({
    required TextEditingController itemCodeController,
    required TextEditingController hsnCodeController,
    required VoidCallback onGenerateBarcode,
    required VoidCallback onFindHSN,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: itemCodeController,
                decoration: InputDecoration(
                  labelText: 'Item Code',
                  hintText: 'ex: ITM12549',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onGenerateBarcode,
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
                controller: hsnCodeController,
                decoration: InputDecoration(
                  labelText: 'HSN code',
                  hintText: 'ex: 4010',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onFindHSN,
              child: const Text('Find HSN Code'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Item Custom Fields'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  static Widget buildStockDetails({
    required TextEditingController itemCodeController,
    required TextEditingController hsnCodeController,
    required String selectedUnit,
    required List<String> units,
    required Function(String?) onUnitChanged,
    required TextEditingController openingStockController,
    required DateTime? openingStockDate,
    required VoidCallback onSelectDate,
    required bool enableLowStockWarning,
    required Function(bool) onLowStockWarningChanged,
    required TextEditingController descriptionController,
    required VoidCallback onAddAlternativeUnit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: itemCodeController,
                decoration: InputDecoration(
                  labelText: 'Item Code',
                  hintText: 'ex: ITM12549',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                enabled: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: hsnCodeController,
                decoration: InputDecoration(
                  labelText: 'HSN code',
                  hintText: 'ex: 4010',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                enabled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedUnit,
          decoration: InputDecoration(
            labelText: 'Measuring Unit',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: units.map((unit) {
            return DropdownMenuItem(value: unit, child: Text(unit));
          }).toList(),
          onChanged: onUnitChanged,
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: onAddAlternativeUnit,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Alternative Unit'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: openingStockController,
                decoration: InputDecoration(
                  labelText: 'Opening Stock',
                  hintText: 'ex: 150 PCS',
                  suffixText: selectedUnit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: onSelectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'As of Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        openingStockDate != null
                            ? '${openingStockDate.day} ${_getMonthName(openingStockDate.month)} ${openingStockDate.year}'
                            : 'Select Date',
                      ),
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
            TextButton.icon(
              onPressed: () => onLowStockWarningChanged(!enableLowStockWarning),
              icon: Icon(
                enableLowStockWarning
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 20,
              ),
              label: const Text('Enable Low stock quantity warning'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 18),
              onPressed: () {},
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Enter Description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  static Widget buildPricingDetails({
    required TextEditingController sellingPriceController,
    required bool sellingPriceWithTax,
    required Function(bool) onSellingPriceWithTaxChanged,
    required TextEditingController purchasePriceController,
    required bool purchasePriceWithTax,
    required Function(bool) onPurchasePriceWithTaxChanged,
    required TextEditingController mrpController,
    required double gstRate,
    required List<double> gstRates,
    required Function(double?) onGstRateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: sellingPriceController,
                decoration: InputDecoration(
                  labelText: 'Sales Price',
                  hintText: 'ex: ₹200',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<bool>(
                value: sellingPriceWithTax,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: false, child: Text('With Tax')),
                  DropdownMenuItem(value: true, child: Text('Without Tax')),
                ],
                onChanged: (value) =>
                    onSellingPriceWithTaxChanged(value ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: purchasePriceController,
                decoration: InputDecoration(
                  labelText: 'Purchase Price',
                  hintText: 'ex: ₹200',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<bool>(
                value: purchasePriceWithTax,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: false, child: Text('With Tax')),
                  DropdownMenuItem(value: true, child: Text('Without Tax')),
                ],
                onChanged: (value) =>
                    onPurchasePriceWithTaxChanged(value ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: mrpController,
                decoration: InputDecoration(
                  labelText: 'Maximum Retail Price (MRP)',
                  hintText: 'ex: ₹200',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<double>(
                value: gstRate,
                decoration: InputDecoration(
                  labelText: 'GST Tax Rate(%)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: gstRates.map((rate) {
                  return DropdownMenuItem(
                    value: rate,
                    child: Text(rate == 0 ? 'None' : '$rate%'),
                  );
                }).toList(),
                onChanged: onGstRateChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _getMonthName(int month) {
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
