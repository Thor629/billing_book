import 'dart:convert';
import '../models/sales_return_model.dart';
import 'api_client.dart';

class SalesReturnService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getReturns({
    required int organizationId,
    String? dateFilter,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, String>{
        'organization_id': organizationId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (dateFilter != null) queryParams['date_filter'] = dateFilter;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get('/sales-returns?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'returns': (data['returns']['data'] as List)
              .map((json) => SalesReturn.fromJson(json))
              .toList(),
          'pagination': {
            'current_page': data['returns']['current_page'],
            'last_page': data['returns']['last_page'],
            'total': data['returns']['total'],
          },
        };
      } else {
        throw Exception('Failed to load sales returns');
      }
    } catch (e) {
      throw Exception('Error fetching sales returns: $e');
    }
  }

  Future<SalesReturn> getReturn(int id) async {
    try {
      final response = await _apiClient.get('/sales-returns/$id');

      if (response.statusCode == 200) {
        return SalesReturn.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load sales return');
      }
    } catch (e) {
      throw Exception('Error fetching sales return: $e');
    }
  }

  Future<SalesReturn> createReturn(Map<String, dynamic> returnData) async {
    try {
      final response = await _apiClient.post('/sales-returns', returnData);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return SalesReturn.fromJson(data['return']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create sales return');
      }
    } catch (e) {
      throw Exception('Error creating sales return: $e');
    }
  }

  Future<SalesReturn> updateReturn(
      int id, Map<String, dynamic> returnData) async {
    try {
      final response = await _apiClient.put('/sales-returns/$id', returnData);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SalesReturn.fromJson(data['return']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update sales return');
      }
    } catch (e) {
      throw Exception('Error updating sales return: $e');
    }
  }

  Future<void> deleteReturn(int id) async {
    try {
      final response = await _apiClient.delete('/sales-returns/$id');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete sales return');
      }
    } catch (e) {
      throw Exception('Error deleting sales return: $e');
    }
  }

  Future<Map<String, dynamic>> getNextReturnNumber(int organizationId) async {
    try {
      final response = await _apiClient
          .get('/sales-returns/next-number?organization_id=$organizationId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next return number');
      }
    } catch (e) {
      throw Exception('Error fetching next return number: $e');
    }
  }
}
