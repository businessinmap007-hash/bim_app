import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_training_providers.dart';
import '../../data/models/trainer_weekly_summary.dart';
import '../../data/models/training_plan.dart';
import 'training_plan_manage_screen.dart';

/// Api\V2\TrainingPlanController::index — plans a trainer has already
/// assigned to clients. No "new plan" entry here: creating one needs a
/// client_id this app has no person-picker for (the same gap already
/// documented for TrainingTemplateController::apply) — a plan is created
/// elsewhere (admin, or a future picker) and managed here once it exists.
class MyTrainingClientsScreen extends ConsumerWidget {
  const MyTrainingClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myTrainingClientsControllerProvider);
    // Best effort: the list is the screen, the adherence overview only decorates it.
    final week = ref.watch(trainerWeeklySummaryProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myTrainingClientsTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(myTrainingClientsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.trainingClientsEmpty))
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(trainerWeeklySummaryProvider);
                await ref.read(myTrainingClientsControllerProvider.notifier).load();
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (week != null ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (week != null && index == 0) return _WeekHeader(week: week);
                  final plan = state.items[index - (week != null ? 1 : 0)];
                  return _PlanTile(plan: plan, week: week?.byPlan[plan.id]);
                },
              ),
            ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final TrainerWeeklySummary week;
  const _WeekHeader({required this.week});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.trainingWeeklyRange(material.formatShortDate(week.from), material.formatShortDate(week.to)),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            if (week.averageAdherence != null) ...[
              const SizedBox(height: 4),
              Text(l10n.trainingWeeklyAverage(week.averageAdherence!), style: theme.textTheme.titleSmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final TrainingPlan plan;
  final ClientWeekAdherence? week;
  const _PlanTile({required this.plan, this.week});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrainingPlanManageScreen(planId: plan.id)),
        ),
        title: Text(plan.clientName ?? '#${plan.clientId ?? plan.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.title),
            if (week != null) ...[
              const SizedBox(height: 6),
              if (week!.weeklyTargetRounds == 0)
                Text(l10n.trainingClientNoSchedule, style: Theme.of(context).textTheme.bodySmall)
              else ...[
                LinearProgressIndicator(value: (week!.adherencePercent ?? 0) / 100),
                const SizedBox(height: 4),
                Text(
                  '${week!.adherencePercent ?? 0}% · ${l10n.trainingClientWeek(week!.completedRounds, week!.weeklyTargetRounds, week!.activeDays, week!.checkIns)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ],
        ),
        trailing: Chip(
          label: Text(_statusLabel(l10n, plan.status)),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
    'active' => l10n.trainingPlanStatusActive,
    'paused' => l10n.trainingPlanStatusPaused,
    'completed' => l10n.trainingPlanStatusCompleted,
    'cancelled' => l10n.trainingPlanStatusCancelled,
    _ => status,
  };
}
