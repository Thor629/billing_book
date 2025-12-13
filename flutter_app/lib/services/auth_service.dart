import 'dart:convert';
import '../core/constants/app_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('AuthService: Attempting login for $email');

    final response = await _apiClient.post(
      AppConfig.loginEndpoint,
      {'email': email, 'password': password},
      includeAuth: false,
    );

    final data = _apiClient.handleResponse(response);

    // Save token
    await _apiClient.saveToken(data['token']);
    print('AuthService: Token saved successfully');

    // Save token expiry
    if (data['expires_at'] != null) {
      await _storage.write(AppConfig.tokenExpiryKey, data['expires_at']);
      print('AuthService: Token expiry saved: ${data['expires_at']}');
    }

    // Save user data
    await _storage.write(AppConfig.userKey, jsonEncode(data['user']));
    print('AuthService: User data saved');

    return data;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(AppConfig.logoutEndpoint, {});
    } catch (e) {
      // Continue with local logout even if API call fails
      print('AuthService: Logout API call failed: $e');
    }

    // Clear local storage
    await _apiClient.deleteToken();
    await _storage.delete(AppConfig.userKey);
    await _storage.delete(AppConfig.tokenExpiryKey);
    print('AuthService: All auth data cleared');
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
    final userJson = await _storage.read(AppConfig.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    if (token == null) {
      print('AuthService: No token found');
      return false;
    }

    // Check if token is expired
    final expiryStr = await _storage.read(AppConfig.tokenExpiryKey);
    if (expiryStr != null) {
      try {
        final expiry = DateTime.parse(expiryStr);
        final now = DateTime.now();
        if (now.isAfter(expiry)) {
          print('AuthService: Token expired at $expiry');
          // Clear expired token
          await logout();
          return false;
        }
        print('AuthService: Token valid until $expiry');
      } catch (e) {
        print('AuthService: Error parsing expiry date: $e');
      }
    }

    return true;
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
    print('AuthService: Attempting registration for $email');

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
    print('AuthService: Token saved successfully');

    // Save token expiry
    if (data['expires_at'] != null) {
      await _storage.write(AppConfig.tokenExpiryKey, data['expires_at']);
      print('AuthService: Token expiry saved: ${data['expires_at']}');
    }

    // Save user data
    await _storage.write(AppConfig.userKey, jsonEncode(data['user']));
    print('AuthService: User data saved');

    return data;
  }
}
