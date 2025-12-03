import '../core/constants/app_config.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get(AppConfig.userProfileEndpoint);
    return _apiClient.handleResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    final response = await _apiClient.put(
      AppConfig.userProfileEndpoint,
      profileData,
    );
    return _apiClient.handleResponse(response);
  }

  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    final response = await _apiClient.put(
      '${AppConfig.userProfileEndpoint}/password',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
    );
    _apiClient.handleResponse(response);
  }
}
