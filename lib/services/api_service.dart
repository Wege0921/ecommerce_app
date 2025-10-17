import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://192.168.8.143:8000/api/auth/"; // change to your backend URL
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: "access_token");
  }

  Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    return http.get(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data,
      {bool auth = false}) async {
    final token = await getToken();
    return http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Content-Type": "application/json",
        if (auth && token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
  }
}
