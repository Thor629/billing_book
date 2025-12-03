import 'package:flutter/material.dart';
import '../models/user_model.dart';

class MockAuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Mock login - no API call
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic
    if (password == 'password123') {
      if (email == 'admin@example.com') {
        _user = UserModel(
          id: 1,
          name: 'Admin User',
          email: 'admin@example.com',
          role: 'admin',
          status: 'active',
          createdAt: DateTime.now(),
        );
      } else if (email == 'john@example.com') {
        _user = UserModel(
          id: 2,
          name: 'John Doe',
          email: 'john@example.com',
          role: 'user',
          status: 'active',
          createdAt: DateTime.now(),
        );
      } else if (email == 'jane@example.com') {
        _user = UserModel(
          id: 3,
          name: 'Jane Smith',
          email: 'jane@example.com',
          role: 'user',
          status: 'active',
          createdAt: DateTime.now(),
        );
      } else if (email == 'bob@example.com') {
        _user = UserModel(
          id: 4,
          name: 'Bob Johnson',
          email: 'bob@example.com',
          role: 'user',
          status: 'inactive',
          createdAt: DateTime.now(),
        );
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
