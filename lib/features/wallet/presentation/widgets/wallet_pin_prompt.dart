import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/wallet_providers.dart';

/// The one PIN gate for every wallet-protected action outside the wallet
/// feature itself (guarantee activate/unlock today; booking's wallet-held
/// deposit confirm tomorrow) — none of these move money on their own, they
/// just started requiring the same PIN a real transfer does. Checks whether
/// the caller has a PIN yet: walks them through setting one first if not,
/// otherwise just asks for it. Returns the PIN to send with the actual
/// request, or null if the user backs out.
Future<String?> promptWalletPin(BuildContext context, WidgetRef ref) async {
  final status = await ref.read(walletApiProvider).pinStatus();
  if (!context.mounted) return null;

  if (!status.isSet) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreatePinDialog(length: status.length),
    );
  }

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EnterPinDialog(length: status.length),
  );
}

class _EnterPinDialog extends StatefulWidget {
  final int length;
  const _EnterPinDialog({required this.length});

  @override
  State<_EnterPinDialog> createState() => _EnterPinDialogState();
}

class _EnterPinDialogState extends State<_EnterPinDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.walletPinEnterTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: widget.length,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(hintText: l10n.walletPinFieldHint, counterText: ''),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l10n.commonOk)),
      ],
    );
  }

  void _submit() {
    if (_controller.text.length != widget.length) return;
    Navigator.pop(context, _controller.text);
  }
}

class _CreatePinDialog extends ConsumerStatefulWidget {
  final int length;
  const _CreatePinDialog({required this.length});

  @override
  ConsumerState<_CreatePinDialog> createState() => _CreatePinDialogState();
}

class _CreatePinDialogState extends ConsumerState<_CreatePinDialog> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final pin = _pinController.text;
    if (pin.length != widget.length) {
      setState(() => _error = l10n.walletPinInvalidLength(widget.length));
      return;
    }
    if (pin != _confirmController.text) {
      setState(() => _error = l10n.walletPinMismatch);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(walletApiProvider).setPin(pin: pin);
      if (mounted) Navigator.pop(context, pin);
    } catch (e) {
      final message = e is ApiException ? (e.firstErrorFor('pin') ?? e.message) : l10n.commonSomethingWentWrong;
      if (mounted) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.walletPinCreateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.walletPinCreateHint(widget.length),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pinController,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: widget.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: l10n.walletPinFieldHint, counterText: ''),
          ),
          TextField(
            controller: _confirmController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: widget.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: l10n.walletPinConfirmHint, counterText: ''),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 4),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _submitting ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.commonCreate),
        ),
      ],
    );
  }
}
