class GodownModel {
  final int id;
  final int organizationId;
  final String name;
  final String code;
  final String? address;
  final String? contactPerson;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  GodownModel({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    this.address,
    this.contactPerson,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  factory GodownModel.fromJson(Map<String, dynamic> json) {
    return GodownModel(
      id: json['id'] ?? 0,
      organizationId: json['organization_id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      address: json['address'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
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
      'code': code,
      'address': address,
      'contact_person': contactPerson,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
