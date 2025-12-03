import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../services/party_service.dart';

class PartyProvider with ChangeNotifier {
  final PartyService _partyService = PartyService();

  List<PartyModel> _parties = [];
  bool _isLoading = false;
  String? _error;

  List<PartyModel> get parties => _parties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load parties for an organization
  Future<void> loadParties(int organizationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _parties = await _partyService.getParties(organizationId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create party
  Future<bool> createParty(Map<String, dynamic> partyData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final party = await _partyService.createParty(partyData);
      _parties.add(party);
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

  // Update party
  Future<bool> updateParty(int id, Map<String, dynamic> partyData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedParty = await _partyService.updateParty(id, partyData);
      final index = _parties.indexWhere((p) => p.id == id);
      if (index != -1) {
        _parties[index] = updatedParty;
      }
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

  // Delete party
  Future<bool> deleteParty(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _partyService.deleteParty(id);
      _parties.removeWhere((p) => p.id == id);
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

  // Clear parties (on logout or organization change)
  void clearParties() {
    _parties = [];
    _error = null;
    notifyListeners();
  }
}
