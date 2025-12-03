import 'package:flutter/material.dart';
import '../models/godown_model.dart';
import '../services/godown_service.dart';

class GodownProvider with ChangeNotifier {
  final GodownService _godownService = GodownService();
  List<GodownModel> _godowns = [];
  bool _isLoading = false;
  String? _error;

  List<GodownModel> get godowns => _godowns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGodowns(int organizationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _godowns = await _godownService.getGodowns(organizationId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGodown(Map<String, dynamic> godownData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final godown = await _godownService.createGodown(godownData);
      _godowns.add(godown);
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

  Future<bool> updateGodown(int id, Map<String, dynamic> godownData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedGodown = await _godownService.updateGodown(id, godownData);
      final index = _godowns.indexWhere((g) => g.id == id);
      if (index != -1) _godowns[index] = updatedGodown;
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

  Future<bool> deleteGodown(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _godownService.deleteGodown(id);
      _godowns.removeWhere((g) => g.id == id);
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

  void clearGodowns() {
    _godowns = [];
    _error = null;
    notifyListeners();
  }
}
