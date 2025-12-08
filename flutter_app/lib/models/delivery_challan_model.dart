class DeliveryChallan {
  final int id;
  final int organizationId;
  final int userId;
  final int partyId;
  final String challanNumber;
  final DateTime challanDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? notes;
  final String? termsConditions;
  final String status;
  final Party? party;
  final List<DeliveryChallanItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryChallan({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.partyId,
    required this.challanNumber,
    required this.challanDate,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.notes,
    this.termsConditions,
    required this.status,
    this.party,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryChallan.fromJson(Map<String, dynamic> json) {
    return DeliveryChallan(
      id: json['id'],
      organizationId: json['organization_id'],
      userId: json['user_id'],
      partyId: json['party_id'],
      challanNumber: json['challan_number'],
      challanDate: DateTime.parse(json['challan_date']),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      notes: json['notes'],
      termsConditions: json['terms_conditions'],
      status: json['status'] ?? 'open',
      party: json['party'] != null ? Party.fromJson(json['party']) : null,
      items: (json['items'] as List?)
              ?.map((item) => DeliveryChallanItem.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class DeliveryChallanItem {
  final int? id;
  final int? deliveryChallanId;
  final int? itemId;
  final String itemName;
  final String? hsnSac;
  final double quantity;
  final double price;
  final double discountPercent;
  final double taxPercent;
  final double amount;

  DeliveryChallanItem({
    this.id,
    this.deliveryChallanId,
    this.itemId,
    required this.itemName,
    this.hsnSac,
    required this.quantity,
    required this.price,
    required this.discountPercent,
    required this.taxPercent,
    required this.amount,
  });

  factory DeliveryChallanItem.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanItem(
      id: json['id'],
      deliveryChallanId: json['delivery_challan_id'],
      itemId: json['item_id'],
      itemName: json['item_name'] ?? '',
      hsnSac: json['hsn_sac'],
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discountPercent:
          double.tryParse(json['discount_percent']?.toString() ?? '0') ?? 0.0,
      taxPercent:
          double.tryParse(json['tax_percent']?.toString() ?? '0') ?? 0.0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (deliveryChallanId != null) 'delivery_challan_id': deliveryChallanId,
      if (itemId != null) 'item_id': itemId,
      'item_name': itemName,
      'hsn_sac': hsnSac,
      'quantity': quantity,
      'price': price,
      'discount_percent': discountPercent,
      'tax_percent': taxPercent,
      'amount': amount,
    };
  }
}

class Party {
  final int id;
  final String name;
  final String phone;

  Party({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }
}
