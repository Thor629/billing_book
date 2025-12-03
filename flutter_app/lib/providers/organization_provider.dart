import 'package:flutter/material.dart';
import '../models/organization_model.dart';
import '../services/organization_service.dart';

class OrganizationProvider with ChangeNotifier {
  final OrganizationService _organizationService = OrganizationService();

  List<OrganizationModel> _organizations = [];
  OrganizationModel? _selectedOrganization;
  bool _isLoading = false;
  String? _error;

  List<OrganizationModel> get organizations => _organizations;
  OrganizationModel? get selectedOrganization => _selectedOrganization;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrganization => _selectedOrganization != null;

  // Load user's organizations
  Future<void> loadOrganizations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _organizations = await _organizationService.getOrganizations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select an organization
  void selectOrganization(OrganizationModel organization) {
    _selectedOrganization = organization;
    notifyListeners();
  }

  // Create organization
  Future<bool> createOrganization(Map<String, dynamic> orgData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final organization =
          await _organizationService.createOrganization(orgData);
      _organizations.add(organization);
      _selectedOrganization = organization;
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

  // Clear organization (on logout)
  void clearOrganization() {
    _organizations = [];
    _selectedOrganization = null;
    _error = null;
    notifyListeners();
  }
}
