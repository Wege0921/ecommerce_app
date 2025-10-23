import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/format.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.checkoutTitle)),
      body: cart.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.cartEmpty))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.shippingDetails, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phoneNumber),
                          validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.requiredField : null,
                          keyboardType: TextInputType.phone,
                        ),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.deliveryAddress),
                          validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.requiredField : null,
                          minLines: 1,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.paymentInstructions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.paymentInstructionLine),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.telebirr),
              
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'BANK_TRANSFER',
                            groupValue: _paymentMethod,
                            onChanged: (v) => setState(() => _paymentMethod = v!),
                          ),
                          Text(AppLocalizations.of(context)!.bankTransfer),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'COD',
                            groupValue: _paymentMethod,
                            onChanged: (v) => setState(() => _paymentMethod = v!),
                          ),
                          Text(AppLocalizations.of(context)!.cashOnDelivery),
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
                                label: Text(_paymentProof == null
                                    ? AppLocalizations.of(context)!.uploadPaymentScreenshot
                                    : AppLocalizations.of(context)!.changeScreenshot),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.orderSummary, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...cart.items.map((it) => ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        title: Text(it.product['title'] ?? ''),
                        trailing: Text(
                          '${it.quantity} x ' + Format.price(context, it.unitPrice),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.subtotal, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        Format.price(context, cart.subtotal),
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: _placing
                          ? Text(AppLocalizations.of(context)!.placing)
                          : Text(AppLocalizations.of(context)!.placeOrder),
                      onPressed: _placing
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              // Validate payment method requirements
                              if (_paymentMethod == 'BANK_TRANSFER' && _paymentProof == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.uploadProofRequired)),
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
                                  SnackBar(content: Text(AppLocalizations.of(context)!.orderPlaced)),
                                );
                                cart.clear();
                                Navigator.pop(context);
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.orderFailed('$e'))),
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
