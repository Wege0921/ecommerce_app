import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/format.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orders = OrderService();
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final data = await _orders.listOrders();
      setState(() {
        orders = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'DELIVERED':
        return Colors.blue;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders yet'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final o = orders[index];
                      final items = (o['items'] as List? ?? const []);
                      final status = (o['status'] ?? 'PENDING').toString();
                      final createdRaw = (o['created_at'] ?? '').toString();
                      DateTime? createdDt;
                      try {
                        createdDt = DateTime.tryParse(createdRaw);
                      } catch (_) {}
                      final created = createdDt != null ? Format.dateShort(context, createdDt) : createdRaw;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Order #${o['id']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Chip(
                                    label: Text(status),
                                    backgroundColor: _statusColor(status).withOpacity(0.15),
                                    labelStyle: TextStyle(color: _statusColor(status)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if ((o['payment_proof_url'] ?? '').toString().isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(order: o),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: o['payment_proof_url'],
                                      height: 80,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if ((o['payment_proof_url'] ?? '').toString().isNotEmpty)
                                const SizedBox(height: 8),
                              ...items.take(3).map((it) {
                                final p = (it['product'] ?? {}) as Map<String, dynamic>;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p['title']?.toString() ?? 'Product',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text('x${it['quantity']}'),
                                  ],
                                );
                              }).cast<Widget>(),
                              if (items.length > 3)
                                Text('+${items.length - 3} more items', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text(created, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(order: o),
                                      ),
                                    );
                                  },
                                  child: const Text('View Details'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
