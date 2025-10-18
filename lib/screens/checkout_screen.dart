import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _placing = false;
  File? _paymentProof;
  String _paymentMethod = 'BANK_TRANSFER'; // or 'COD'

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  Future<void> _prefillFromProfile() async {
    final me = await AuthService().getUser();
    if (me != null) {
      final first = (me['first_name'] ?? '').toString();
      final last = (me['last_name'] ?? '').toString();
      final phone = (me['phone'] ?? me['username'] ?? '').toString();
      _nameCtrl.text = [first, last].where((e) => e.isNotEmpty).join(' ').trim();
      _phoneCtrl.text = phone;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shipping Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          keyboardType: TextInputType.phone,
                        ),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(labelText: 'Delivery Address'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          minLines: 2,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Payment Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Please pay half of the total to one of the accounts below and upload a screenshot of your payment.'),
                        SizedBox(height: 8),
                        Text('CBE: 1000023454545'),
                        Text('Tele birr: 0940706072'),
                        Text('Abyssinia Bank: 45673400'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'BANK_TRANSFER',
                            groupValue: _paymentMethod,
                            onChanged: (v) => setState(() => _paymentMethod = v!),
                          ),
                          const Text('Bank Transfer (upload screenshot)'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'COD',
                            groupValue: _paymentMethod,
                            onChanged: (v) => setState(() => _paymentMethod = v!),
                          ),
                          const Text('Cash on delivery'),
                        ],
                      ),
                      if (_paymentMethod == 'BANK_TRANSFER')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                                  if (picked != null) {
                                    setState(() => _paymentProof = File(picked.path));
                                  }
                                },
                                icon: const Icon(Icons.attach_file),
                                label: Text(_paymentProof == null ? 'Upload Payment Screenshot' : 'Change Screenshot'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...cart.items.map((it) => ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        title: Text(it.product['title'] ?? ''),
                        trailing: Text('${it.quantity} x \$${it.unitPrice}'),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('\$${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: _placing ? const Text('Placing...') : const Text('Place Order'),
                      onPressed: _placing
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              // Validate payment method requirements
                              if (_paymentMethod == 'BANK_TRANSFER' && _paymentProof == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please upload the payment screenshot.')),
                                );
                                return;
                              }

                              // Require login
                              final token = await AuthService().getAccessToken();
                              if (token == null) {
                                final loggedIn = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                                if (loggedIn != true) return;
                              }

                              setState(() => _placing = true);
                              try {
                                final items = cart.items
                                    .map((it) => {
                                          'product_id': it.productId,
                                          'quantity': it.quantity,
                                        })
                                    .toList();
                                final order = await OrderService().createOrder(
                                  items: items,
                                  deliveryAddress: _addressCtrl.text.trim(),
                                );
                                // Upload payment proof if applicable
                                if (_paymentMethod == 'BANK_TRANSFER' && _paymentProof != null) {
                                  final orderId = (order['id'] as num).toInt();
                                  await OrderService().uploadPaymentProof(orderId: orderId, filePath: _paymentProof!.path);
                                }
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Order placed successfully')),
                                );
                                cart.clear();
                                Navigator.pop(context);
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to place order: $e')),
                                );
                              } finally {
                                if (mounted) setState(() => _placing = false);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
