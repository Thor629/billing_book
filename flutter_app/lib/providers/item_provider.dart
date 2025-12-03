import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemProvider with ChangeNotifier {
  final ItemService _itemService = ItemService();
  List<ItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get lowStockCount => _items.where((item) => item.isLowStock).length;

  Future<void> loadItems(int organizationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _itemService.getItems(organizationId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createItem(Map<String, dynamic> itemData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final item = await _itemService.createItem(itemData);
      _items.add(item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(int id, Map<String, dynamic> itemData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedItem = await _itemService.updateItem(id, itemData);
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) _items[index] = updatedItem;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _itemService.deleteItem(id);
      _items.removeWhere((i) => i.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearItems() {
    _items = [];
    _error = null;
    notifyListeners();
  }
}
