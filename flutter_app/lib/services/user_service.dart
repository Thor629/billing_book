import '../core/constants/app_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
  }) async {
    String endpoint =
        '${AppConfig.adminUsersEndpoint}?page=$page&per_page=$perPage';
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=$search';
    }
    if (status != null && status.isNotEmpty) {
      endpoint += '&status=$status';
    }

    final response = await _apiClient.get(endpoint);
    return _apiClient.handleResponse(response);
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final response = await _apiClient.post(
      AppConfig.adminUsersEndpoint,
      userData,
    );
    final data = _apiClient.handleResponse(response);
    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await _apiClient.put(
      '${AppConfig.adminUsersEndpoint}/$id',
      userData,
    );
    final data = _apiClient.handleResponse(response);
    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> updateUserStatus(int id, String status) async {
    final response = await _apiClient.patch(
      '${AppConfig.adminUsersEndpoint}/$id/status',
      {'status': status},
    );
    final data = _apiClient.handleResponse(response);
    return UserModel.fromJson(data['user']);
  }

  Future<void> deleteUser(int id) async {
    final response = await _apiClient.delete(
      '${AppConfig.adminUsersEndpoint}/$id',
    );
    _apiClient.handleResponse(response);
  }
}
