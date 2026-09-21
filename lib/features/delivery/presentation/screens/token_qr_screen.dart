import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';

/// Shows a one-time delivery-loop token as a scannable QR — the merchant's
/// pickup QR (handed to the driver in person) and the driver's delivery QR
/// (handed to the customer) both render through this same screen. The token
/// is encoded bare, matching TokenScanScreen's own bare-token reading.
///
/// When [onReset] is given (the merchant's pickup code), a "Reset code"
/// button sits right under the QR: after a confirmation it swaps in the
/// fresh code [onReset] returns, and the old one stops working.
class TokenQrScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String token;
  final Future<String> Function()? onReset;

  const TokenQrScreen({super.key, required this.title, required this.subtitle, required this.token, this.onReset});

  @override
  State<TokenQrScreen> createState() => _TokenQrScreenState();
}

class _TokenQrScreenState extends State<TokenQrScreen> {
  late String _token = widget.token;
  bool _resetting = false;

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deliveryResetPickupCodeConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.deliveryResetPickupCode)),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _resetting = true);
    try {
      final fresh = await widget.onReset!();
      if (mounted) setState(() => _token = fresh);
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.subtitle, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(data: _token, size: 240, backgroundColor: Colors.white),
              ),
              // TEMPORARY (emulator testing, no camera): show the code as text so it
              // can be copied to the other emulator and pasted into the manual
              // entry dialog. Remove with the other QR bypasses.
              const SizedBox(height: 12),
              SelectableText(_token, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              TextButton.icon(
                onPressed: () => Clipboard.setData(ClipboardData(text: _token)),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy code (dev only)'),
              ),
              if (widget.onReset != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _resetting ? null : _reset,
                  icon: _resetting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh),
                  label: Text(l10n.deliveryResetPickupCode),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
