import 'dart:convert';
import '../models/payment_out_model.dart';
import 'api_client.dart';

class PaymentOutService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getPaymentOuts({
    required String organizationId,
    String? dateFilter,
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
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '/payment-outs?$queryString',
        customHeaders: {'X-Organization-Id': organizationId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<PaymentOut> payments = [];
        if (data['data'] != null) {
          payments = (data['data'] as List)
              .map((json) => PaymentOut.fromJson(json))
              .toList();
        }

        return {
          'payments': payments,
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'total': data['total'] ?? 0,
          },
        };
      } else {
        throw Exception('Failed to load payment outs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching payment outs: $e');
    }
  }

  Future<PaymentOut> createPaymentOut(Map<String, dynamic> paymentData) async {
    try {
      final organizationId = paymentData['organization_id'].toString();

      print('💾 Creating payment out with data: $paymentData');

      final response = await _apiClient.post(
        '/payment-outs',
        paymentData,
        customHeaders: {'X-Organization-Id': organizationId},
      );

      print('📡 Create payment response status: ${response.statusCode}');
      print('📡 Create payment response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentOut.fromJson(data);
      } else {
        final error = json.decode(response.body);

        // Extract validation errors if present
        if (error['errors'] != null) {
          final errors = error['errors'] as Map<String, dynamic>;
          final errorMessages = errors.entries
              .map((e) =>
                  '${e.key}: ${e.value is List ? (e.value as List).join(', ') : e.value}')
              .join('\n');
          throw Exception('Validation failed:\n$errorMessages');
        }

        throw Exception(error['message'] ?? 'Failed to create payment out');
      }
    } catch (e) {
      print('❌ Error creating payment out: $e');
      throw Exception('Error creating payment out: $e');
    }
  }

  Future<String> getNextPaymentNumber(String organizationId) async {
    try {
      print('🔍 Fetching next payment number for org: $organizationId');

      final response = await _apiClient.get(
        '/payment-outs/next-number',
        customHeaders: {'X-Organization-Id': organizationId},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nextNumber = data['next_number'];
        print('✅ Next payment number from API: $nextNumber');
        return nextNumber;
      } else {
        throw Exception('Failed to get next payment number');
      }
    } catch (e) {
      print('❌ Error fetching next payment number: $e');
      throw Exception('Error fetching next payment number: $e');
    }
  }

  Future<PaymentOut> updatePaymentOut(
      int id, Map<String, dynamic> paymentData) async {
    try {
      final organizationId = paymentData['organization_id'].toString();

      print('💾 Updating payment out $id with data: $paymentData');

      final response = await _apiClient.put(
        '/payment-outs/$id',
        paymentData,
        customHeaders: {'X-Organization-Id': organizationId},
      );

      print('📡 Update payment response status: ${response.statusCode}');
      print('📡 Update payment response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentOut.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update payment out');
      }
    } catch (e) {
      print('❌ Error updating payment out: $e');
      throw Exception('Error updating payment out: $e');
    }
  }

  Future<void> deletePaymentOut(int id, String organizationId) async {
    try {
      final response = await _apiClient.delete(
        '/payment-outs/$id',
        customHeaders: {'X-Organization-Id': organizationId},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete payment out');
      }
    } catch (e) {
      throw Exception('Error deleting payment out: $e');
    }
  }
}
