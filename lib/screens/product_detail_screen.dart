import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/order_service.dart';
import '../utils/format.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> product = widget.product;
    final imageUrl = (product['image_url'] ?? '') as String;
    final stock = product['stock'] is int ? product['stock'] as int : null;
    return Scaffold(
      appBar: AppBar(title: Text(product['title'] ?? 'Product')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Container(
                color: Colors.grey.shade100,
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_outlined, size: 64, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Category: ${product['category']?['name'] ?? ''}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)!.price}: ' + Format.price(context, Format.toNum(product['price'])),
                    style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary),
                  ),
                  if (stock != null) ...[
                    const SizedBox(height: 8),
                    Text('In stock: $stock'),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.quantity + ':'),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            quantity = (quantity - 1).clamp(1, stock ?? 9999);
                          });
                        },
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            quantity = (quantity + 1).clamp(1, stock ?? 9999);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text(AppLocalizations.of(context)!.addToCart),
                          onPressed: () {
                            final cart = context.read<CartState>();
                            cart.add(product, quantity: quantity, stock: stock);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.addToCart)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: Text(AppLocalizations.of(context)!.buyNow),
                          onPressed: () async {
                            final token = await AuthService().getAccessToken();
                            if (token == null) {
                              final loggedIn = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                              if (loggedIn != true) return;
                            }
                            final cart = context.read<CartState>();
                            cart.add(product, quantity: quantity, stock: stock);
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product['description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
