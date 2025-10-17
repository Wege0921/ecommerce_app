import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.8.143:8000/api/auth/";

  /// 🔑 Save tokens locally
  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  /// 🧾 Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// 🧾 Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// ✅ Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 🧍 Register a new user
  Future<bool> register(Map<String, dynamic> data) async {
    final url = Uri.parse("${baseUrl}register/");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.statusCode == 201;
  }

  /// 🔐 Login user and store tokens
  Future<bool> login(String username, String password) async {
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
