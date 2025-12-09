class PaymentOut {
  final int? id;
  final int organizationId;
  final int partyId;
  final int? purchaseInvoiceId;
  final String paymentNumber;
  final String paymentDate;
  final double amount;
  final String paymentMethod;
  final int? bankAccountId;
  final String? referenceNumber;
  final String? notes;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Party? party;

  PaymentOut({
    this.id,
    required this.organizationId,
    required this.partyId,
    this.purchaseInvoiceId,
    required this.paymentNumber,
    required this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    this.bankAccountId,
    this.referenceNumber,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.party,
  });

  factory PaymentOut.fromJson(Map<String, dynamic> json) {
    return PaymentOut(
      id: json['id'],
      organizationId: json['organization_id'],
      partyId: json['party_id'],
      purchaseInvoiceId: json['purchase_invoice_id'],
      paymentNumber: json['payment_number'],
      paymentDate: json['payment_date'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'],
      bankAccountId: json['bank_account_id'],
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      status: json['status'] ?? 'completed',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      party: json['party'] != null ? Party.fromJson(json['party']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'party_id': partyId,
      'purchase_invoice_id': purchaseInvoiceId,
      'payment_number': paymentNumber,
      'payment_date': paymentDate,
      'amount': amount,
      'payment_method': paymentMethod,
      'bank_account_id': bankAccountId,
      'reference_number': referenceNumber,
      'notes': notes,
      'status': status,
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
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}
