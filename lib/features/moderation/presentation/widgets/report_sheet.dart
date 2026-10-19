import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/moderation_providers.dart';

/// «إبلاغ»: pick why, add a word if you like, send. Works for any post or owner listing — [type] is
/// `post` or `owner_listing`. The server counts one report per person per item, so tapping it twice is harmless.
Future<void> showReportSheet(
  BuildContext context, {
  required String type,
  required int id,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ReportSheet(type: type, id: id),
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  final String type;
  final int id;
  const _ReportSheet({required this.type, required this.id});

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _details = TextEditingController();
  String? _reason;
  bool _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);

    try {
      await ref
          .read(moderationApiProvider)
          .report(
            type: widget.type,
            id: widget.id,
            reason: _reason!,
            details: _details.text,
          );
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
    } on ApiException catch (e) {
      if (mounted) setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reasons = ref.watch(reportReasonsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            reasons.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(e is ApiException ? e.message : '$e'),
              ),
              data: (items) => RadioGroup<String>(
                groupValue: _reason,
                onChanged: (v) => setState(() => _reason = v),
                child: Column(
                  children: [
                    for (final r in items)
                      RadioListTile<String>(
                        value: r.key,
                        title: Text(r.name),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _details,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.reportDetailsHint),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _reason == null || _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.reportSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
