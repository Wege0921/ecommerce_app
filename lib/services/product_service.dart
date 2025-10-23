import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/locale_headers.dart';

class ProductService {
  final String baseUrl = ApiConfig.baseUrl; // e.g., http://host:8000/api/

  Future<Map<String, dynamic>> listProducts({
    int? categoryId,
    String? type,
    num? priceMin,
    num? priceMax,
    bool? inStock,
    bool? isFeatured,
    String? ordering,
    String? search,
    int? page,
    int? pageSize,
    bool? descendants,
  }) async {
    final params = <String, String>{};
    if (categoryId != null) params['category'] = categoryId.toString();
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (priceMin != null) params['price_min'] = priceMin.toString();
    if (priceMax != null) params['price_max'] = priceMax.toString();
    if (inStock != null) params['in_stock'] = inStock.toString();
    if (isFeatured != null) params['is_featured'] = isFeatured.toString();
    if (ordering != null) params['ordering'] = ordering;
    if (search != null) params['search'] = search;
    if (page != null) params['page'] = page.toString();
    if (pageSize != null) params['page_size'] = pageSize.toString();
    if (descendants == true) params['descendants'] = 'true';

    final uri = Uri.parse(baseUrl + 'products/').replace(queryParameters: params);
    final lang = await LocaleHeaders.acceptLanguageHeader();
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...lang,
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load products: ${res.statusCode}');
  }
}
