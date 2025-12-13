import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_config.dart';
import 'storage_service.dart';

class ApiClient {
  final StorageService _storage = StorageService();
  final http.Client _client = http.Client();

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(AppConfig.tokenKey);
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(AppConfig.tokenKey, token);
  }

  // Delete token
  Future<void> deleteToken() async {
    await _storage.delete(AppConfig.tokenKey);
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        print('ApiClient: Token found and added to headers');
        print('ApiClient: Token preview: ${token.substring(0, 20)}...');
      } else {
        print('ApiClient: WARNING - No token found in storage!');
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(String endpoint,
      {bool includeAuth = true, Map<String, String>? customHeaders}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    // Add custom headers if provided
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    try {
      final response = await _client
          .get(url, headers: headers)
          .timeout(AppConfig.connectionTimeout);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    // Add custom headers if provided
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    try {
      final response = await _client
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(AppConfig.connectionTimeout);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    // Add custom headers if provided
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    try {
      final response = await _client
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(AppConfig.connectionTimeout);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PATCH request
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    try {
      final response = await _client
          .patch(url, headers: headers, body: jsonEncode(body))
          .timeout(AppConfig.connectionTimeout);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint,
      {bool includeAuth = true, Map<String, String>? customHeaders}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    // Add custom headers if provided
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    try {
      final response = await _client
          .delete(url, headers: headers)
          .timeout(AppConfig.connectionTimeout);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle API response
  Map<String, dynamic> handleResponse(http.Response response) {
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      print('401 Unauthorized - Token may be expired or invalid');
      throw Exception('Unauthorized');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body);
      // Extract specific validation errors
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError[0]);
        }
      }
      throw Exception(data['message'] ?? 'Validation error');
    } else {
      throw Exception('An error occurred. Please try again later.');
    }
  }
}
