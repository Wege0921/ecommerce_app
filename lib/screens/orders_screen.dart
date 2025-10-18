import 'package:flutter/material.dart';
import '../services/order_service.dart';

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
                      final created = (o['created_at'] ?? '').toString();
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
