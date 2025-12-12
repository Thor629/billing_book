import '../models/organization_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class OrganizationService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();
  static const String _selectedOrgKey = 'selected_organization_id';

  Future<List<OrganizationModel>> getOrganizations() async {
    final response = await _apiClient.get('/organizations');
    final data = _apiClient.handleResponse(response);

    final List<dynamic> orgsJson = data['data'];
    return orgsJson.map((json) => OrganizationModel.fromJson(json)).toList();
  }

  Future<OrganizationModel> createOrganization(
      Map<String, dynamic> orgData) async {
    final response = await _apiClient.post('/organizations', orgData);
    final data = _apiClient.handleResponse(response);
    return OrganizationModel.fromJson(data['organization']);
  }

  Future<OrganizationModel> getOrganization(int id) async {
    final response = await _apiClient.get('/organizations/$id');
    final data = _apiClient.handleResponse(response);
    return OrganizationModel.fromJson(data['organization']);
  }

  Future<OrganizationModel> updateOrganization(
      int id, Map<String, dynamic> orgData) async {
    final response = await _apiClient.put('/organizations/$id', orgData);
    final data = _apiClient.handleResponse(response);
    return OrganizationModel.fromJson(data['organization']);
  }

  Future<void> deleteOrganization(int id) async {
    final response = await _apiClient.delete('/organizations/$id');
    _apiClient.handleResponse(response);
  }

  // Save selected organization ID
  Future<void> saveSelectedOrganizationId(int orgId) async {
    await _storage.write(_selectedOrgKey, orgId.toString());
  }

  // Get selected organization ID
  Future<int?> getSelectedOrganizationId() async {
    final orgIdStr = await _storage.read(_selectedOrgKey);
    if (orgIdStr != null) {
      return int.tryParse(orgIdStr);
    }
    return null;
  }

  // Clear selected organization
  Future<void> clearSelectedOrganization() async {
    await _storage.delete(_selectedOrgKey);
  }
}
