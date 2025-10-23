import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.auth;
  final storage = const FlutterSecureStorage();

  /// 🔑 Save tokens locally
  Future<void> _saveTokens(String access, String refresh) async {
    await storage.write(key: 'access_token', value: access);
    await storage.write(key: 'refresh_token', value: refresh);
  }

  /// 📱 Optionally save credentials for biometric login (secure storage)
  Future<void> saveCredentials(String username, String password) async {
    await storage.write(key: 'saved_username', value: username);
    await storage.write(key: 'saved_password', value: password);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final u = await storage.read(key: 'saved_username');
    final p = await storage.read(key: 'saved_password');
    if (u != null && p != null && u.isNotEmpty && p.isNotEmpty) {
      return {"username": u, "password": p};
    }
    return null;
  }

  Future<void> clearSavedCredentials() async {
    await storage.delete(key: 'saved_username');
    await storage.delete(key: 'saved_password');
  }

  /// 🧾 Get access token
  Future<String?> getAccessToken() async {
    return storage.read(key: 'access_token');
  }

  /// 🧾 Get refresh token
  Future<String?> getRefreshToken() async {
    return storage.read(key: 'refresh_token');
  }

  /// ✅ Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 🧍 Register a new user
  Future<http.Response> registerRaw(Map<String, dynamic> data) async {
    final url = Uri.parse("${baseUrl}register/");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return res;
  }

  /// Back-compat: boolean result
  Future<bool> register(Map<String, dynamic> data) async {
    final res = await registerRaw(data);
    return res.statusCode == 201;
  }

  /// 🔐 Login user and store tokens
  Future<bool> login(String username, String password, {bool rememberForBiometric = false}) async {
    final url = Uri.parse("${baseUrl}token/");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      await _saveTokens(body["access"], body["refresh"]);
      if (rememberForBiometric) {
        await saveCredentials(username, password);
      }
      return true;
    }

    return false;
  }

  /// 👤 Get current user profile
  Future<Map<String, dynamic>?> getUser() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final url = Uri.parse("${baseUrl}me/");
    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  /// 🚪 Logout user
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await clearSavedCredentials();
  }

  /// 🔁 Reset PIN (server endpoint should verify identity via biometric/OTP server-side)
  Future<bool> resetPin({required String phone, required String newPin}) async {
    final url = Uri.parse("${baseUrl}reset-pin/");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "new_pin": newPin,
      }),
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }
}
