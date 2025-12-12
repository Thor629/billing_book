import 'dart:convert';
import '../models/quotation_model.dart';
import 'api_client.dart';

class QuotationService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getQuotations({
    required int organizationId,
    String? dateFilter,
    String? statusFilter,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (dateFilter != null) queryParams['date_filter'] = dateFilter;
      if (statusFilter != null) queryParams['status_filter'] = statusFilter;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '/quotations?$queryString',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'quotations': (data['quotations']['data'] as List)
              .map((json) => Quotation.fromJson(json))
              .toList(),
          'summary': data['summary'],
          'pagination': {
            'current_page': data['quotations']['current_page'],
            'last_page': data['quotations']['last_page'],
            'total': data['quotations']['total'],
          },
        };
      } else {
        throw Exception('Failed to load quotations');
      }
    } catch (e) {
      throw Exception('Error fetching quotations: $e');
    }
  }

  Future<Quotation> getQuotation(int id, int organizationId) async {
    try {
      final response = await _apiClient.get(
        '/quotations/$id',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 200) {
        return Quotation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load quotation');
      }
    } catch (e) {
      throw Exception('Error fetching quotation: $e');
    }
  }

  Future<Quotation> createQuotation(
      int organizationId, Map<String, dynamic> quotationData) async {
    try {
      final response = await _apiClient.post(
        '/quotations',
        quotationData,
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Quotation.fromJson(data['quotation']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create quotation');
      }
    } catch (e) {
      throw Exception('Error creating quotation: $e');
    }
  }

  Future<Quotation> updateQuotation(
      int id, int organizationId, Map<String, dynamic> quotationData) async {
    try {
      final response = await _apiClient.put(
        '/quotations/$id',
        quotationData,
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quotation.fromJson(data['quotation']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update quotation');
      }
    } catch (e) {
      throw Exception('Error updating quotation: $e');
    }
  }

  Future<void> deleteQuotation(int id, int organizationId) async {
    try {
      final response = await _apiClient.delete(
        '/quotations/$id',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete quotation');
      }
    } catch (e) {
      throw Exception('Error deleting quotation: $e');
    }
  }

  Future<Map<String, dynamic>> getNextQuotationNumber(
      int organizationId) async {
    try {
      final response = await _apiClient.get(
        '/quotations/next-number',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next quotation number');
      }
    } catch (e) {
      throw Exception('Error fetching next quotation number: $e');
    }
  }
}
