import 'dart:convert';
import 'api_client.dart';

class PurchaseInvoiceService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getPurchaseInvoices({
    int? organizationId,
    String? dateFilter,
    String? statusFilter,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      if (organizationId == null) {
        throw Exception('No organization selected');
      }

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
        '/purchase-invoices?$queryString',
        customHeaders: {
          'X-Organization-Id': organizationId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load purchase invoices');
      }
    } catch (e) {
      throw Exception('Error fetching purchase invoices: $e');
    }
  }

  Future<Map<String, dynamic>> createPurchaseInvoice(
      Map<String, dynamic> invoiceData) async {
    try {
      final organizationId = invoiceData['organization_id'];

      if (organizationId == null) {
        throw Exception('No organization selected');
      }

      final response = await _apiClient.post(
        '/purchase-invoices',
        invoiceData,
        customHeaders: {
          'X-Organization-Id': organizationId.toString(),
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        // Try to parse error response
        try {
          final error = json.decode(response.body);
          final errorMessage =
              error['message'] ?? 'Failed to create purchase invoice';
          // Include validation errors if present
          if (error['errors'] != null) {
            final errors = error['errors'] as Map<String, dynamic>;
            final errorDetails =
                errors.entries.map((e) => '${e.key}: ${e.value}').join(', ');
            throw Exception('$errorMessage - $errorDetails');
          }
          throw Exception(errorMessage);
        } catch (e) {
          // If JSON parsing fails, return raw response
          throw Exception(
              'Failed to create purchase invoice. Status: ${response.statusCode}, Body: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error creating purchase invoice: $e');
    }
  }

  Future<Map<String, dynamic>> getNextInvoiceNumber(int organizationId) async {
    try {
      final response = await _apiClient.get(
          '/purchase-invoices/next-number?organization_id=$organizationId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next invoice number');
      }
    } catch (e) {
      throw Exception('Error fetching next invoice number: $e');
    }
  }

  Future<void> deletePurchaseInvoice(int id, int organizationId) async {
    try {
      final response = await _apiClient.delete(
        '/purchase-invoices/$id',
        customHeaders: {
          'X-Organization-Id': organizationId.toString(),
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to delete purchase invoice');
      }
    } catch (e) {
      throw Exception('Error deleting purchase invoice: $e');
    }
  }
}
