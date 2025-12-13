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

  // Load user's organizations and restore previously selected one
  Future<void> loadOrganizations() async {
    if (_isLoading) return; // Prevent duplicate calls

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('OrganizationProvider: Loading organizations...');
      _organizations = await _organizationService.getOrganizations();
      print(
          'OrganizationProvider: Loaded ${_organizations.length} organizations');

      // Try to restore previously selected organization
      final savedOrgId = await _organizationService.getSelectedOrganizationId();
      if (savedOrgId != null) {
        try {
          final savedOrg = _organizations.firstWhere(
            (org) => org.id == savedOrgId,
          );
          _selectedOrganization = savedOrg;
          print(
              'OrganizationProvider: Restored organization: ${savedOrg.name}');
        } catch (e) {
          print('OrganizationProvider: Could not restore saved organization');
        }
      }

      _isLoading = false;
      notifyListeners();
      print('OrganizationProvider: Loading complete');
    } catch (e) {
      print('OrganizationProvider: Error loading organizations: $e');

      // Check if it's an authentication error
      if (e.toString().contains('Unauthorized')) {
        _error = 'Session expired. Please login again.';
        print(
            'OrganizationProvider: Authentication error detected - user needs to re-login');
      } else {
        _error = e.toString().replaceAll('Exception: ', '');
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  // Select an organization and persist the selection
  Future<void> selectOrganization(OrganizationModel organization) async {
    _selectedOrganization = organization;
    await _organizationService.saveSelectedOrganizationId(organization.id);
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
      await _organizationService.saveSelectedOrganizationId(organization.id);
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
  Future<void> clearOrganization() async {
    _organizations = [];
    _selectedOrganization = null;
    _error = null;
    await _organizationService.clearSelectedOrganization();
    notifyListeners();
  }
}
