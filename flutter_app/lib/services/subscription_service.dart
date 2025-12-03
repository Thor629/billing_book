import '../core/constants/app_config.dart';
import '../models/subscription_model.dart';
import 'api_client.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  Future<SubscriptionModel?> getCurrentSubscription() async {
    final response = await _apiClient.get(AppConfig.userSubscriptionEndpoint);
    final data = _apiClient.handleResponse(response);

    if (data['subscription'] != null) {
      return SubscriptionModel.fromJson(data['subscription']);
    }
    return null;
  }

  Future<SubscriptionModel> subscribe(int planId, String billingCycle) async {
    final response = await _apiClient.post(
      AppConfig.subscribeEndpoint,
      {
        'plan_id': planId,
        'billing_cycle': billingCycle,
      },
    );
    final data = _apiClient.handleResponse(response);
    return SubscriptionModel.fromJson(data['subscription']);
  }

  Future<SubscriptionModel> changePlan(int planId) async {
    final response = await _apiClient.put(
      '${AppConfig.userSubscriptionEndpoint}/change-plan',
      {'plan_id': planId},
    );
    final data = _apiClient.handleResponse(response);
    return SubscriptionModel.fromJson(data['subscription']);
  }

  Future<void> cancelSubscription() async {
    final response = await _apiClient.delete(
      '${AppConfig.userSubscriptionEndpoint}/cancel',
    );
    _apiClient.handleResponse(response);
  }
}
