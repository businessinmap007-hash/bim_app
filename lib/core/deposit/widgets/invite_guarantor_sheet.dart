import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../network/api_exception.dart';
import '../guarantor.dart';
import '../visit_deposit.dart';
import '../visit_deposit_providers.dart';

/// «ادعُ ضامنًا من أصدقائك» — the customer asks a friend with an active guarantee to stand for the operation's
/// deposit: the friend's coverage is frozen for it and returned when it ends. Shows what is still missing and how
/// each invited friend answered.
Future<void> showInviteGuarantorSheet(BuildContext context, {required VisitKind kind, required int subjectId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _InviteGuarantorSheet(kind: kind, subjectId: subjectId),
  );
}

class _InviteGuarantorSheet extends ConsumerStatefulWidget {
  final VisitKind kind;
  final int subjectId;
  const _InviteGuarantorSheet({required this.kind, required this.subjectId});

  @override
  ConsumerState<_InviteGuarantorSheet> createState() => _InviteGuarantorSheetState();
}

class _InviteGuarantorSheetState extends ConsumerState<_InviteGuarantorSheet> {
  final _who = TextEditingController();
  GuarantorList? _list;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _who.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await ref.read(visitDepositApiProvider).guarantors(widget.kind, widget.subjectId);
      if (mounted) setState(() => _list = list);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _invite() async {
    final text = _who.text.trim();
    if (text.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      final byEmail = text.contains('@');
      await ref.read(visitDepositApiProvider).inviteGuarantor(
        widget.kind,
        widget.subjectId,
        phone: byEmail ? null : text,
        email: byEmail ? text : null,
      );
      _who.clear();
      messenger.showSnackBar(SnackBar(content: Text(l10n.guarantorSent)));
      await _load();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _status(AppLocalizations l10n, Guarantor g) => switch (g.status) {
    Guarantor.invited => l10n.guarantorStatusInvited,
    Guarantor.accepted => l10n.guarantorStatusAccepted(_money(g.coveredAmount)),
    Guarantor.declined => l10n.guarantorStatusDeclined,
    Guarantor.released => l10n.guarantorStatusReleased,
    _ => l10n.guarantorStatusCancelled,
  };

  String _money(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final list = _list;
    final needed = list?.need?.needed ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.guarantorSheetTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (_failed)
                Text(l10n.commonSomethingWentWrong)
              else if (list == null)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
              else ...[
                Text(
                  needed > 0 ? l10n.guarantorSheetBody(_money(needed)) : l10n.guarantorNoNeed,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _who,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _invite(),
                  decoration: InputDecoration(labelText: l10n.guarantorFieldHint, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _busy ? null : _invite, child: Text(l10n.guarantorSend)),
                ),
                if (list.items.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  for (final g in list.items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(g.guarantorName ?? '#${g.guarantorId ?? g.id}'),
                      subtitle: Text(_status(l10n, g)),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
