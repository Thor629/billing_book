class PaymentIn {
  final int? id;
  final int organizationId;
  final int partyId;
  final int userId;
  final String paymentNumber;
  final DateTime paymentDate;
  final double amount;
  final String paymentMode;
  final String? notes;
  final String? referenceNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related models
  final PartyBasic? party;

  PaymentIn({
    this.id,
    required this.organizationId,
    required this.partyId,
    required this.userId,
    required this.paymentNumber,
    required this.paymentDate,
    required this.amount,
    required this.paymentMode,
    this.notes,
    this.referenceNumber,
    this.createdAt,
    this.updatedAt,
    this.party,
  });

  factory PaymentIn.fromJson(Map<String, dynamic> json) {
    return PaymentIn(
      id: json['id'],
      organizationId: json['organization_id'],
      partyId: json['party_id'],
      userId: json['user_id'],
      paymentNumber: json['payment_number'],
      paymentDate: DateTime.parse(json['payment_date']),
      amount: double.parse(json['amount'].toString()),
      paymentMode: json['payment_mode'],
      notes: json['notes'],
      referenceNumber: json['reference_number'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      party: json['party'] != null ? PartyBasic.fromJson(json['party']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'party_id': partyId,
      'user_id': userId,
      'payment_number': paymentNumber,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'amount': amount,
      'payment_mode': paymentMode,
      'notes': notes,
      'reference_number': referenceNumber,
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
