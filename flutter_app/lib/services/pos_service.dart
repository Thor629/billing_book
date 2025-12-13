import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_config.dart';
import '../models/item_model.dart';
import 'auth_service.dart';

class PosService {
  final AuthService _authService = AuthService();

  Future<List<ItemModel>> searchItems(int organizationId, String search) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/pos/search-items').replace(
          queryParameters: {
            'organization_id': organizationId.toString(),
            'search': search,
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> itemsJson = data['data'];
        return itemsJson.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search items');
      }
    } catch (e) {
      throw Exception('Error searching items: $e');
    }
  }

  Future<ItemModel> getItemByBarcode(int organizationId, String barcode) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/pos/item-by-barcode').replace(
          queryParameters: {
            'organization_id': organizationId.toString(),
            'barcode': barcode,
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ItemModel.fromJson(data['data']);
      } else {
        throw Exception('Item not found');
      }
    } catch (e) {
      throw Exception('Error getting item by barcode: $e');
    }
  }

  Future<Map<String, dynamic>> saveBill({
    required int organizationId,
    required List<Map<String, dynamic>> items,
    required double discount,
    required double additionalCharge,
    required String paymentMethod,
    required double receivedAmount,
    int? customerId,
    bool isCashSale = true,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/pos/save-bill'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'organization_id': organizationId,
          'items': items,
          'discount': discount,
          'additional_charge': additionalCharge,
          'payment_method': paymentMethod.toLowerCase(),
          'received_amount': receivedAmount,
          'customer_id': customerId,
          'is_cash_sale': isCashSale,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to save bill');
      }
    } catch (e) {
      throw Exception('Error saving bill: $e');
    }
  }
}
