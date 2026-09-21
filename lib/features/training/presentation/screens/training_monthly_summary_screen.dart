import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/training_providers.dart';
import '../../data/models/set_log.dart';

String _monthKey(DateTime m) => '${m.year}-${m.month.toString().padLeft(2, '0')}';

/// A plan's month, rolled up from the confirmed sets: finished days, totals,
/// each exercise's best and total, and the weight check-ins. Read by the
/// trainee (their own month) and by the trainer (a client's month); the
/// trainer can also open any finished day to see its sets against the plan.
class TrainingMonthlySummaryScreen extends ConsumerStatefulWidget {
  final int planId;

  /// true = the trainer's view of a client's plan.
  final bool trainer;

  const TrainingMonthlySummaryScreen({super.key, required this.planId, this.trainer = false});

  @override
  ConsumerState<TrainingMonthlySummaryScreen> createState() => _TrainingMonthlySummaryScreenState();
}

class _TrainingMonthlySummaryScreenState extends ConsumerState<TrainingMonthlySummaryScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  Future<void> _openDay(FinishedDay day) async {
    final l10n = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, controller) => FutureBuilder<List<DayLogExercise>>(
          future: ref.read(trainingApiProvider).dayLog(widget.planId, day.date),
          builder: (context, snapshot) {
            final theme = Theme.of(context);
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text(l10n.commonSomethingWentWrong));
            final exercises = snapshot.data ?? const [];
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.trainingDayLogTitle(material.formatShortDate(day.date)), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final e in exercises) ...[
                  Text(e.name, style: theme.textTheme.titleSmall),
                  if (e.targetSets != null || e.targetReps != null || e.targetWeight != null)
                    Text(
                      [
                        if (e.targetSets != null) '${e.targetSets} × ${e.targetReps ?? '–'}',
                        if (e.targetWeight != null) '${formatWeight(e.targetWeight)} ${l10n.trainingKgUnit}',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [for (final s in e.sets) Chip(label: Text('${s.roundNumber}: ${s.label}'))],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = ref.watch(
      trainingMonthlySummaryProvider((planId: widget.planId, month: _monthKey(_month), trainer: widget.trainer)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingMonthlySummary)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left_rounded)),
                Text(material.formatMonthYear(_month), style: theme.textTheme.titleSmall),
                IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right_rounded)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: summary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
              data: (s) => s.isEmpty
                  ? Center(child: Text(l10n.trainingMonthNoData))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          children: [
                            for (final (label, value) in [
                              (l10n.trainingMonthSessions, '${s.sessionsCompleted}'),
                              (l10n.trainingMonthSets, '${s.totalSets}'),
                              (l10n.trainingMonthReps, '${s.totalReps}'),
                              (l10n.trainingMonthVolume, formatWeight(s.volumeKg) ?? '0'),
                            ])
                              Expanded(
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                    child: Column(
                                      children: [
                                        Text(value, style: theme.textTheme.titleLarge),
                                        const SizedBox(height: 2),
                                        Text(label, textAlign: TextAlign.center, style: theme.textTheme.labelSmall),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (s.firstWeight != null && s.latestWeight != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.trainingMonthWeight(formatWeight(s.firstWeight)!, formatWeight(s.latestWeight)!),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        if (s.exercises.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(l10n.trainingMonthExercises, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          for (final e in s.exercises)
                            Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                dense: true,
                                title: Text(e.name),
                                subtitle: Text(
                                  [
                                    l10n.trainingMonthSetsDone(e.setsDone),
                                    if (e.maxWeight != null) '${l10n.trainingMonthMaxWeight}: ${formatWeight(e.maxWeight)}',
                                    if (e.volumeKg > 0) '${l10n.trainingMonthVolume}: ${formatWeight(e.volumeKg)}',
                                  ].join(' · '),
                                ),
                              ),
                            ),
                        ],
                        if (s.sessions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(l10n.trainingSessionsSection, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          for (final d in s.sessions)
                            Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                dense: true,
                                leading: const Icon(Icons.check_circle_outline),
                                title: Text(material.formatMediumDate(d.date)),
                                subtitle: Text(
                                  [
                                    l10n.trainingMonthSetsDone(d.setsCount),
                                    if (d.volumeKg > 0) '${formatWeight(d.volumeKg)} ${l10n.trainingKgUnit}',
                                  ].join(' · '),
                                ),
                                trailing: widget.trainer ? const Icon(Icons.chevron_right) : null,
                                onTap: widget.trainer ? () => _openDay(d) : null,
                              ),
                            ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
