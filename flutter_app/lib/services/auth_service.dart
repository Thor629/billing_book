import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      AppConfig.loginEndpoint,
      {'email': email, 'password': password},
      includeAuth: false,
    );

    final data = _apiClient.handleResponse(response);

    // Save token
    await _apiClient.saveToken(data['token']);

    // Save user data
    await _storage.write(
      key: AppConfig.userKey,
      value: jsonEncode(data['user']),
    );

    return data;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(AppConfig.logoutEndpoint, {});
    } catch (e) {
      // Continue with local logout even if API call fails
    }

    // Clear local storage
    await _apiClient.deleteToken();
    await _storage.delete(key: AppConfig.userKey);
  }

  // Refresh token
  Future<String> refreshToken() async {
    final response = await _apiClient.post(AppConfig.refreshEndpoint, {});
    final data = _apiClient.handleResponse(response);

    // Save new token
    await _apiClient.saveToken(data['token']);

    return data['token'];
  }

  // Get stored user
  Future<UserModel?> getStoredUser() async {
    final userJson = await _storage.read(key: AppConfig.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null;
  }

  // Get token
  Future<String?> getToken() async {
    return await _apiClient.getToken();
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await _apiClient.post(
      AppConfig.registerEndpoint,
      {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      includeAuth: false,
    );

    final data = _apiClient.handleResponse(response);

    // Save token
    await _apiClient.saveToken(data['token']);

    // Save user data
    await _storage.write(
      key: AppConfig.userKey,
      value: jsonEncode(data['user']),
    );

    return data;
  }
}
