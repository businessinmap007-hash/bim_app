import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/schedules_providers.dart';
import '../../data/models/trip_run.dart';
import 'run_detail_screen.dart';

/// Every run across the business's legs, most-recent first — the "manager"
/// overview: which vehicle is where right now, and which trips already
/// finished. Tapping one opens the same live screen the driver uses.
class RunsListScreen extends ConsumerStatefulWidget {
  const RunsListScreen({super.key});

  @override
  ConsumerState<RunsListScreen> createState() => _RunsListScreenState();
}

class _RunsListScreenState extends ConsumerState<RunsListScreen> {
  bool _loading = true;
  String? _error;
  List<TripRun> _runs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(schedulesApiProvider).myRuns();
      if (mounted) setState(() => _runs = result.items);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException ? e.message : AppLocalizations.of(context)!.commonSomethingWentWrong);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
    'in_progress' => l10n.tripRunStatusInProgress,
    'awaiting_reconciliation' => l10n.tripRunStatusAwaitingReconciliation,
    _ => l10n.tripRunStatusCompleted,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripRunsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
                ],
              ),
            )
          : _runs.isEmpty
          ? Center(child: Text(l10n.tripRunEmpty))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _runs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final run = _runs[index];
                  final current = run.currentStop;
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(run.vehicleLabel ?? '#${run.tripScheduleId}'),
                      subtitle: Text(current != null
                          ? (current.isArrived ? l10n.tripRunArrivedAt(current.label) : l10n.tripRunHeadingTo(current.label))
                          : _statusLabel(l10n, run.status)),
                      trailing: Text(_statusLabel(l10n, run.status)),
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => RunDetailScreen(runId: run.id)));
                        _load();
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
