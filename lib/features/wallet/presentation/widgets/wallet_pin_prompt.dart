import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/wallet_providers.dart';

/// The one PIN gate for every wallet-protected action outside the wallet
/// feature itself (guarantee activate/unlock today; booking's wallet-held
/// deposit confirm tomorrow) — none of these move money on their own, they
/// just started requiring the same PIN a real transfer does.
///
/// No OK/Cancel: filling the last box runs [action] immediately, a wrong PIN
/// just flashes the boxes red and clears them for another try (the actual
/// error text stays in [onError] for a case retrying can't fix). Checks
/// whether the caller has a PIN yet first — walks them through setting one
/// and runs [action] with it right after, if not. Returns whether [action]
/// ultimately ran and succeeded.
Future<bool> promptWalletPin(
  BuildContext context,
  WidgetRef ref, {
  required Future<void> Function(String pin) action,
  void Function(Object error)? onError,
}) async {
  final status = await ref.read(walletApiProvider).pinStatus();
  if (!context.mounted) return false;

  if (!status.isSet) {
    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreatePinDialog(length: status.length),
    );
    if (pin == null || !context.mounted) return false;

    try {
      await action(pin);
      return true;
    } catch (e) {
      onError?.call(e);
      return false;
    }
  }

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EnterPinDialog(length: status.length, action: action, onOtherError: onError),
  );
  return result ?? false;
}

/// Six tap-anywhere-to-focus boxes over a single invisible text field — the
/// field does the real keyboard capture (so paste/autofill/hardware keyboards
/// all still work), the boxes are pure display.
class _PinBoxes extends StatefulWidget {
  final int length;
  final bool error;
  final ValueChanged<String> onChanged;
  const _PinBoxes({super.key, required this.length, required this.error, required this.onChanged});

  @override
  State<_PinBoxes> createState() => _PinBoxesState();
}

class _PinBoxesState extends State<_PinBoxes> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void didUpdateWidget(covariant _PinBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error && widget.error) {
      _controller.clear();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filledColor = widget.error ? theme.colorScheme.error : AppColors.accentGold;
    final emptyColor = widget.error ? theme.colorScheme.error : theme.dividerColor;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 38,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: i < _controller.text.length ? filledColor : emptyColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: i < _controller.text.length
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: filledColor),
                        )
                      : null,
                ),
              ],
            ],
          ),
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                onChanged: (value) {
                  setState(() {});
                  widget.onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnterPinDialog extends StatefulWidget {
  final int length;
  final Future<void> Function(String pin) action;
  final void Function(Object error)? onOtherError;
  const _EnterPinDialog({required this.length, required this.action, this.onOtherError});

  @override
  State<_EnterPinDialog> createState() => _EnterPinDialogState();
}

class _EnterPinDialogState extends State<_EnterPinDialog> {
  bool _error = false;
  bool _submitting = false;

  Future<void> _onChanged(String value) async {
    if (_error) setState(() => _error = false);
    if (value.length != widget.length || _submitting) return;

    setState(() => _submitting = true);
    try {
      await widget.action(value);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (e.firstErrorFor('pin') != null) {
        if (mounted) setState(() { _error = true; _submitting = false; });
      } else {
        if (mounted) Navigator.of(context).pop(false);
        widget.onOtherError?.call(e);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(false);
      widget.onOtherError?.call(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.walletPinEnterTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinBoxes(length: widget.length, error: _error, onChanged: _onChanged),
          const SizedBox(height: 16),
          SizedBox(
            height: 18,
            child: _submitting
                ? const CircularProgressIndicator(strokeWidth: 2)
                : _error
                ? Text(l10n.walletPinWrong, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))
                : null,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
      ],
    );
  }
}

class _CreatePinDialog extends ConsumerStatefulWidget {
  final int length;
  const _CreatePinDialog({required this.length});

  @override
  ConsumerState<_CreatePinDialog> createState() => _CreatePinDialogState();
}

class _CreatePinDialogState extends ConsumerState<_CreatePinDialog> {
  String _pin = '';
  bool _confirming = false;
  bool _error = false;
  bool _submitting = false;

  Future<void> _onPinChanged(String value) async {
    if (_error) setState(() => _error = false);
    if (value.length != widget.length) return;
    setState(() {
      _pin = value;
      _confirming = true;
    });
  }

  Future<void> _onConfirmChanged(String value) async {
    if (_error) setState(() => _error = false);
    if (value.length != widget.length) return;

    if (value != _pin) {
      setState(() {
        _error = true;
        _confirming = false;
        _pin = '';
      });
      return;
    }

    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(walletApiProvider).setPin(pin: _pin);
      if (mounted) Navigator.pop(context, _pin);
    } catch (e) {
      final message = e is ApiException ? (e.firstErrorFor('pin') ?? e.message) : l10n.commonSomethingWentWrong;
      if (mounted) {
        setState(() {
          _error = true;
          _confirming = false;
          _pin = '';
          _submitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.walletPinCreateTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.walletPinCreateHint(widget.length),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 16),
          Text(
            _confirming ? l10n.walletPinConfirmHint : l10n.walletPinFieldHint,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          // Keyed by step so a fresh _PinBoxes (and a fresh focus request)
          // mounts for the confirm step instead of reusing the PIN step's.
          _PinBoxes(
            key: ValueKey(_confirming),
            length: widget.length,
            error: _error,
            onChanged: _confirming ? _onConfirmChanged : _onPinChanged,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 18,
            child: _submitting
                ? const CircularProgressIndicator(strokeWidth: 2)
                : _error
                ? Text(l10n.walletPinMismatch, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))
                : null,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
      ],
    );
  }
}
