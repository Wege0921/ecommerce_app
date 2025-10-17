import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final token = await AuthService().getAccessToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        isLoggedIn = false;
      });
      return;
    }

    final url = Uri.parse("http://192.168.8.143:8000/api/auth/me/");
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      setState(() {
        user = jsonDecode(response.body);
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
    setState(() {
      user = null;
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Center(
        child: Text("Please login to view your profile"),
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
          ElevatedButton(
            onPressed: logout,
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
