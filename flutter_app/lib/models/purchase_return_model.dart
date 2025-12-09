class PurchaseReturn {
  final int id;
  final int organizationId;
  final int partyId;
  final int? purchaseInvoiceId;
  final String returnNumber;
  final DateTime returnDate;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? paymentMode;
  final int? bankAccountId;
  final double amountReceived;
  final String status;
  final String? reason;
  final String? notes;
  final Party? party;
  final List<PurchaseReturnItem>? items;
  final DateTime? createdAt;

  PurchaseReturn({
    required this.id,
    required this.organizationId,
    required this.partyId,
    this.purchaseInvoiceId,
    required this.returnNumber,
    required this.returnDate,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.paymentMode,
    this.bankAccountId,
    required this.amountReceived,
    required this.status,
    this.reason,
    this.notes,
    this.party,
    this.items,
    this.createdAt,
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) {
    return PurchaseReturn(
      id: int.parse(json['id'].toString()),
      organizationId: int.parse(json['organization_id'].toString()),
      partyId: int.parse(json['party_id'].toString()),
      purchaseInvoiceId: json['purchase_invoice_id'] != null
          ? int.parse(json['purchase_invoice_id'].toString())
          : null,
      returnNumber: json['return_number'] ?? '',
      returnDate: DateTime.parse(json['return_date']),
      subtotal: double.parse(json['subtotal'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      paymentMode: json['payment_mode'],
      bankAccountId: json['bank_account_id'] != null
          ? int.parse(json['bank_account_id'].toString())
          : null,
      amountReceived: double.parse(json['amount_received']?.toString() ?? '0'),
      status: json['status'] ?? 'pending',
      reason: json['reason'],
      notes: json['notes'],
      party: json['party'] != null ? Party.fromJson(json['party']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => PurchaseReturnItem.fromJson(item))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'party_id': partyId,
      'purchase_invoice_id': purchaseInvoiceId,
      'return_number': returnNumber,
      'return_date': returnDate.toIso8601String().split('T')[0],
      'status': status,
      'payment_mode': paymentMode,
      'bank_account_id': bankAccountId,
      'amount_received': amountReceived,
      'reason': reason,
      'notes': notes,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class PurchaseReturnItem {
  final int? id;
  final int itemId;
  final String? description;
  final double quantity;
  final String unit;
  final double rate;
  final double taxRate;
  final double amount;
  final Item? item;

  PurchaseReturnItem({
    this.id,
    required this.itemId,
    this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.taxRate,
    required this.amount,
    this.item,
  });

  factory PurchaseReturnItem.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnItem(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      itemId: int.parse(json['item_id'].toString()),
      description: json['description'],
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'] ?? 'pcs',
      rate: double.parse(json['rate'].toString()),
      taxRate: double.parse(json['tax_rate']?.toString() ?? '0'),
      amount: double.parse(json['amount'].toString()),
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'tax_rate': taxRate,
    };
  }
}

class Party {
  final int id;
  final String name;
  final String? phone;
  final String? email;

  Party({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class Item {
  final int id;
  final String name;
  final String? itemCode;
  final double salePrice;
  final double purchasePrice;
  final double stockQty;

  Item({
    required this.id,
    required this.name,
    this.itemCode,
    required this.salePrice,
    required this.purchasePrice,
    required this.stockQty,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      itemCode: json['item_code'],
      salePrice: double.parse(json['sale_price']?.toString() ?? '0'),
      purchasePrice: double.parse(json['purchase_price']?.toString() ?? '0'),
      stockQty: double.parse(json['stock_qty']?.toString() ?? '0'),
    );
  }
}
