import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import '../state/locale_state.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final AuthService _authService = AuthService();

  // Screens should return only the body (no Scaffold)
  final List<Widget> _screens = const [
    HomeScreen(),       // just the body
    CategoriesScreen(), // just the body
    CartScreen(),       // just the body
    ProfileScreen(),    // just the body
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _onTabTapped(int index) async {
    // Only require auth for Profile tab. Cart can be viewed without auth; checkout enforces login.
    if (index == 3) {
      final token = await _authService.getAccessToken();
      if (token == null) {
        final loggedIn = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        if (loggedIn != true) return;
      }
    }

    if (mounted) setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text([
          t.home,
          t.categories,
          t.cart,
          t.profile,
        ][_currentIndex]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (code) {
              context.read<LocaleState>().setLocale(Locale(code));
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'am', child: Text('አማርኛ')),
              PopupMenuItem(value: 'om', child: Text('Afaan Oromo')),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex], // directly show the active body
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
          BottomNavigationBarItem(icon: const Icon(Icons.category), label: t.categories),
          BottomNavigationBarItem(
            icon: Consumer<CartState>(
              builder: (_, cart, __) {
                final count = cart.totalItems;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (count > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                          constraints: const BoxConstraints(minWidth: 18),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: t.cart,
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: t.profile),
        ],
      ),
    );
  }
}
