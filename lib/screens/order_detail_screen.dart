import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/format.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'DELIVERED':
        return Colors.blue;
      case 'PAID':
        return Colors.teal;
      case 'SHIPPED':
        return Colors.indigo;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = (order['items'] as List? ?? const []);
    final status = (order['status'] ?? 'PENDING').toString();
    final createdRaw = (order['created_at'] ?? '').toString();
    DateTime? createdDt;
    try {
      createdDt = DateTime.tryParse(createdRaw);
    } catch (_) {}
    final created = createdDt != null ? Format.dateShort(context, createdDt) : createdRaw;
    final address = (order['delivery_address'] ?? '').toString();
    final proof = (order['payment_proof_url'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order['id']}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status: $status', style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w600)),
                Text(created, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            if (address.isNotEmpty) ...[
              const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(address),
              const SizedBox(height: 12),
            ],
            const Text('Items', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...items.map((it) {
              final p = (it['product'] ?? {}) as Map<String, dynamic>;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(p['title']?.toString() ?? 'Product'),
                trailing: Text('x${it['quantity']}'),
              );
            }).cast<Widget>(),
            const SizedBox(height: 16),
            const Text('Payment Proof', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            if (proof.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: proof,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Text('No proof uploaded'),
          ],
        ),
      ),
    );
  }
}
