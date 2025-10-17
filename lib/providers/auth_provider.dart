import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      await fetchUser();
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> fetchUser() async {
    final data = await _authService.getUser();
    if (data != null) {
      _user = User.fromJson(data);
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    await _authService.register(data);
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
