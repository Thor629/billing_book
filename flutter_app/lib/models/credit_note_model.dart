class CreditNote {
  final int id;
  final int organizationId;
  final int partyId;
  final int userId;
  final int? salesInvoiceId;
  final String creditNoteNumber;
  final DateTime creditNoteDate;
  final String? invoiceNumber;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final String? paymentMode;
  final int? bankAccountId;
  final double amountReceived;
  final String status;
  final String? reason;
  final String? notes;
  final String? termsConditions;
  final String? partyName;
  final List<CreditNoteItem>? items;

  CreditNote({
    required this.id,
    required this.organizationId,
    required this.partyId,
    required this.userId,
    this.salesInvoiceId,
    required this.creditNoteNumber,
    required this.creditNoteDate,
    this.invoiceNumber,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.totalAmount,
    this.paymentMode,
    this.bankAccountId,
    required this.amountReceived,
    required this.status,
    this.reason,
    this.notes,
    this.termsConditions,
    this.partyName,
    this.items,
  });

  factory CreditNote.fromJson(Map<String, dynamic> json) {
    return CreditNote(
      id: int.parse(json['id'].toString()),
      organizationId: int.parse(json['organization_id'].toString()),
      partyId: int.parse(json['party_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      salesInvoiceId: json['sales_invoice_id'] != null
          ? int.parse(json['sales_invoice_id'].toString())
          : null,
      creditNoteNumber: json['credit_note_number'] ?? '',
      creditNoteDate: DateTime.parse(json['credit_note_date']),
      invoiceNumber: json['invoice_number'],
      subtotal: double.parse(json['subtotal'].toString()),
      discount: double.parse(json['discount'].toString()),
      tax: double.parse(json['tax'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      paymentMode: json['payment_mode'],
      bankAccountId: json['bank_account_id'] != null
          ? int.parse(json['bank_account_id'].toString())
          : null,
      amountReceived: double.parse(json['amount_received']?.toString() ?? '0'),
      status: json['status'] ?? 'draft',
      reason: json['reason'],
      notes: json['notes'],
      termsConditions: json['terms_conditions'],
      partyName: json['party']?['name'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CreditNoteItem.fromJson(item))
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
      'sales_invoice_id': salesInvoiceId,
      'credit_note_number': creditNoteNumber,
      'credit_note_date': creditNoteDate.toIso8601String().split('T')[0],
      'invoice_number': invoiceNumber,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total_amount': totalAmount,
      'payment_mode': paymentMode,
      'bank_account_id': bankAccountId,
      'amount_received': amountReceived,
      'status': status,
      'reason': reason,
      'notes': notes,
      'terms_conditions': termsConditions,
    };
  }
}

class CreditNoteItem {
  final int id;
  final int creditNoteId;
  final int itemId;
  final String? hsnSac;
  final String? itemCode;
  final double quantity;
  final double price;
  final double discount;
  final double taxRate;
  final double taxAmount;
  final double total;
  final String? itemName;

  CreditNoteItem({
    required this.id,
    required this.creditNoteId,
    required this.itemId,
    this.hsnSac,
    this.itemCode,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    this.itemName,
  });

  factory CreditNoteItem.fromJson(Map<String, dynamic> json) {
    return CreditNoteItem(
      id: int.parse(json['id'].toString()),
      creditNoteId: int.parse(json['credit_note_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      hsnSac: json['hsn_sac'],
      itemCode: json['item_code'],
      quantity: double.parse(json['quantity'].toString()),
      price: double.parse(json['price'].toString()),
      discount: double.parse(json['discount'].toString()),
      taxRate: double.parse(json['tax_rate'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      total: double.parse(json['total'].toString()),
      itemName: json['item']?['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'hsn_sac': hsnSac,
      'item_code': itemCode,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total': total,
    };
  }
}
