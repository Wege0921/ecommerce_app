import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class OrderService {
  final String baseUrl = ApiConfig.baseUrl; // http://host:8000/api/
  final _auth = AuthService();

  Future<List<dynamic>> listOrders() async {
    final token = await _auth.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse(baseUrl + 'orders/');
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic> && body.containsKey('results')) {
        return (body['results'] as List<dynamic>);
      }
      if (body is List<dynamic>) return body;
      return [];
    }
    throw Exception('Failed to load orders: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    String status = 'PENDING',
    String? deliveryAddress,
    String? paymentProofUrl,
  }) async {
    final token = await _auth.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse(baseUrl + 'orders/');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
        if (deliveryAddress != null && deliveryAddress.isNotEmpty) 'delivery_address': deliveryAddress,
        if (paymentProofUrl != null && paymentProofUrl.isNotEmpty) 'payment_proof_url': paymentProofUrl,
        'items': items,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // Try to parse a helpful error message
    try {
      final parsed = jsonDecode(res.body);
      if (parsed is Map && parsed.isNotEmpty) {
        return Future.error('Failed to create order: ${res.statusCode} ${parsed.toString()}');
      }
    } catch (_) {}
    throw Exception('Failed to create order: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> uploadPaymentProof({required int orderId, required String filePath}) async {
    final token = await _auth.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse(baseUrl + 'orders/$orderId/upload_proof/');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to upload payment proof: ${res.statusCode} ${res.body}');
  }
}
