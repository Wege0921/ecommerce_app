import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/locale_headers.dart';

class CategoryService {
  final String baseUrl = ApiConfig.baseUrl; // http://host:8000/api/

  Future<List<dynamic>> listCategories({int? page, int? pageSize, int? parent}) async {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (pageSize != null) params['page_size'] = pageSize.toString();
    if (parent != null) params['parent'] = parent.toString();

    final uri = Uri.parse(baseUrl + 'categories/').replace(queryParameters: params);
    final lang = await LocaleHeaders.acceptLanguageHeader();
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...lang,
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map && data.containsKey('results')) return (data['results'] as List);
      if (data is List) return data as List;
      return [];
    }
    throw Exception('Failed to load categories: ${res.statusCode}');
  }
}
