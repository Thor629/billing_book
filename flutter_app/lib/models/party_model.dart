class PartyModel {
  final int id;
  final int organizationId;
  final String name;
  final String? contactPerson;
  final String? email;
  final String phone;
  final String? gstNo;
  final String? billingAddress;
  final String? shippingAddress;
  final String partyType; // customer, vendor, both
  final bool isActive;
  final DateTime createdAt;

  PartyModel({
    required this.id,
    required this.organizationId,
    required this.name,
    this.contactPerson,
    this.email,
    required this.phone,
    this.gstNo,
    this.billingAddress,
    this.shippingAddress,
    required this.partyType,
    required this.isActive,
    required this.createdAt,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] ?? 0,
      organizationId: json['organization_id'] ?? 0,
      name: json['name'] ?? '',
      contactPerson: json['contact_person'],
      email: json['email'],
      phone: json['phone'] ?? '',
      gstNo: json['gst_no'],
      billingAddress: json['billing_address'],
      shippingAddress: json['shipping_address'],
      partyType: json['party_type'] ?? 'customer',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'gst_no': gstNo,
      'billing_address': billingAddress,
      'shipping_address': shippingAddress,
      'party_type': partyType,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get partyTypeLabel {
    switch (partyType) {
      case 'customer':
        return 'Customer';
      case 'vendor':
        return 'Vendor';
      case 'both':
        return 'Both';
      default:
        return partyType;
    }
  }
}
