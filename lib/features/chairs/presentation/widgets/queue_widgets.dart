import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/application/business_page_providers.dart';
import '../../../business/data/models/offering_item.dart';
import '../../application/chairs_providers.dart';
import '../../data/models/service_chair.dart';
import '../../../../core/time/clock_format.dart';

/// Runs one action of the queue (call / start / finish): the screen owns the busy flag, the refresh and the error.
typedef QueueAct = Future<void> Function(Future<void> Function() action, {String? done});

/// One chair's line as the staff work it: who is being served, who has been called, who waits — each with the one
/// button that moves them on. Shared by the business's console and the barber's own screen.
class QueueSection extends ConsumerWidget {
  final List<QueueItem> items;
  final bool busy;
  final QueueAct onAct;

  /// The business the caller acts for when it is not their own (a staff member); null for the owner.
  final int? businessId;

  const QueueSection({super.key, required this.items, required this.busy, required this.onAct, this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final api = ref.watch(chairsApiProvider);

    final serving = items.where((i) => i.isServing).toList();
    final called = items.where((i) => i.isCalled).toList();
    final waiting = items.where((i) => !i.isServing && !i.isCalled).toList()
      ..sort((a, b) => (a.startsAt ?? DateTime(2100)).compareTo(b.startsAt ?? DateTime(2100)));
    final out = <Widget>[];

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w700),
      ),
    );

    for (final i in serving) {
      out
        ..add(label(l10n.queueNowServing))
        ..add(
          TurnCard(
            item: i,
            highlight: true,
            actions: [
              FilledButton.icon(
                onPressed: busy ? null : () => onAct(() => api.finish(i.id, businessId: businessId)),
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.queueFinish),
              ),
            ],
          ),
        );
    }

    for (final i in called) {
      out
        ..add(label(l10n.queueCalled))
        ..add(
          TurnCard(
            item: i,
            highlight: true,
            actions: [
              FilledButton.icon(
                onPressed: busy ? null : () => onAct(() => api.start(i.id, businessId: businessId)),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.queueStart),
              ),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => onAct(() => api.call(i.id, businessId: businessId), done: l10n.queueCalledSent),
                child: Text(l10n.queueCallAgain),
              ),
            ],
          ),
        );
    }

    if (waiting.isEmpty && serving.isEmpty && called.isEmpty) {
      out.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(l10n.queueNobody, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
        ),
      );
    }

    if (waiting.isNotEmpty) {
      out.add(label(l10n.queueWaiting));
      for (var n = 0; n < waiting.length; n++) {
        final i = waiting[n];
        out.add(
          TurnCard(
            item: i,
            actions: [
              if (n == 0)
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => onAct(() => api.call(i.id, businessId: businessId), done: l10n.queueCalledSent),
                  icon: const Icon(Icons.campaign_outlined),
                  label: Text(l10n.queueCallNext),
                ),
            ],
          ),
        );
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: out);
  }
}

class TurnCard extends StatelessWidget {
  final QueueItem item;
  final List<Widget> actions;
  final bool highlight;
  const TurnCard({super.key, required this.item, required this.actions, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: highlight ? cs.secondary : Colors.transparent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    item.turn == null ? '—' : '${item.turn}',
                    style: TextStyle(color: cs.onPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.customerName.isEmpty ? l10n.queueTurnShort(item.turn ?? 0) : item.customerName,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        [
                          if (item.title.isNotEmpty) item.title,
                          if (item.startsAt != null) ClockFormat.time(context, item.startsAt!),
                          if (item.walkIn) l10n.queueWalkInTag,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[const SizedBox(height: 10), Wrap(spacing: 8, runSpacing: 8, children: actions)],
          ],
        ),
      ),
    );
  }
}

/// «عميل بدون حجز»: the staff add a turn for someone standing at the door — a name, a phone, the service and the chair.
class WalkInForm extends ConsumerStatefulWidget {
  /// The chairs the turn may go to (a barber's own; the whole house's for the owner).
  final List<ServiceChair> chairs;

  /// The business whose services are offered — the employer when a staff member adds the turn.
  final int businessId;

  /// Whether the caller acts for someone else's business (sends it with the request).
  final bool actingForOther;

  const WalkInForm({super.key, required this.chairs, required this.businessId, this.actingForOther = false});

  @override
  ConsumerState<WalkInForm> createState() => _WalkInFormState();
}

class _WalkInFormState extends ConsumerState<WalkInForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  int? _offeringId;
  int? _chairId;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // one chair to choose from is no choice: the turn simply goes there
    if (widget.chairs.length == 1) _chairId = widget.chairs.first.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _add(List<OfferingItem> services) async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.queueWalkInName);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final turn = await ref
          .read(chairsApiProvider)
          .walkIn(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            offeringId: _offeringId ?? services.first.id,
            chairId: _chairId,
            businessId: widget.actingForOther ? widget.businessId : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.queueWalkInAdded(turn))));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final services = (ref.watch(businessOfferingsProvider(widget.businessId)).valueOrNull ?? const <OfferingItem>[])
        .where((o) => o.isBookable)
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.queueWalkInTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.queueWalkInName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.queueWalkInPhone),
            ),
            const SizedBox(height: 12),
            if (services.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: _offeringId ?? services.first.id,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.queueWalkInService),
                items: [for (final s in services) DropdownMenuItem(value: s.id, child: Text(s.label))],
                onChanged: (v) => setState(() => _offeringId = v),
              ),
            if (widget.chairs.length > 1) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _chairId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.chairPickTitle),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(l10n.chairAnyone)),
                  for (final c in widget.chairs) DropdownMenuItem<int?>(value: c.id, child: Text(c.title)),
                ],
                onChanged: (v) => setState(() => _chairId = v),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _busy || services.isEmpty ? null : () => _add(services),
              child: _busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.queueWalkInAdd),
            ),
          ],
        ),
      ),
    );
  }
}
