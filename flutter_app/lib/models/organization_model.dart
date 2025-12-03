class OrganizationModel {
  final int id;
  final String name;
  final String? gstNo;
  final String? billingAddress;
  final String mobileNo;
  final String email;
  final int createdBy;
  final bool isActive;
  final String? role; // From pivot table
  final DateTime createdAt;

  OrganizationModel({
    required this.id,
    required this.name,
    this.gstNo,
    this.billingAddress,
    required this.mobileNo,
    required this.email,
    required this.createdBy,
    required this.isActive,
    this.role,
    required this.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gstNo: json['gst_no'],
      billingAddress: json['billing_address'],
      mobileNo: json['mobile_no'] ?? '',
      email: json['email'] ?? '',
      createdBy: json['created_by'] ?? 0,
      isActive: json['is_active'] ?? true,
      role: json['pivot']?['role'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gst_no': gstNo,
      'billing_address': billingAddress,
      'mobile_no': mobileNo,
      'email': email,
      'created_by': createdBy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isOwner => role == 'owner';
}
