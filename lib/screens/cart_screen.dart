import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartItems = [];
  bool isLoading = true;
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final token = await AuthService().getAccessToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        isLoggedIn = false;
      });
      return;
    }

    final url = Uri.parse("http://192.168.8.143:8000/api/orders/");
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cartItems = data.isNotEmpty ? data[0]['items'] : [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Center(
        child: Text("Please login to view your cart"),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartItems.isEmpty) {
      return const Center(child: Text("Your cart is empty"));
    }

    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return ListTile(
          title: Text(item['product']['title']),
          subtitle: Text("${item['quantity']} x \$${item['product']['price']}"),
        );
      },
    );
  }
}
