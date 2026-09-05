import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/maps_launcher.dart';
import '../../application/trip_run_providers.dart';
import '../../data/models/trip_run.dart';

/// The driver's live action screen for one run: the ordered stop list, the
/// one action button whose label reflects the current stop's state, and —
/// once every stop is done on a freight/distribution run — the
/// delivered/returned reconciliation form. Also serves as the "manager" view:
/// anyone with the schedules capability can open the same screen to see
/// progress live (see TripRunController — autoDispose, always refetches).
class RunDetailScreen extends ConsumerWidget {
  final int runId;
  const RunDetailScreen({super.key, required this.runId});

  Future<void> _act(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(tripRunControllerProvider(runId));
    final run = state.run;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripRunsTitle)),
      body: state.isLoading && run == null
          ? const Center(child: CircularProgressIndicator())
          : run == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(tripRunControllerProvider(runId).notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(tripRunControllerProvider(runId).notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (run.passengerCount != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.tripRunPassengerCountDisplay(run.passengerCount!),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  for (final stop in run.stops) _StopTile(stop: stop),
                  const SizedBox(height: 20),
                  if (run.isInProgress) _ActionButton(run: run, onAct: (action) => _act(context, ref, action)),
                  if (run.isAwaitingReconciliation) _ReconcileForm(run: run, onAct: (action) => _act(context, ref, action)),
                  if (run.isCompleted)
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l10n.tripRunCompletedMessage)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StopTile extends StatelessWidget {
  final TripRunStop stop;
  const _StopTile({required this.stop});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrent = stop.isHeading || stop.isArrived;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4) : null,
      child: ListTile(
        leading: Icon(
          stop.isDone
              ? Icons.check_circle
              : isCurrent
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          color: stop.isDone ? Colors.green : (isCurrent ? Theme.of(context).colorScheme.primary : null),
        ),
        title: Text(stop.label, style: TextStyle(decoration: stop.isDone ? TextDecoration.lineThrough : null)),
        subtitle: stop.address != null ? Text(stop.address!) : null,
        trailing: isCurrent
            ? IconButton(
                icon: const Icon(Icons.directions_outlined),
                tooltip: l10n.tripRunNavigate,
                onPressed: () => MapsLauncher.navigateTo(context, stop.navigationDestination),
              )
            : null,
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  final TripRun run;
  final Future<void> Function(Future<void> Function()) onAct;
  const _ActionButton({required this.run, required this.onAct});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = run.currentStop;
    final isActing = ref.watch(tripRunControllerProvider(run.id)).isActing;

    if (current == null) return const SizedBox.shrink();

    final upcoming = run.stops.where((s) => s.sequence > current.sequence).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final next = upcoming.isEmpty ? null : upcoming.first;

    final label = current.isHeading
        ? l10n.tripRunArrivedAction
        : (next != null ? l10n.tripRunAdvanceToNext(next.label) : l10n.tripRunFinishAction);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isActing
            ? null
            : () => onAct(() {
                final notifier = ref.read(tripRunControllerProvider(run.id).notifier);
                return current.isHeading ? notifier.arrive() : notifier.advance();
              }),
        child: isActing
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      ),
    );
  }
}

class _ReconcileForm extends ConsumerStatefulWidget {
  final TripRun run;
  final Future<void> Function(Future<void> Function()) onAct;
  const _ReconcileForm({required this.run, required this.onAct});

  @override
  ConsumerState<_ReconcileForm> createState() => _ReconcileFormState();
}

class _ReconcileFormState extends ConsumerState<_ReconcileForm> {
  final Map<int, TextEditingController> _delivered = {};
  final Map<int, TextEditingController> _returned = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.run.manifestItems) {
      _delivered[item.id] = TextEditingController(text: '0');
      _returned[item.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    for (final c in [..._delivered.values, ..._returned.values]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isActing = ref.watch(tripRunControllerProvider(widget.run.id)).isActing;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tripRunReconcileTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final item in widget.run.manifestItems) ...[
              Text('${item.label}${item.unit != null ? ' (${item.unit})' : ''} — ${item.assignedQty}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _delivered[item.id],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.tripRunReconcileDelivered),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _returned[item.id],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.tripRunReconcileReturned),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isActing
                    ? null
                    : () => widget.onAct(() {
                        final items = <int, ({int delivered, int returned})>{};
                        for (final item in widget.run.manifestItems) {
                          items[item.id] = (
                            delivered: int.tryParse(_delivered[item.id]!.text.trim()) ?? 0,
                            returned: int.tryParse(_returned[item.id]!.text.trim()) ?? 0,
                          );
                        }
                        return ref.read(tripRunControllerProvider(widget.run.id).notifier).reconcile(items);
                      }),
                child: isActing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.tripRunReconcileSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
