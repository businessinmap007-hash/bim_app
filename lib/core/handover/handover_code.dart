import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import 'token_scan_screen.dart';

/// The platform's handover code core, app side. A handover (a parcel picked up or delivered, a clinic arrival, an
/// order…) is proved with ONE short string: shown as a QR by the party who owns it ([HandoverCodeCard]) and read by
/// the other either by scanning that QR or by typing the same string ([askHandoverCode]) — the QR encodes exactly the
/// typed code, so both land on the same value and the server compares one thing.
///
/// Returns what was scanned or typed (trimmed), or null when the person backed out.
Future<String?> askHandoverCode(
  BuildContext context, {
  required String title,
  required String hint,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AskHandoverCodeSheet(title: title, hint: hint),
  );
}

class _AskHandoverCodeSheet extends StatefulWidget {
  final String title;
  final String hint;
  const _AskHandoverCodeSheet({required this.title, required this.hint});

  @override
  State<_AskHandoverCodeSheet> createState() => _AskHandoverCodeSheetState();
}

class _AskHandoverCodeSheetState extends State<_AskHandoverCodeSheet> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final l10n = AppLocalizations.of(context)!;
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => TokenScanScreen(title: widget.title, hint: widget.hint.isNotEmpty ? widget.hint : l10n.qrScanTitle)),
    );

    if (scanned != null && scanned.trim().isNotEmpty && mounted) {
      Navigator.of(context).pop(scanned.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              if (widget.hint.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(widget.hint, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _scan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.handoverScanQr),
                ),
              ),
              const SizedBox(height: 10),
              Text(l10n.handoverOrTypeCode, style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),
              TextField(
                controller: _typed,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.done,
                onSubmitted: (v) => v.trim().isEmpty ? null : Navigator.of(context).pop(v.trim()),
                decoration: InputDecoration(labelText: l10n.handoverCodeLabel, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _typed.text.trim().isEmpty ? null : Navigator.of(context).pop(_typed.text.trim()),
                  child: Text(l10n.handoverConfirmTyped),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A handover code to show: the QR the other party scans, and the same code in big letters to read out / copy.
class HandoverCodeCard extends StatefulWidget {
  final String code;
  final String caption;
  final bool showQr;

  /// The typed code stays behind a «إظهار الكود» button: the QR is what is normally shown, the text is for whoever has
  /// no app to scan with (the sender tells it to him).
  final bool hideCode;
  const HandoverCodeCard({super.key, required this.code, required this.caption, this.showQr = true, this.hideCode = false});

  @override
  State<HandoverCodeCard> createState() => _HandoverCodeCardState();
}

class _HandoverCodeCardState extends State<HandoverCodeCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textVisible = !widget.hideCode || _revealed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.caption, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        if (widget.showQr)
          Center(child: QrImageView(data: widget.code, size: 160, backgroundColor: Colors.white)),
        if (widget.hideCode)
          TextButton.icon(
            onPressed: () => setState(() => _revealed = !_revealed),
            icon: Icon(_revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            label: Text(_revealed ? l10n.handoverHideCode : l10n.handoverShowCode),
          ),
        if (textVisible)
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  widget.code,
                  style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 4, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(icon: const Icon(Icons.copy_outlined), onPressed: () => Clipboard.setData(ClipboardData(text: widget.code))),
            ],
          ),
      ],
    );
  }
}
