import 'dart:convert';
import '../models/delivery_challan_model.dart';
import 'api_client.dart';

class DeliveryChallanService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDeliveryChallans({
    required int organizationId,
    String? dateFilter,
    String? status,
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
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get('/delivery-challans?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'challans': (data['data'] as List)
              .map((json) => DeliveryChallan.fromJson(json))
              .toList(),
          'pagination': {
            'current_page': data['current_page'],
            'last_page': data['last_page'],
            'total': data['total'],
          },
        };
      } else {
        throw Exception('Failed to load delivery challans');
      }
    } catch (e) {
      throw Exception('Error fetching delivery challans: $e');
    }
  }

  Future<DeliveryChallan> getDeliveryChallan(int id) async {
    try {
      final response = await _apiClient.get('/delivery-challans/$id');

      if (response.statusCode == 200) {
        return DeliveryChallan.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load delivery challan');
      }
    } catch (e) {
      throw Exception('Error fetching delivery challan: $e');
    }
  }

  Future<DeliveryChallan> createDeliveryChallan(
      Map<String, dynamic> challanData) async {
    try {
      print('DEBUG Service: Calling API with data: $challanData');
      final response = await _apiClient.post('/delivery-challans', challanData);

      print('DEBUG Service: Response status: ${response.statusCode}');
      print('DEBUG Service: Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return DeliveryChallan.fromJson(data['challan']);
      } else {
        final error = json.decode(response.body);
        print('DEBUG Service: Error response: $error');
        throw Exception(
            error['message'] ?? 'Failed to create delivery challan');
      }
    } catch (e) {
      print('DEBUG Service: Exception caught: $e');
      throw Exception('Error creating delivery challan: $e');
    }
  }

  Future<void> deleteDeliveryChallan(int id) async {
    try {
      final response = await _apiClient.delete('/delivery-challans/$id');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to delete delivery challan');
      }
    } catch (e) {
      throw Exception('Error deleting delivery challan: $e');
    }
  }

  Future<int> getNextChallanNumber(int organizationId) async {
    try {
      final response = await _apiClient.get(
          '/delivery-challans/next-number?organization_id=$organizationId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['next_number'];
      } else {
        throw Exception('Failed to get next challan number');
      }
    } catch (e) {
      throw Exception('Error fetching next challan number: $e');
    }
  }

  Future<DeliveryChallan> updateStatus(int id, String status) async {
    try {
      final response = await _apiClient.patch(
        '/delivery-challans/$id/status',
        {'status': status},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DeliveryChallan.fromJson(data['challan']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }
}
