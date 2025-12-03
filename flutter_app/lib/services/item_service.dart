import '../models/item_model.dart';
import 'api_client.dart';

class ItemService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ItemModel>> getItems(int organizationId) async {
    final response =
        await _apiClient.get('/items?organization_id=$organizationId');
    final data = _apiClient.handleResponse(response);
    final List<dynamic> itemsJson = data['data'];
    return itemsJson.map((json) => ItemModel.fromJson(json)).toList();
  }

  Future<ItemModel> createItem(Map<String, dynamic> itemData) async {
    final response = await _apiClient.post('/items', itemData);
    final data = _apiClient.handleResponse(response);
    return ItemModel.fromJson(data['item']);
  }

  Future<ItemModel> getItem(int id) async {
    final response = await _apiClient.get('/items/$id');
    final data = _apiClient.handleResponse(response);
    return ItemModel.fromJson(data['item']);
  }

  Future<ItemModel> updateItem(int id, Map<String, dynamic> itemData) async {
    final response = await _apiClient.put('/items/$id', itemData);
    final data = _apiClient.handleResponse(response);
    return ItemModel.fromJson(data['item']);
  }

  Future<void> deleteItem(int id) async {
    final response = await _apiClient.delete('/items/$id');
    _apiClient.handleResponse(response);
  }
}
