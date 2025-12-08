import 'dart:convert';
import '../models/payment_in_model.dart';
import 'api_client.dart';

class PaymentInService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getPayments({
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

      final response = await _apiClient.get('/payment-ins?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'payments': (data['payments']['data'] as List)
              .map((json) => PaymentIn.fromJson(json))
              .toList(),
          'summary': data['summary'],
          'pagination': {
            'current_page': data['payments']['current_page'],
            'last_page': data['payments']['last_page'],
            'total': data['payments']['total'],
          },
        };
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  Future<PaymentIn> getPayment(int id) async {
    try {
      final response = await _apiClient.get('/payment-ins/$id');

      if (response.statusCode == 200) {
        return PaymentIn.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load payment');
      }
    } catch (e) {
      throw Exception('Error fetching payment: $e');
    }
  }

  Future<PaymentIn> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiClient.post('/payment-ins', paymentData);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return PaymentIn.fromJson(data['payment']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create payment');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  Future<PaymentIn> updatePayment(
      int id, Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiClient.put('/payment-ins/$id', paymentData);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentIn.fromJson(data['payment']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update payment');
      }
    } catch (e) {
      throw Exception('Error updating payment: $e');
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      final response = await _apiClient.delete('/payment-ins/$id');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete payment');
      }
    } catch (e) {
      throw Exception('Error deleting payment: $e');
    }
  }

  Future<Map<String, dynamic>> getNextPaymentNumber(int organizationId) async {
    try {
      final response = await _apiClient
          .get('/payment-ins/next-number?organization_id=$organizationId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next payment number');
      }
    } catch (e) {
      throw Exception('Error fetching next payment number: $e');
    }
  }

  Future<List<dynamic>> getBankAccounts(int organizationId) async {
    try {
      final response = await _apiClient
          .get('/bank-accounts?organization_id=$organizationId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['accounts'] as List;
      } else {
        throw Exception('Failed to load bank accounts');
      }
    } catch (e) {
      throw Exception('Error fetching bank accounts: $e');
    }
  }
}
