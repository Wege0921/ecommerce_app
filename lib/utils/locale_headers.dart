import 'package:shared_preferences/shared_preferences.dart';

class LocaleHeaders {
  static const _key = 'app_locale_code';

  static Future<Map<String, String>> acceptLanguageHeader() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key) ?? 'en';
      // Whitelist server-supported languages. Fallback to 'en' if not supported.
      const supported = {'en', 'am', 'om'};
      final headerCode = supported.contains(code) ? code : 'en';
      return {'Accept-Language': headerCode};
    } catch (_) {
      return {'Accept-Language': 'en'};
    }
  }
}
