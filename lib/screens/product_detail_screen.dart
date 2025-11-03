import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/order_service.dart';
import '../utils/format.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'image_viewer_screen.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  int _imageIndex = 0;
  final PageController _pageCtrl = PageController();

  String _thumbOf(dynamic e) {
    if (e is Map && e['thumb'] is String) return e['thumb'] as String;
    if (e is String) return e;
    return '';
  }

  String _fullOf(dynamic e) {
    if (e is Map && e['full'] is String) return e['full'] as String;
    if (e is String) return e;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> product = widget.product;
    final List<dynamic> imgs = (product['images'] as List?) ?? const [];
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
                child: (imgs.isNotEmpty)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final urls = imgs.map((e) => _fullOf(e)).where((e) => e.isNotEmpty).toList();
                              if (urls.isEmpty) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageViewerScreen(images: urls, initialIndex: _imageIndex),
                                ),
                              );
                            },
                            child: PageView.builder(
                              controller: _pageCtrl,
                              itemCount: imgs.length,
                              onPageChanged: (i) => setState(() => _imageIndex = i),
                              itemBuilder: (context, index) {
                                final url = _fullOf(imgs[index]);
                                final dpr = MediaQuery.of(context).devicePixelRatio;
                                return CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  memCacheWidth: (1200 * dpr).round(),
                                );
                              },
                            ),
                          ),
                          if (imgs.length > 1)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(imgs.length, (i) {
                                  final active = i == _imageIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: active ? 10 : 6,
                                    height: active ? 10 : 6,
                                    decoration: BoxDecoration(
                                      color: active ? Colors.white : Colors.white70,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      )
                    : imageUrl.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageViewerScreen(images: [imageUrl], initialIndex: 0),
                                ),
                              );
                            },
                            child: Builder(builder: (context) {
                              final dpr = MediaQuery.of(context).devicePixelRatio;
                              return CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: (1200 * dpr).round(),
                              );
                            }),
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
