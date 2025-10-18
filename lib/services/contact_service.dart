import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ContactService {
  final String baseUrl = ApiConfig.baseUrl; // http://host:8000/api/

  Future<void> sendMessage({
    required String name,
    String? phone,
    String? email,
    required String subject,
    required String message,
  }) async {
    final uri = Uri.parse(baseUrl + 'contact/');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        'subject': subject,
        'message': message,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to send message: ${res.statusCode} ${res.body}');
    }
  }
}
