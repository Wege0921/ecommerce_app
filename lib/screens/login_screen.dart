import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';
import '../widgets/pin_entry_screen.dart';
import 'forgot_pin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberForBiometric = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _nextToPin() async {
    String input = usernameController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
      );
      return;
    }

    // Normalize to +251XXXXXXXXX
    // If pasted with +251 or 0, strip to last 9 digits; else assume user typed remaining digits with prefix shown
    input = input.replaceAll(' ', '');
    if (input.startsWith('+251')) {
      input = input.substring(4);
    } else if (input.startsWith('0')) {
      input = input.substring(1);
    }
    final rest = input;
    final restReg = RegExp(r'^(9|7)\d{8}$');
    if (!restReg.hasMatch(rest)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidPhone)),
      );
      return;
    }
    final username = "+251$rest";
    // Navigate to PIN entry (no confirm). On return, attempt login.
    final pin = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PinEntryScreen(requireConfirm: false)),
    );
    if (pin == null) return;
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pinLabel)),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final ok = await _auth.login(username, pin, rememberForBiometric: rememberForBiometric);
      setState(() => isLoading = false);
      if (ok && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccess)));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loginFailed)));
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loginTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
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
                          controller: usernameController,
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPinScreen()),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.forgotPin),
                  ),
                ),
                // PIN is entered on the next screen
                // Localized labels
                const SizedBox(height: 0),
                Row(
                  children: [
                    Checkbox(
                      value: rememberForBiometric,
                      onChanged: (v) => setState(() => rememberForBiometric = v ?? false),
                    ),
                    Expanded(child: Text(AppLocalizations.of(context)!.rememberBiometric)),
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.authenticateToLogin,
                      icon: const Icon(Icons.fingerprint, size: 28),
                      onPressed: () async {
                        try {
                          final canCheck = await _localAuth.isDeviceSupported();
                          if (!canCheck) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.biometricNotSupported)));
                            return;
                          }
                          final auth = await _localAuth.authenticate(
                            localizedReason: AppLocalizations.of(context)!.authenticateToLogin,
                            options: const AuthenticationOptions(biometricOnly: true),
                          );
                          if (!auth) return;
                          final creds = await _auth.getSavedCredentials();
                          if (creds == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.biometricNoSavedCreds)));
                            return;
                          }
                          setState(() => isLoading = true);
                          final ok = await _auth.login(creds['username']!, creds['password']!, rememberForBiometric: true);
                          setState(() => isLoading = false);
                          if (ok && mounted) {
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccess)));
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.biometricLoginFailed)));
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.biometricError('$e'))));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _nextToPin,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      child: Text(AppLocalizations.of(context)!.nextLabel),
                    ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.registerBtn),
                ),
                const SizedBox(height: 20),
                Row(children: const [Expanded(child: Divider()), SizedBox(width: 8), Text('or'), SizedBox(width: 8), Expanded(child: Divider())]),
                const SizedBox(height: 12),
                isLoading
                    ? const SizedBox.shrink()
                    : OutlinedButton.icon(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          final ok = await _auth.loginWithGoogle();
                          setState(() => isLoading = false);
                          if (!mounted) return;
                          if (ok) {
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccess)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
                          }
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
