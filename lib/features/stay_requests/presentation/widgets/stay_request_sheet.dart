import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/stay_requests_providers.dart';
import '../../data/models/stay_request.dart';

/// Wording of a request's state, shared by the guest's list and the hotel's screen.
String stayRequestStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'in_progress' => l10n.stayReqStatusInProgress,
  'done' => l10n.stayReqStatusDone,
  'cancelled' => l10n.stayReqStatusCancelled,
  _ => l10n.stayReqStatusNew,
};

/// «بلّغ عن مشكلة» / «اطلب خدمة» — the guest's two buttons during a running hotel stay. Opens on [kind]; the same
/// sheet lists what has already been asked, so a guest sees the hotel's progress without leaving it.
Future<void> showStayRequestSheet(BuildContext context, {required int bookingId, required String kind}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => StayRequestSheet(bookingId: bookingId, kind: kind),
  );
}

class StayRequestSheet extends ConsumerStatefulWidget {
  final int bookingId;
  final String kind;
  const StayRequestSheet({super.key, required this.bookingId, required this.kind});

  @override
  ConsumerState<StayRequestSheet> createState() => _StayRequestSheetState();
}

class _StayRequestSheetState extends ConsumerState<StayRequestSheet> {
  final _note = TextEditingController();
  String? _choice;
  bool _busy = false;

  bool get _isIssue => widget.kind == StayRequest.kindIssue;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final choice = _choice;
    if (choice == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(stayRequestsApiProvider).create(
        widget.bookingId,
        kind: widget.kind,
        category: _isIssue ? choice : null,
        title: _isIssue ? null : choice,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      ref.invalidate(stayRequestOptionsProvider(widget.bookingId));
      if (!mounted) return;
      _note.clear();
      setState(() => _choice = null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.stayReqSent)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _withdraw(StayRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(stayRequestsApiProvider).cancel(widget.bookingId, request.id);
      ref.invalidate(stayRequestOptionsProvider(widget.bookingId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(stayRequestOptionsProvider(widget.bookingId));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: async.when(
            loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
            error: (_, _) => Padding(padding: const EdgeInsets.all(24), child: Text(l10n.commonSomethingWentWrong)),
            data: (options) {
              final choices = _isIssue ? options.issues : options.services;
              final mine = options.requests.where((r) => r.kind == widget.kind).toList();
              final noteRequired = _isIssue && _choice == 'other';

              if (!options.canRequest) {
                return Padding(padding: const EdgeInsets.all(24), child: Text(l10n.stayReqNotNow, style: theme.textTheme.bodyMedium));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_isIssue ? l10n.stayReqIssueTitle : l10n.stayReqServiceTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in choices)
                        ChoiceChip(
                          label: Text(c.label),
                          selected: _choice == c.value,
                          onSelected: _busy ? null : (_) => setState(() => _choice = c.value),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _note,
                    maxLength: 500,
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(labelText: noteRequired ? l10n.stayReqNoteHintRequired : l10n.stayReqNoteHint),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy || _choice == null || (noteRequired && _note.text.trim().isEmpty) ? null : _send,
                      child: _busy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.stayReqSend),
                    ),
                  ),
                  if (mine.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(l10n.stayReqMine, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    for (final r in mine)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(r.label),
                        subtitle: Text(
                          [stayRequestStatusLabel(r.status, l10n), if (r.note != null && r.note!.isNotEmpty) r.note!].join(' · '),
                        ),
                        trailing: r.isNew
                            ? TextButton(onPressed: () => _withdraw(r), child: Text(l10n.stayReqWithdraw))
                            : null,
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
