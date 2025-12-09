class DebitNote {
  final int id;
  final int organizationId;
  final int partyId;
  final int? purchaseInvoiceId;
  final String debitNoteNumber;
  final DateTime debitNoteDate;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? paymentMode;
  final int? bankAccountId;
  final double amountPaid;
  final String status;
  final String? reason;
  final String? notes;
  final String? partyName;
  final List<DebitNoteItem>? items;

  DebitNote({
    required this.id,
    required this.organizationId,
    required this.partyId,
    this.purchaseInvoiceId,
    required this.debitNoteNumber,
    required this.debitNoteDate,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.paymentMode,
    this.bankAccountId,
    required this.amountPaid,
    required this.status,
    this.reason,
    this.notes,
    this.partyName,
    this.items,
  });

  factory DebitNote.fromJson(Map<String, dynamic> json) {
    return DebitNote(
      id: int.parse(json['id'].toString()),
      organizationId: int.parse(json['organization_id'].toString()),
      partyId: int.parse(json['party_id'].toString()),
      purchaseInvoiceId: json['purchase_invoice_id'] != null
          ? int.parse(json['purchase_invoice_id'].toString())
          : null,
      debitNoteNumber: json['debit_note_number'] ?? '',
      debitNoteDate: DateTime.parse(json['debit_note_date']),
      subtotal: double.parse(json['subtotal'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      paymentMode: json['payment_mode'],
      bankAccountId: json['bank_account_id'] != null
          ? int.parse(json['bank_account_id'].toString())
          : null,
      amountPaid: double.parse(json['amount_paid']?.toString() ?? '0'),
      status: json['status'] ?? 'draft',
      reason: json['reason'],
      notes: json['notes'],
      partyName: json['party']?['name'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => DebitNoteItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'party_id': partyId,
      'purchase_invoice_id': purchaseInvoiceId,
      'debit_note_number': debitNoteNumber,
      'debit_note_date': debitNoteDate.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_mode': paymentMode,
      'bank_account_id': bankAccountId,
      'amount_paid': amountPaid,
      'status': status,
      'reason': reason,
      'notes': notes,
    };
  }
}

class DebitNoteItem {
  final int id;
  final int debitNoteId;
  final int? itemId;
  final String description;
  final double quantity;
  final String unit;
  final double rate;
  final double taxRate;
  final double amount;
  final String? itemName;

  DebitNoteItem({
    required this.id,
    required this.debitNoteId,
    this.itemId,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.taxRate,
    required this.amount,
    this.itemName,
  });

  factory DebitNoteItem.fromJson(Map<String, dynamic> json) {
    return DebitNoteItem(
      id: int.parse(json['id'].toString()),
      debitNoteId: int.parse(json['debit_note_id'].toString()),
      itemId: json['item_id'] != null
          ? int.parse(json['item_id'].toString())
          : null,
      description: json['description'] ?? '',
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'] ?? 'pcs',
      rate: double.parse(json['rate'].toString()),
      taxRate: double.parse(json['tax_rate'].toString()),
      amount: double.parse(json['amount'].toString()),
      itemName: json['item']?['name'] ?? '',
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
