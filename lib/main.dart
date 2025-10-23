import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'state/cart_state.dart';
import 'state/locale_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartState()),
        ChangeNotifierProvider(create: (_) => LocaleState()..load()),
      ],
      child: Consumer<LocaleState>(
        builder: (context, ls, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'E-Commerce App',
            theme: (() {
              const lightBg = Color(0xFFF5F7FA); // soft light gray
              const charcoal = Color(0xFF111827); // dark text
              const teal = Color(0xFF0EA5A4); // highlight
              const emerald = Color(0xFF10B981); // secondary highlight
              final scheme = ColorScheme.fromSeed(
                seedColor: teal,
                brightness: Brightness.light,
              ).copyWith(
                primary: teal,
                onPrimary: Colors.white,
                secondary: emerald,
                onSecondary: Colors.white,
                surface: Colors.white,
                onSurface: charcoal,
                background: lightBg,
                onBackground: charcoal,
              );
              return ThemeData(
                colorScheme: scheme,
                useMaterial3: true,
                scaffoldBackgroundColor: lightBg,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0.5,
                  centerTitle: true,
                ),
                iconTheme: const IconThemeData(color: Colors.black87),
                cardColor: Colors.white,
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.black87),
                  bodyMedium: TextStyle(color: Colors.black87),
                  titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: teal),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: teal, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintStyle: const TextStyle(color: Colors.black38),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              );
            })(),
            locale: ls.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('am'),
              Locale('om'),
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              final target = ls.locale ?? locale ?? const Locale('en');
              if (GlobalMaterialLocalizations.delegate.isSupported(target)) {
                return target;
              }
              // Fallback to English if Material localization not available
              return const Locale('en');
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
