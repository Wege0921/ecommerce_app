import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import 'login_screen.dart';
import 'checkout_screen.dart';
import '../utils/format.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _orders = OrderService();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    return Column(
      children: [
        Expanded(
          child: cart.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.cartEmpty, style: const TextStyle(color: Colors.black87)))
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final product = item.product;
                    final imageUrl = (product['image_url'] ?? '') as String;
                    final stock = product['stock'] is int ? product['stock'] as int : null;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: SizedBox(
                          width: 56,
                          height: 56,
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : const Icon(Icons.image_outlined, color: Colors.grey),
                        ),
                        title: Text(
                          product['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        subtitle: Text(
                          Format.price(context, Format.toNum(product['price'])),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        trailing: SizedBox(
                          width: 156,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.black87),
                                onPressed: () => cart.decrement(item.productId),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
                                onPressed: () => cart.increment(item.productId, stock: stock),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                icon: const Icon(Icons.delete_outline, color: Colors.black87),
                                onPressed: () => cart.remove(item.productId),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context)!.total, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(
                        Format.price(context, cart.subtotal),
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: cart.isEmpty
                        ? null
                        : () async {
                            final token = await AuthService().getAccessToken();
                            if (token == null) {
                              final loggedIn = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                              if (loggedIn != true) return;
                            }
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                    child: Text(AppLocalizations.of(context)!.checkoutTitle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
