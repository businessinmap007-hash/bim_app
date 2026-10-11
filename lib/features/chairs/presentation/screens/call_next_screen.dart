import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../business/application/business_page_providers.dart';
import '../../../business/data/models/offering_item.dart';
import '../../application/chairs_providers.dart';
import '../../data/models/service_chair.dart';
import '../widgets/chair_picker.dart';

/// «نداء الدور التالي» — the business's own queue for the day, by chair: who is being served, who has been called, who
/// waits. One tap calls the next customer (they are told), one starts the service, one finishes it; and a customer who
/// walked in with no booking is added from here.
class CallNextScreen extends ConsumerStatefulWidget {
  const CallNextScreen({super.key});

  @override
  ConsumerState<CallNextScreen> createState() => _CallNextScreenState();
}

class _CallNextScreenState extends ConsumerState<CallNextScreen> {
  Timer? _timer;
  int? _chairFilter;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // the queue moves while the screen is open: other staff call, customers cancel, new turns arrive
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) ref.invalidate(businessQueueProvider);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _act(Future<void> Function() action, {String? done}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(businessQueueProvider);
      if (mounted && done != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      if (mounted) {
        final message = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _walkIn(BusinessQueue queue) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WalkInForm(chairs: queue.chairs),
    );
    if (added == true) ref.invalidate(businessQueueProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(businessQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.queueConsoleTitle),
        actions: [IconButton(onPressed: () => ref.invalidate(businessQueueProvider), icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: async.valueOrNull == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _walkIn(async.value!),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l10n.queueAddWalkIn),
            ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(onPressed: () => ref.invalidate(businessQueueProvider), child: Text(l10n.commonSomethingWentWrong)),
        ),
        data: (queue) {
          final chairs = queue.chairs;
          // one group per chair; with no chairs the whole day is one line. A turn on no listed chair gets its own group.
          final groups = <({ServiceChair? chair, List<QueueItem> items})>[];
          if (chairs.isEmpty) {
            groups.add((chair: null, items: queue.items));
          } else {
            for (final c in chairs) {
              if (_chairFilter != null && _chairFilter != c.id) continue;
              groups.add((chair: c, items: queue.items.where((i) => i.chairId == c.id).toList()));
            }
            final known = chairs.map((c) => c.id).toSet();
            final loose = queue.items.where((i) => i.chairId == null || !known.contains(i.chairId)).toList();
            if (loose.isNotEmpty && _chairFilter == null) groups.add((chair: null, items: loose));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(businessQueueProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                if (chairs.isNotEmpty) ...[
                  ChairPicker(chairs: chairs, selected: _chairFilter, onPick: (id) => setState(() => _chairFilter = id)),
                  const SizedBox(height: 8),
                ],
                for (final g in groups) ...[
                  _GroupHeader(chair: g.chair, waiting: g.items.where((i) => !i.isServing && !i.isCalled).length, hasChairs: chairs.isNotEmpty),
                  const SizedBox(height: 8),
                  ..._section(context, l10n, theme, g.items),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _section(BuildContext context, AppLocalizations l10n, ThemeData theme, List<QueueItem> items) {
    final serving = items.where((i) => i.isServing).toList();
    final called = items.where((i) => i.isCalled).toList();
    final waiting = items.where((i) => !i.isServing && !i.isCalled).toList()
      ..sort((a, b) => (a.startsAt ?? DateTime(2100)).compareTo(b.startsAt ?? DateTime(2100)));
    final out = <Widget>[];

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(text, style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w700)),
    );

    for (final i in serving) {
      out
        ..add(label(l10n.queueNowServing))
        ..add(
          _TurnCard(
            item: i,
            highlight: true,
            actions: [FilledButton.icon(onPressed: _busy ? null : () => _act(() => ref.read(chairsApiProvider).finish(i.id)), icon: const Icon(Icons.check_rounded), label: Text(l10n.queueFinish))],
          ),
        );
    }

    for (final i in called) {
      out
        ..add(label(l10n.queueCalled))
        ..add(
          _TurnCard(
            item: i,
            highlight: true,
            actions: [
              FilledButton.icon(onPressed: _busy ? null : () => _act(() => ref.read(chairsApiProvider).start(i.id)), icon: const Icon(Icons.play_arrow_rounded), label: Text(l10n.queueStart)),
              OutlinedButton(onPressed: _busy ? null : () => _act(() => ref.read(chairsApiProvider).call(i.id), done: l10n.queueCalledSent), child: Text(l10n.queueCallAgain)),
            ],
          ),
        );
    }

    if (waiting.isEmpty && serving.isEmpty && called.isEmpty) {
      out.add(Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(l10n.queueNobody, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))));
    }

    if (waiting.isNotEmpty) {
      out.add(label(l10n.queueWaiting));
      for (var n = 0; n < waiting.length; n++) {
        final i = waiting[n];
        out.add(
          _TurnCard(
            item: i,
            actions: [
              if (n == 0)
                FilledButton.icon(
                  onPressed: _busy ? null : () => _act(() => ref.read(chairsApiProvider).call(i.id), done: l10n.queueCalledSent),
                  icon: const Icon(Icons.campaign_outlined),
                  label: Text(l10n.queueCallNext),
                ),
            ],
          ),
        );
      }
    }

    return out;
  }
}

class _GroupHeader extends StatelessWidget {
  final ServiceChair? chair;
  final int waiting;
  final bool hasChairs;
  const _GroupHeader({required this.chair, required this.waiting, required this.hasChairs});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (!hasChairs) return const SizedBox.shrink();

    return Row(
      children: [
        ChairAvatar(chair: chair, size: 38),
        const SizedBox(width: 10),
        Expanded(child: Text(chair?.title ?? l10n.queueNoChair, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
        Text('$waiting', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}

class _TurnCard extends StatelessWidget {
  final QueueItem item;
  final List<Widget> actions;
  final bool highlight;
  const _TurnCard({required this.item, required this.actions, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();

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
                      Text(item.customerName.isEmpty ? l10n.queueTurnShort(item.turn ?? 0) : item.customerName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        [
                          if (item.title.isNotEmpty) item.title,
                          if (item.startsAt != null) DateFormat.jm(locale).format(item.startsAt!),
                          if (item.walkIn) l10n.queueWalkInTag,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _WalkInForm extends ConsumerStatefulWidget {
  final List<ServiceChair> chairs;
  const _WalkInForm({required this.chairs});

  @override
  ConsumerState<_WalkInForm> createState() => _WalkInFormState();
}

class _WalkInFormState extends ConsumerState<_WalkInForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  int? _offeringId;
  int? _chairId;
  bool _busy = false;
  String? _error;

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
      final turn = await ref.read(chairsApiProvider).walkIn(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        offeringId: _offeringId ?? services.first.id,
        chairId: _chairId,
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
    final auth = ref.watch(authControllerProvider);
    final myId = auth is AuthSignedIn ? auth.user.id : null;
    final services = myId == null ? <OfferingItem>[] : (ref.watch(businessOfferingsProvider(myId)).valueOrNull ?? const <OfferingItem>[]).where((o) => o.isBookable).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.queueWalkInTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            TextField(controller: _name, autofocus: true, decoration: InputDecoration(labelText: l10n.queueWalkInName)),
            const SizedBox(height: 12),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.queueWalkInPhone)),
            const SizedBox(height: 12),
            if (services.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: _offeringId ?? services.first.id,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.queueWalkInService),
                items: [for (final s in services) DropdownMenuItem(value: s.id, child: Text(s.label))],
                onChanged: (v) => setState(() => _offeringId = v),
              ),
            if (widget.chairs.isNotEmpty) ...[
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
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _busy || services.isEmpty ? null : () => _add(services),
              child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.queueWalkInAdd),
            ),
          ],
        ),
      ),
    );
  }
}
