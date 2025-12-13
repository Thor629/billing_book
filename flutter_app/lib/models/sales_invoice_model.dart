class SalesInvoice {
  final int? id;
  final int organizationId;
  final int? partyId; // Nullable for POS sales
  final int userId;
  final String invoicePrefix;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final int paymentTerms;
  final DateTime dueDate;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double additionalCharges;
  final double roundOff;
  final double totalAmount;
  final double amountReceived;
  final double balanceAmount;
  final String? paymentMode;
  final String paymentStatus;
  final String? notes;
  final String? termsConditions;
  final String? bankDetails;
  final bool showBankDetails;
  final bool autoRoundOff;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // E-Invoice specific fields
  final String? irn;
  final String? ackNo;
  final DateTime? ackDate;
  final String? qrCodeData;
  final String? qrCodeImage;
  final String? signedInvoice;
  final String? wayBillNo;
  final DateTime? wayBillDate;
  final String invoiceStatus;
  final bool isEInvoiceGenerated;
  final bool isReconciled;
  final DateTime? reconciledAt;

  // Related models
  final PartyBasic? party;
  final List<SalesInvoiceItem>? items;

  SalesInvoice({
    this.id,
    required this.organizationId,
    this.partyId, // Nullable for POS sales
    required this.userId,
    required this.invoicePrefix,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.paymentTerms,
    required this.dueDate,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.additionalCharges,
    required this.roundOff,
    required this.totalAmount,
    required this.amountReceived,
    required this.balanceAmount,
    this.paymentMode,
    required this.paymentStatus,
    this.notes,
    this.termsConditions,
    this.bankDetails,
    required this.showBankDetails,
    required this.autoRoundOff,
    this.createdAt,
    this.updatedAt,
    this.irn,
    this.ackNo,
    this.ackDate,
    this.qrCodeData,
    this.qrCodeImage,
    this.signedInvoice,
    this.wayBillNo,
    this.wayBillDate,
    this.invoiceStatus = 'draft',
    this.isEInvoiceGenerated = false,
    this.isReconciled = false,
    this.reconciledAt,
    this.party,
    this.items,
  });

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: json['id'],
      organizationId: json['organization_id'],
      partyId: json['party_id'],
      userId: json['user_id'],
      invoicePrefix: json['invoice_prefix'],
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      paymentTerms: json['payment_terms'],
      dueDate: DateTime.parse(json['due_date']),
      subtotal: double.parse(json['subtotal'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      additionalCharges: double.parse(json['additional_charges'].toString()),
      roundOff: double.parse(json['round_off'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      amountReceived: double.parse(json['amount_received'].toString()),
      balanceAmount: double.parse(json['balance_amount'].toString()),
      paymentMode: json['payment_mode'],
      paymentStatus: json['payment_status'],
      notes: json['notes'],
      termsConditions: json['terms_conditions'],
      bankDetails: json['bank_details'],
      showBankDetails: json['show_bank_details'] ?? true,
      autoRoundOff: json['auto_round_off'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      irn: json['irn'],
      ackNo: json['ack_no'],
      ackDate:
          json['ack_date'] != null ? DateTime.parse(json['ack_date']) : null,
      qrCodeData: json['qr_code_data'],
      qrCodeImage: json['qr_code_image'],
      signedInvoice: json['signed_invoice'],
      wayBillNo: json['way_bill_no'],
      wayBillDate: json['way_bill_date'] != null
          ? DateTime.parse(json['way_bill_date'])
          : null,
      invoiceStatus: json['invoice_status'] ?? 'draft',
      isEInvoiceGenerated: json['is_einvoice_generated'] ?? false,
      isReconciled: json['is_reconciled'] ?? false,
      reconciledAt: json['reconciled_at'] != null
          ? DateTime.parse(json['reconciled_at'])
          : null,
      party: json['party'] != null ? PartyBasic.fromJson(json['party']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => SalesInvoiceItem.fromJson(i))
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
      'invoice_prefix': invoicePrefix,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0],
      'payment_terms': paymentTerms,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'additional_charges': additionalCharges,
      'round_off': roundOff,
      'total_amount': totalAmount,
      'amount_received': amountReceived,
      'balance_amount': balanceAmount,
      'payment_mode': paymentMode,
      'payment_status': paymentStatus,
      'notes': notes,
      'terms_conditions': termsConditions,
      'bank_details': bankDetails,
      'show_bank_details': showBankDetails,
      'auto_round_off': autoRoundOff,
      'irn': irn,
      'ack_no': ackNo,
      'ack_date': ackDate?.toIso8601String(),
      'qr_code_data': qrCodeData,
      'qr_code_image': qrCodeImage,
      'signed_invoice': signedInvoice,
      'way_bill_no': wayBillNo,
      'way_bill_date': wayBillDate?.toIso8601String(),
      'invoice_status': invoiceStatus,
      'is_einvoice_generated': isEInvoiceGenerated,
      'is_reconciled': isReconciled,
      'reconciled_at': reconciledAt?.toIso8601String(),
    };
  }

  String get fullInvoiceNumber => '$invoicePrefix$invoiceNumber';

  String get dueInText {
    if (paymentStatus == 'paid') return '-';

    final today = DateTime.now();
    final difference = dueDate.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue by ${difference.abs()} days';
    }
    return '$difference Days';
  }

  bool get isOverdue {
    if (paymentStatus == 'paid') return false;
    return DateTime.now().isAfter(dueDate);
  }

  bool get isDraft => invoiceStatus == 'draft';

  bool get isFinal => invoiceStatus == 'final';

  bool get isEditable => isDraft && !isEInvoiceGenerated;

  bool get hasIRN => irn != null && irn!.isNotEmpty;

  bool get hasWayBill => wayBillNo != null && wayBillNo!.isNotEmpty;
}

class SalesInvoiceItem {
  final int? id;
  final int salesInvoiceId;
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

  SalesInvoiceItem({
    this.id,
    required this.salesInvoiceId,
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

  factory SalesInvoiceItem.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItem(
      id: json['id'],
      salesInvoiceId: json['sales_invoice_id'],
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
