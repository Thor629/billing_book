import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_config.dart';
import 'auth_service.dart';

class GstReportService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getGstSummary(
    int organizationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/gst-reports/summary').replace(
        queryParameters: {
          'organization_id': organizationId.toString(),
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load GST summary');
    }
  }

  Future<Map<String, dynamic>> getGstByRate(
    int organizationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/gst-reports/by-rate').replace(
        queryParameters: {
          'organization_id': organizationId.toString(),
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load GST by rate');
    }
  }

  Future<List<dynamic>> getGstTransactions(
    int organizationId,
    DateTime startDate,
    DateTime endDate, {
    String type = 'all',
  }) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/gst-reports/transactions').replace(
        queryParameters: {
          'organization_id': organizationId.toString(),
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'type': type,
        },
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load GST transactions');
    }
  }
}
