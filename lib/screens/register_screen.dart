import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import '../widgets/pin_entry_screen.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  final _auth = AuthService();

  Future<void> _nextToPin() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
      );
      return;
    }
    phone = phone.replaceAll(' ', '');
    if (phone.startsWith('+251')) {
      phone = phone.substring(4);
    } else if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    final restReg = RegExp(r'^(9|7)\d{8}$');
    if (!restReg.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidPhone)),
      );
      return;
    }
    final normalized = "+251$phone";

    // Ask for PIN with confirmation
    final pin = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PinEntryScreen(requireConfirm: true)),
    );
    if (pin == null || pin.length != 6) return;

    setState(() => isLoading = true);
    try {
      final res = await _auth.registerRaw({
        "username": normalized,
        "phone": normalized,
        "password": pin,
        "password2": pin,
      });
      setState(() => isLoading = false);
      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.registrationSuccess)),
        );
        if (mounted) Navigator.pop(context);
      } else if (res.statusCode == 400) {
        String message = AppLocalizations.of(context)!.registrationFailed;
        try {
          final body = jsonDecode(res.body);
          // Common DRF errors for duplicate username/phone
          if (body is Map) {
            if (body['username'] is List && (body['username'] as List).isNotEmpty) {
              message = AppLocalizations.of(context)!.phoneAlreadyRegistered;
            } else if (body['phone'] is List && (body['phone'] as List).isNotEmpty) {
              message = AppLocalizations.of(context)!.phoneAlreadyRegistered;
            } else if (body['detail'] is String) {
              message = body['detail'];
            }
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.registrationFailed)),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.registerTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.createAccount,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 52,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('+251', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.phoneNumber,
                                hintText: AppLocalizations.of(context)!.phoneHint,
                                border: const OutlineInputBorder(),
                                isDense: true,
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              maxLength: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _nextToPin,
                            child: Text(AppLocalizations.of(context)!.nextLabel),
                          ),
                    const SizedBox(height: 20),
                    Row(children: const [Expanded(child: Divider()), SizedBox(width: 8), Text('or'), SizedBox(width: 8), Expanded(child: Divider())]),
                    const SizedBox(height: 12),
                    isLoading
                        ? const SizedBox.shrink()
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                            onPressed: () async {
                              setState(() => isLoading = true);
                              final ok = await _auth.loginWithGoogle();
                              setState(() => isLoading = false);
                              if (!mounted) return;
                              if (ok) {
                                Navigator.pop(context, true);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.registrationSuccess)));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Continue with Google'),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
