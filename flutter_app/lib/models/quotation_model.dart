class Quotation {
  final int? id;
  final int organizationId;
  final int partyId;
  final int userId;
  final String quotationNumber;
  final DateTime quotationDate;
  final int validFor;
  final DateTime validityDate;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double additionalCharges;
  final double roundOff;
  final double totalAmount;
  final String status;
  final String? notes;
  final String? termsConditions;
  final String? bankDetails;
  final bool showBankDetails;
  final bool autoRoundOff;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related models
  final PartyBasic? party;
  final List<QuotationItem>? items;

  Quotation({
    this.id,
    required this.organizationId,
    required this.partyId,
    required this.userId,
    required this.quotationNumber,
    required this.quotationDate,
    required this.validFor,
    required this.validityDate,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.additionalCharges,
    required this.roundOff,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.termsConditions,
    this.bankDetails,
    required this.showBankDetails,
    required this.autoRoundOff,
    this.createdAt,
    this.updatedAt,
    this.party,
    this.items,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      organizationId: int.parse(json['organization_id'].toString()),
      partyId: int.parse(json['party_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      quotationNumber: json['quotation_number'].toString(),
      quotationDate: DateTime.parse(json['quotation_date']),
      validFor: int.parse(json['valid_for'].toString()),
      validityDate: DateTime.parse(json['validity_date']),
      subtotal: double.parse(json['subtotal'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      additionalCharges: double.parse(json['additional_charges'].toString()),
      roundOff: double.parse(json['round_off'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'].toString(),
      notes: json['notes']?.toString(),
      termsConditions: json['terms_conditions']?.toString(),
      bankDetails: json['bank_details']?.toString(),
      showBankDetails:
          json['show_bank_details'] == true || json['show_bank_details'] == 1,
      autoRoundOff:
          json['auto_round_off'] == true || json['auto_round_off'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      party: json['party'] != null ? PartyBasic.fromJson(json['party']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => QuotationItem.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'party_id': partyId,
      'user_id': userId,
      'quotation_number': quotationNumber,
      'quotation_date': quotationDate.toIso8601String().split('T')[0],
      'valid_for': validFor,
      'validity_date': validityDate.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'additional_charges': additionalCharges,
      'round_off': roundOff,
      'total_amount': totalAmount,
      'status': status,
      'notes': notes,
      'terms_conditions': termsConditions,
      'bank_details': bankDetails,
      'show_bank_details': showBankDetails,
      'auto_round_off': autoRoundOff,
    };
  }

  String get dueInText {
    if (status == 'expired' || status == 'converted') return '-';

    final today = DateTime.now();
    final difference = validityDate.difference(today).inDays;

    if (difference < 0) {
      return 'Expired';
    }
    return '$difference Days';
  }

  bool get isExpired {
    return DateTime.now().isAfter(validityDate);
  }

  String get statusDisplay {
    switch (status) {
      case 'open':
        return 'Open';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      case 'converted':
        return 'Converted';
      default:
        return status.toUpperCase();
    }
  }
}

class QuotationItem {
  final int? id;
  final int quotationId;
  final int itemId;
  final String itemName;
  final String? hsnSac;
  final String? itemCode;
  final double? mrp;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double discountPercent;
  final double discountAmount;
  final double taxPercent;
  final double taxAmount;
  final double lineTotal;

  QuotationItem({
    this.id,
    required this.quotationId,
    required this.itemId,
    required this.itemName,
    this.hsnSac,
    this.itemCode,
    this.mrp,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.discountPercent,
    required this.discountAmount,
    required this.taxPercent,
    required this.taxAmount,
    required this.lineTotal,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      id: json['id'],
      quotationId: json['quotation_id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      hsnSac: json['hsn_sac'],
      itemCode: json['item_code'],
      mrp: json['mrp'] != null ? double.parse(json['mrp'].toString()) : null,
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'],
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      discountPercent: double.parse(json['discount_percent'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      taxPercent: double.parse(json['tax_percent'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      lineTotal: double.parse(json['line_total'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'hsn_sac': hsnSac,
      'item_code': itemCode,
      'mrp': mrp,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'tax_percent': taxPercent,
      'tax_amount': taxAmount,
      'line_total': lineTotal,
    };
  }
}

class PartyBasic {
  final int id;
  final String name;
  final String? phone;
  final String? email;

  PartyBasic({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });

  factory PartyBasic.fromJson(Map<String, dynamic> json) {
    return PartyBasic(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}
