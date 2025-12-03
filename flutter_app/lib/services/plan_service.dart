import '../core/constants/app_config.dart';
import '../models/plan_model.dart';
import 'api_client.dart';

class PlanService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PlanModel>> getPlans({bool adminView = false}) async {
    final endpoint =
        adminView ? AppConfig.adminPlansEndpoint : AppConfig.plansEndpoint;

    final response = await _apiClient.get(endpoint, includeAuth: adminView);
    final data = _apiClient.handleResponse(response);

    final List<dynamic> plansJson = data['data'];
    return plansJson.map((json) => PlanModel.fromJson(json)).toList();
  }

  Future<PlanModel> createPlan(Map<String, dynamic> planData) async {
    final response = await _apiClient.post(
      AppConfig.adminPlansEndpoint,
      planData,
    );
    final data = _apiClient.handleResponse(response);
    return PlanModel.fromJson(data['plan']);
  }

  Future<PlanModel> updatePlan(int id, Map<String, dynamic> planData) async {
    final response = await _apiClient.put(
      '${AppConfig.adminPlansEndpoint}/$id',
      planData,
    );
    final data = _apiClient.handleResponse(response);
    return PlanModel.fromJson(data['plan']);
  }

  Future<void> deletePlan(int id) async {
    final response = await _apiClient.delete(
      '${AppConfig.adminPlansEndpoint}/$id',
    );
    _apiClient.handleResponse(response);
  }
}
