import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import '../config/app_config.dart';

class Format {
  static num toNum(dynamic v) {
    if (v is num) return v;
    if (v is String) {
      final parsed = num.tryParse(v);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static String price(BuildContext context, num value, {String? currency}) {
    final symbol = currency ?? AppConfig.currencySymbol;
    try {
      final locale = Localizations.localeOf(context).toLanguageTag();
      final f = NumberFormat.currency(locale: locale, name: symbol, symbol: symbol, decimalDigits: 2);
      return f.format(value);
    } catch (_) {
      try {
        final f = NumberFormat.currency(locale: 'en', name: symbol, symbol: symbol, decimalDigits: 2);
        return f.format(value);
      } catch (_) {
        return '$symbol $value';
      }
    }
  }

  static String dateShort(BuildContext context, DateTime dt) {
    try {
      final locale = Localizations.localeOf(context).toLanguageTag();
      return DateFormat.yMMMd(locale).add_jm().format(dt);
    } catch (_) {
      try {
        return DateFormat.yMMMd('en').add_jm().format(dt);
      } catch (_) {
        return dt.toIso8601String();
      }
    }
  }
}
