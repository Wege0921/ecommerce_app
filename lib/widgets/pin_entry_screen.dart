import 'package:flutter/material.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';

class PinEntryScreen extends StatefulWidget {
  final bool requireConfirm; // if true, ask twice and confirm match
  final int length; // pin length
  final String? title;
  const PinEntryScreen({super.key, this.requireConfirm = false, this.length = 6, this.title});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = '';
  String _confirm = '';
  bool _confirming = false;

  void _onDigit(String d) {
    setState(() {
      if (!_confirming) {
        if (_pin.length < widget.length) _pin += d;
        if (_pin.length == widget.length) {
          if (widget.requireConfirm) {
            _confirming = true;
          } else {
            // Auto-submit for login
            Navigator.pop(context, _pin);
          }
        }
      } else {
        if (_confirm.length < widget.length) _confirm += d;
        if (_confirm.length == widget.length) {
          if (_pin == _confirm) {
            Navigator.pop(context, _pin);
          } else {
            final t = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pinMismatch)));
            _confirm = '';
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_confirming) {
        if (_confirm.isNotEmpty) {
          _confirm = _confirm.substring(0, _confirm.length - 1);
        } else {
          _confirming = false;
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  void _onClear() {
    setState(() {
      _pin = '';
      _confirm = '';
      _confirming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final length = widget.length;
    final showing = _confirming ? _confirm : _pin;
    final done = !widget.requireConfirm
        ? _pin.length == length
        : _confirming && _confirm.length == length && _pin == _confirm;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? (_confirming ? t.confirmPinTitle : t.enterPinTitle))),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              widget.requireConfirm
                  ? (_confirming ? t.confirmPinSubtitle : t.enterPinSubtitle)
                  : t.enterPinSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(length, (i) {
              final filled = i < showing.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final d in ['1','2','3','4','5','6','7','8','9']) _numKey(d),
                _actionKey(t.clearLabel, _onClear),
                _numKey('0'),
                _actionKey(t.deleteLabel, _onBackspace),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _numKey(String d) => ElevatedButton(
        onPressed: () => _onDigit(d),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(0, 56),
        ),
        child: Text(d, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      );

  Widget _actionKey(String label, VoidCallback onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(0, 56),
        ),
        child: Text(label),
      );
}
