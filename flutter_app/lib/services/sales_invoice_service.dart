import 'dart:convert';
import '../models/sales_invoice_model.dart';
import 'api_client.dart';

class SalesInvoiceService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getInvoices({
    String? dateFilter,
    String? paymentStatus,
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
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get('/sales-invoices?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'invoices': (data['invoices']['data'] as List)
              .map((json) => SalesInvoice.fromJson(json))
              .toList(),
          'summary': data['summary'],
          'pagination': {
            'current_page': data['invoices']['current_page'],
            'last_page': data['invoices']['last_page'],
            'total': data['invoices']['total'],
          },
        };
      } else {
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      throw Exception('Error fetching invoices: $e');
    }
  }

  Future<SalesInvoice> getInvoice(int id) async {
    try {
      final response = await _apiClient.get('/sales-invoices/$id');

      if (response.statusCode == 200) {
        return SalesInvoice.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load invoice');
      }
    } catch (e) {
      throw Exception('Error fetching invoice: $e');
    }
  }

  Future<SalesInvoice> createInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final response = await _apiClient.post('/sales-invoices', invoiceData);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return SalesInvoice.fromJson(data['invoice']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create invoice');
      }
    } catch (e) {
      throw Exception('Error creating invoice: $e');
    }
  }

  Future<SalesInvoice> updateInvoice(
      int id, Map<String, dynamic> invoiceData) async {
    try {
      final response = await _apiClient.put('/sales-invoices/$id', invoiceData);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SalesInvoice.fromJson(data['invoice']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update invoice');
      }
    } catch (e) {
      throw Exception('Error updating invoice: $e');
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      final response = await _apiClient.delete('/sales-invoices/$id');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete invoice');
      }
    } catch (e) {
      throw Exception('Error deleting invoice: $e');
    }
  }

  Future<Map<String, dynamic>> getNextInvoiceNumber(
      {String prefix = 'INV'}) async {
    try {
      final response = await _apiClient.get(
        '/sales-invoices/next-number?prefix=${Uri.encodeComponent(prefix)}',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next invoice number');
      }
    } catch (e) {
      throw Exception('Error fetching next invoice number: $e');
    }
  }
}
