import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'orders_screen.dart';
import 'contact_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isLoggedIn = true;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final token = await _auth.getAccessToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        isLoggedIn = false;
      });
      return;
    }

    final me = await _auth.getUser();
    if (me != null) {
      setState(() {
        user = me;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        isLoggedIn = false;
      });
    }
  }

  Future<void> logout() async {
    await AuthService().logout();
    if (mounted) {
      context.read<CartState>().clear();
    }
    setState(() {
      user = null;
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please login to view your profile", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final loggedIn = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                    if (loggedIn == true) {
                      // refresh profile
                      setState(() {
                        isLoading = true;
                        isLoggedIn = true;
                      });
                      await fetchProfile();
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Username: ${user?['username']}", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text("Email: ${user?['email']}", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrdersScreen()),
                );
              },
              child: const Text('My Orders'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
              child: const Text('Contact Us'),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: logout,
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
