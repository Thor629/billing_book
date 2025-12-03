import 'plan_model.dart';

class SubscriptionModel {
  final int id;
  final int userId;
  final int planId;
  final String billingCycle;
  final String status;
  final DateTime startedAt;
  final DateTime expiresAt;
  final PlanModel? plan;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.billingCycle,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
    this.plan,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      billingCycle: json['billing_cycle'],
      status: json['status'],
      startedAt: DateTime.parse(json['started_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      plan: json['plan'] != null ? PlanModel.fromJson(json['plan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'billing_cycle': billingCycle,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'plan': plan?.toJson(),
    };
  }

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());
  bool get isExpired => expiresAt.isBefore(DateTime.now());
}
