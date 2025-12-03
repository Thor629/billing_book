import '../models/godown_model.dart';
import 'api_client.dart';

class GodownService {
  final ApiClient _apiClient = ApiClient();

  Future<List<GodownModel>> getGodowns(int organizationId) async {
    final response =
        await _apiClient.get('/godowns?organization_id=$organizationId');
    final data = _apiClient.handleResponse(response);
    final List<dynamic> godownsJson = data['data'];
    return godownsJson.map((json) => GodownModel.fromJson(json)).toList();
  }

  Future<GodownModel> createGodown(Map<String, dynamic> godownData) async {
    final response = await _apiClient.post('/godowns', godownData);
    final data = _apiClient.handleResponse(response);
    return GodownModel.fromJson(data['godown']);
  }

  Future<GodownModel> getGodown(int id) async {
    final response = await _apiClient.get('/godowns/$id');
    final data = _apiClient.handleResponse(response);
    return GodownModel.fromJson(data['godown']);
  }

  Future<GodownModel> updateGodown(
      int id, Map<String, dynamic> godownData) async {
    final response = await _apiClient.put('/godowns/$id', godownData);
    final data = _apiClient.handleResponse(response);
    return GodownModel.fromJson(data['godown']);
  }

  Future<void> deleteGodown(int id) async {
    final response = await _apiClient.delete('/godowns/$id');
    _apiClient.handleResponse(response);
  }
}
