import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/chairs_providers.dart';
import '../../data/models/service_chair.dart';
import '../widgets/chair_picker.dart';
import '../widgets/queue_widgets.dart';

/// «كرسيي» — the barber's own screen: his chair, his customers of the day, nobody else's. He calls the next customer,
/// starts and finishes the service, and adds someone who walked in with no booking; the other chairs of the house are
/// not on it (and the server would refuse him if he reached for them).
class MyChairScreen extends ConsumerStatefulWidget {
  /// The business he sits a chair of — his employer, not his own account.
  final int businessId;
  final String businessName;

  const MyChairScreen({super.key, required this.businessId, this.businessName = ''});

  @override
  ConsumerState<MyChairScreen> createState() => _MyChairScreenState();
}

class _MyChairScreenState extends ConsumerState<MyChairScreen> {
  Timer? _timer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // customers arrive and cancel while he works: the line follows
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) ref.invalidate(myChairQueueProvider(widget.businessId));
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
      ref.invalidate(myChairQueueProvider(widget.businessId));
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
      builder: (_) => WalkInForm(chairs: queue.chairs, businessId: widget.businessId, actingForOther: true),
    );
    if (added == true) ref.invalidate(myChairQueueProvider(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myChairQueueProvider(widget.businessId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myChairTitle),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(myChairQueueProvider(widget.businessId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myChairQueueProvider(widget.businessId)),
            child: Text(l10n.commonSomethingWentWrong),
          ),
        ),
        data: (queue) {
          if (queue.chairs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.myChairNone,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myChairQueueProvider(widget.businessId)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _Header(queue: queue, businessName: widget.businessName),
                const SizedBox(height: 12),
                // inline, not floating: a floating button sat over the next customer's «نادِ التالي»
                OutlinedButton.icon(
                  onPressed: () => _walkIn(queue),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(l10n.queueAddWalkIn),
                ),
                const SizedBox(height: 16),
                for (final c in queue.chairs) ...[
                  // a barber with two chairs sees each line under its own face
                  if (queue.chairs.length > 1) ...[
                    Row(
                      children: [
                        ChairAvatar(chair: c, size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  QueueSection(
                    items: queue.items.where((i) => i.chairId == c.id).toList(),
                    busy: _busy,
                    onAct: _act,
                    businessId: widget.businessId,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// His face, his chair, and the day's count: how many wait, how many he has served.
class _Header extends StatelessWidget {
  final BusinessQueue queue;
  final String businessName;
  const _Header({required this.queue, required this.businessName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final chair = queue.chairs.first;
    final waiting = queue.items.where((i) => !i.isServing && !i.isCalled).length;

    Widget stat(String value, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
        ),
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                ChairAvatar(chair: chair, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chair.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      if (businessName.isNotEmpty)
                        Text(businessName, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                stat('$waiting', l10n.queueWaiting),
                const SizedBox(width: 10),
                stat('${queue.served}', l10n.myChairServed),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
