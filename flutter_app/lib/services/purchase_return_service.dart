import '../models/purchase_return_model.dart';
import 'api_client.dart';

class PurchaseReturnService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PurchaseReturn>> getPurchaseReturns(int organizationId) async {
    final response = await _apiClient.get(
      '/purchase-returns',
      customHeaders: {'X-Organization-Id': organizationId.toString()},
    );
    final data = _apiClient.handleResponse(response);

    final returns = (data['data'] as List)
        .map((json) => PurchaseReturn.fromJson(json))
        .toList();
    return returns;
  }

  Future<PurchaseReturn> createPurchaseReturn(
    int organizationId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post(
      '/purchase-returns',
      data,
      customHeaders: {'X-Organization-Id': organizationId.toString()},
    );
    final responseData = _apiClient.handleResponse(response);
    return PurchaseReturn.fromJson(responseData);
  }

  Future<String> getNextReturnNumber(int organizationId) async {
    final response = await _apiClient.get(
      '/purchase-returns/next-number',
      customHeaders: {'X-Organization-Id': organizationId.toString()},
    );
    final data = _apiClient.handleResponse(response);
    return data['next_number'];
  }

  Future<void> deletePurchaseReturn(int organizationId, int id) async {
    final response = await _apiClient.delete(
      '/purchase-returns/$id',
      customHeaders: {'X-Organization-Id': organizationId.toString()},
    );
    _apiClient.handleResponse(response);
  }
}
