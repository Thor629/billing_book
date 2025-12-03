class ItemModel {
  final int id;
  final int organizationId;
  final String itemName;
  final String itemCode;
  final String? barcode;
  final double sellingPrice;
  final bool sellingPriceWithTax;
  final double purchasePrice;
  final bool purchasePriceWithTax;
  final double mrp;
  final int stockQty;
  final double openingStock;
  final DateTime? openingStockDate;
  final String unit;
  final String? alternativeUnit;
  final double? alternativeUnitConversion;
  final int lowStockAlert;
  final bool enableLowStockWarning;
  final String? category;
  final String? description;
  final String? hsnCode;
  final double gstRate;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final List<ItemPartyPrice>? partyPrices;
  final List<ItemCustomField>? customFields;

  ItemModel({
    required this.id,
    required this.organizationId,
    required this.itemName,
    required this.itemCode,
    this.barcode,
    required this.sellingPrice,
    required this.sellingPriceWithTax,
    required this.purchasePrice,
    required this.purchasePriceWithTax,
    required this.mrp,
    required this.stockQty,
    required this.openingStock,
    this.openingStockDate,
    required this.unit,
    this.alternativeUnit,
    this.alternativeUnitConversion,
    required this.lowStockAlert,
    required this.enableLowStockWarning,
    this.category,
    this.description,
    this.hsnCode,
    required this.gstRate,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.partyPrices,
    this.customFields,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? 0,
      organizationId: json['organization_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      itemCode: json['item_code'] ?? '',
      barcode: json['barcode'],
      sellingPrice:
          double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0,
      sellingPriceWithTax: json['selling_price_with_tax'] ?? false,
      purchasePrice:
          double.tryParse(json['purchase_price']?.toString() ?? '0') ?? 0,
      purchasePriceWithTax: json['purchase_price_with_tax'] ?? false,
      mrp: double.tryParse(json['mrp']?.toString() ?? '0') ?? 0,
      stockQty: json['stock_qty'] ?? 0,
      openingStock:
          double.tryParse(json['opening_stock']?.toString() ?? '0') ?? 0,
      openingStockDate: json['opening_stock_date'] != null
          ? DateTime.tryParse(json['opening_stock_date'])
          : null,
      unit: json['unit'] ?? 'PCS',
      alternativeUnit: json['alternative_unit'],
      alternativeUnitConversion: json['alternative_unit_conversion'] != null
          ? double.tryParse(json['alternative_unit_conversion'].toString())
          : null,
      lowStockAlert: json['low_stock_alert'] ?? 10,
      enableLowStockWarning: json['enable_low_stock_warning'] ?? false,
      category: json['category'],
      description: json['description'],
      hsnCode: json['hsn_code'],
      gstRate: double.tryParse(json['gst_rate']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      partyPrices: json['party_prices'] != null
          ? (json['party_prices'] as List)
              .map((e) => ItemPartyPrice.fromJson(e))
              .toList()
          : null,
      customFields: json['custom_fields'] != null
          ? (json['custom_fields'] as List)
              .map((e) => ItemCustomField.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'item_name': itemName,
      'item_code': itemCode,
      'barcode': barcode,
      'selling_price': sellingPrice,
      'selling_price_with_tax': sellingPriceWithTax,
      'purchase_price': purchasePrice,
      'purchase_price_with_tax': purchasePriceWithTax,
      'mrp': mrp,
      'stock_qty': stockQty,
      'opening_stock': openingStock,
      'opening_stock_date': openingStockDate?.toIso8601String(),
      'unit': unit,
      'alternative_unit': alternativeUnit,
      'alternative_unit_conversion': alternativeUnitConversion,
      'low_stock_alert': lowStockAlert,
      'enable_low_stock_warning': enableLowStockWarning,
      'category': category,
      'description': description,
      'hsn_code': hsnCode,
      'gst_rate': gstRate,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      if (partyPrices != null)
        'party_prices': partyPrices!.map((e) => e.toJson()).toList(),
      if (customFields != null)
        'custom_fields': customFields!.map((e) => e.toJson()).toList(),
    };
  }

  bool get isLowStock => stockQty <= lowStockAlert;
}

class ItemPartyPrice {
  final int? id;
  final int partyId;
  final double sellingPrice;
  final double? purchasePrice;
  final bool priceWithTax;
  final Map<String, dynamic>? party;

  ItemPartyPrice({
    this.id,
    required this.partyId,
    required this.sellingPrice,
    this.purchasePrice,
    required this.priceWithTax,
    this.party,
  });

  factory ItemPartyPrice.fromJson(Map<String, dynamic> json) {
    return ItemPartyPrice(
      id: json['id'],
      partyId: json['party_id'],
      sellingPrice:
          double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0,
      purchasePrice: json['purchase_price'] != null
          ? double.tryParse(json['purchase_price'].toString())
          : null,
      priceWithTax: json['price_with_tax'] ?? false,
      party: json['party'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'party_id': partyId,
      'selling_price': sellingPrice,
      'purchase_price': purchasePrice,
      'price_with_tax': priceWithTax,
    };
  }
}

class ItemCustomField {
  final int? id;
  final String fieldName;
  final String? fieldValue;
  final String fieldType;

  ItemCustomField({
    this.id,
    required this.fieldName,
    this.fieldValue,
    required this.fieldType,
  });

  factory ItemCustomField.fromJson(Map<String, dynamic> json) {
    return ItemCustomField(
      id: json['id'],
      fieldName: json['field_name'] ?? '',
      fieldValue: json['field_value'],
      fieldType: json['field_type'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'field_name': fieldName,
      'field_value': fieldValue,
      'field_type': fieldType,
    };
  }
}
