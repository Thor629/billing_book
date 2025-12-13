import 'api_client.dart';

class PurchaseOrderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getPurchaseOrders(
    int organizationId, {
    String? status,
  }) async {
    final response = await _apiClient.get(
      '/purchase-orders?organization_id=$organizationId${status != null ? '&status=$status' : ''}',
    );
    final data = _apiClient.handleResponse(response);
    return data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createPurchaseOrder({
    required int organizationId,
    required int partyId,
    required String orderDate,
    String? expectedDeliveryDate,
    required List<Map<String, dynamic>> items,
    double discountAmount = 0,
    double additionalCharges = 0,
    bool autoRoundOff = false,
    bool fullyPaid = false,
    int? bankAccountId,
    String? paymentMode,
    double? paymentAmount,
    String? notes,
    String? terms,
  }) async {
    final response = await _apiClient.post('/purchase-orders', {
      'organization_id': organizationId,
      'party_id': partyId,
      'order_date': orderDate,
      'expected_delivery_date': expectedDeliveryDate,
      'items': items,
      'discount_amount': discountAmount,
      'additional_charges': additionalCharges,
      'auto_round_off': autoRoundOff,
      'fully_paid': fullyPaid,
      'bank_account_id': bankAccountId,
      'payment_mode': paymentMode,
      'payment_amount': paymentAmount,
      'notes': notes,
      'terms': terms,
    });
    return _apiClient.handleResponse(response);
  }

  Future<Map<String, dynamic>> getPurchaseOrder(int id) async {
    final response = await _apiClient.get('/purchase-orders/$id');
    final data = _apiClient.handleResponse(response);
    return data['data'];
  }

  Future<Map<String, dynamic>> updatePurchaseOrder({
    required int id,
    required int partyId,
    required String orderDate,
    String? expectedDeliveryDate,
    required List<Map<String, dynamic>> items,
    double discountAmount = 0,
    double additionalCharges = 0,
    bool autoRoundOff = false,
    bool fullyPaid = false,
    int? bankAccountId,
    String? paymentMode,
    double? paymentAmount,
    String? notes,
    String? terms,
  }) async {
    final response = await _apiClient.put('/purchase-orders/$id', {
      'party_id': partyId,
      'order_date': orderDate,
      'expected_delivery_date': expectedDeliveryDate,
      'items': items,
      'discount_amount': discountAmount,
      'additional_charges': additionalCharges,
      'auto_round_off': autoRoundOff,
      'fully_paid': fullyPaid,
      'bank_account_id': bankAccountId,
      'payment_mode': paymentMode,
      'payment_amount': paymentAmount,
      'notes': notes,
      'terms': terms,
    });
    return _apiClient.handleResponse(response);
  }

  Future<void> deletePurchaseOrder(int id) async {
    final response = await _apiClient.delete('/purchase-orders/$id');
    _apiClient.handleResponse(response);
  }

  Future<Map<String, dynamic>> convertToInvoice(int id) async {
    final response =
        await _apiClient.post('/purchase-orders/$id/convert-to-invoice', {});
    return _apiClient.handleResponse(response);
  }
}
