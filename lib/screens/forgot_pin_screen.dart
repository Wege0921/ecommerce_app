import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';
import '../widgets/pin_entry_screen.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _auth = AuthService();

  Future<void> _continue() async {
    final t = AppLocalizations.of(context)!;
    String phone = phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.fillAllFields)));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.invalidPhone)));
      return;
    }

    // Biometric authenticate before allowing reset
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.biometricNotSupported)));
        return;
      }
      final ok = await _localAuth.authenticate(
        localizedReason: t.authenticateToLogin,
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!ok) return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.biometricError('$e'))));
      return;
    }

    // Ask for new PIN (confirm)
    final pin = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PinEntryScreen(requireConfirm: true)),
    );
    if (pin == null || pin.length != 6) return;
    setState(() => isLoading = true);
    final normalized = "+251$phone";
    final ok = await _auth.resetPin(phone: normalized, newPin: pin);
    setState(() => isLoading = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.forgotPinSuccess)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.forgotPinFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.forgotPinTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        t.forgotPinSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
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
                                labelText: t.phoneNumber,
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
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _continue,
                            child: Text(t.continueLabel),
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
