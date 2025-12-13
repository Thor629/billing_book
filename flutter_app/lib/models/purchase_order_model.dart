class PurchaseOrder {
  final int id;
  final int organizationId;
  final int partyId;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double additionalCharges;
  final double roundOff;
  final bool autoRoundOff;
  final double totalAmount;
  final bool fullyPaid;
  final int? bankAccountId;
  final String status;
  final String? notes;
  final String? terms;
  final String? partyName;
  final List<PurchaseOrderItem>? items;
  final bool? convertedToInvoice;
  final int? purchaseInvoiceId;
  final DateTime? convertedAt;

  PurchaseOrder({
    required this.id,
    required this.organizationId,
    required this.partyId,
    required this.orderNumber,
    required this.orderDate,
    this.expectedDeliveryDate,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.additionalCharges,
    required this.roundOff,
    required this.autoRoundOff,
    required this.totalAmount,
    required this.fullyPaid,
    this.bankAccountId,
    required this.status,
    this.notes,
    this.terms,
    this.partyName,
    this.items,
    this.convertedToInvoice,
    this.purchaseInvoiceId,
    this.convertedAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      organizationId: json['organization_id'],
      partyId: json['party_id'],
      orderNumber: json['order_number'],
      orderDate: DateTime.parse(json['order_date']),
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.parse(json['expected_delivery_date'])
          : null,
      subtotal: double.parse(json['subtotal'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      additionalCharges: double.parse(json['additional_charges'].toString()),
      roundOff: double.parse(json['round_off'].toString()),
      autoRoundOff:
          json['auto_round_off'] == 1 || json['auto_round_off'] == true,
      totalAmount: double.parse(json['total_amount'].toString()),
      fullyPaid: json['fully_paid'] == 1 || json['fully_paid'] == true,
      bankAccountId: json['bank_account_id'],
      status: json['status'],
      notes: json['notes'],
      terms: json['terms'],
      partyName: json['party']?['name'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => PurchaseOrderItem.fromJson(item))
              .toList()
          : null,
      convertedToInvoice: json['converted_to_invoice'] == 1 ||
          json['converted_to_invoice'] == true,
      purchaseInvoiceId: json['purchase_invoice_id'],
      convertedAt: json['converted_at'] != null
          ? DateTime.parse(json['converted_at'])
          : null,
    );
  }
}

class PurchaseOrderItem {
  final int id;
  final int purchaseOrderId;
  final int itemId;
  final String? description;
  final double quantity;
  final String unit;
  final double rate;
  final double taxRate;
  final double discountRate;
  final double amount;
  final String? itemName;
  final String? itemCode;

  PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.itemId,
    this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.taxRate,
    required this.discountRate,
    required this.amount,
    this.itemName,
    this.itemCode,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'],
      purchaseOrderId: json['purchase_order_id'],
      itemId: json['item_id'],
      description: json['description'],
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'],
      rate: double.parse(json['rate'].toString()),
      taxRate: double.parse(json['tax_rate'].toString()),
      discountRate: double.parse(json['discount_rate'].toString()),
      amount: double.parse(json['amount'].toString()),
      itemName: json['item']?['item_name'],
      itemCode: json['item']?['item_code'],
    );
  }
}
