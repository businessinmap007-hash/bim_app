import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/chairs_providers.dart';
import '../../data/models/service_chair.dart';
import '../widgets/chair_picker.dart';
import '../widgets/queue_widgets.dart';

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
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthSignedIn) return;

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalkInForm(chairs: queue.chairs, businessId: auth.user.id),
    );
    if (added == true) ref.invalidate(businessQueueProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          child: TextButton(
            onPressed: () => ref.invalidate(businessQueueProvider),
            child: Text(l10n.commonSomethingWentWrong),
          ),
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
                  ChairPicker(
                    chairs: chairs,
                    selected: _chairFilter,
                    onPick: (id) => setState(() => _chairFilter = id),
                  ),
                  const SizedBox(height: 8),
                ],
                for (final g in groups) ...[
                  _GroupHeader(
                    chair: g.chair,
                    waiting: g.items.where((i) => !i.isServing && !i.isCalled).length,
                    hasChairs: chairs.isNotEmpty,
                  ),
                  const SizedBox(height: 8),
                  QueueSection(items: g.items, busy: _busy, onAct: _act),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          );
        },
      ),
    );
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
        Expanded(
          child: Text(
            chair?.title ?? l10n.queueNoChair,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text('$waiting', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}
