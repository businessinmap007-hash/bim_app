import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/training_providers.dart';
import '../../data/models/body_report.dart';
import '../../data/models/training_plan.dart';
import '../../data/models/weekly_summary.dart';
import 'training_chat_screen.dart';

class TrainingPlanDetailScreen extends ConsumerWidget {
  final int planId;
  const TrainingPlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(trainingPlanDetailProvider(planId));

    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(trainingPlanDetailProvider(planId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (plan) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(plan.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrainingChatScreen(planId: planId, title: plan.title),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: l10n.trainingTabExercises),
                Tab(text: l10n.trainingTabMeals),
                Tab(text: l10n.trainingTabProgress),
                Tab(text: l10n.trainingTabBodyReports),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _ExercisesTab(planId: planId, plan: plan),
              _MealsTab(plan: plan),
              _ProgressTab(planId: planId, plan: plan),
              _BodyReportsTab(planId: planId),
            ],
          ),
        ),
      ),
    );
  }
}

String _weekdayName(AppLocalizations l10n, int? day) {
  switch (day) {
    case 0:
      return l10n.weekdaySunday;
    case 1:
      return l10n.weekdayMonday;
    case 2:
      return l10n.weekdayTuesday;
    case 3:
      return l10n.weekdayWednesday;
    case 4:
      return l10n.weekdayThursday;
    case 5:
      return l10n.weekdayFriday;
    case 6:
      return l10n.weekdaySaturday;
    default:
      return '';
  }
}

class _ExercisesTab extends ConsumerWidget {
  final int planId;
  final TrainingPlan plan;
  const _ExercisesTab({required this.planId, required this.plan});

  Future<void> _completeRound(BuildContext context, WidgetRef ref, PlanExercise exercise) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(trainingApiProvider).completeRound(planId, exercise.id);
      ref.invalidate(trainingPlanDetailProvider(planId));
      ref.invalidate(trainingWeeklySummaryProvider(planId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.trainingRoundCompleted)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final exercises = plan.exercises ?? const [];

    if (exercises.isEmpty) {
      return Center(child: Text(l10n.trainingExercisesEmpty));
    }

    final byDay = <int?, List<PlanExercise>>{};
    for (final e in exercises) {
      byDay.putIfAbsent(e.dayOfWeek, () => []).add(e);
    }
    final dayKeys = byDay.keys.toList()..sort((a, b) => (a ?? -1).compareTo(b ?? -1));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final day in dayKeys) ...[
          if (day != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(_weekdayName(l10n, day), style: Theme.of(context).textTheme.titleSmall),
            ),
          for (final e in byDay[day]!) ...[
            _ExerciseCard(exercise: e, onCompleteRound: () => _completeRound(context, ref, e)),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final PlanExercise exercise;
  final VoidCallback onCompleteRound;
  const _ExerciseCard({required this.exercise, required this.onCompleteRound});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              children: [
                if (exercise.sets != null) Text('${l10n.trainingSetsLabel}: ${exercise.sets}'),
                if (exercise.reps != null) Text('${l10n.trainingRepsLabel}: ${exercise.reps}'),
                if (exercise.restSeconds != null)
                  Text('${l10n.trainingRestLabel}: ${exercise.restSeconds}s'),
              ],
            ),
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(exercise.notes!, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (exercise.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: exercise.images.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      exercise.images[index].url,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (exercise.sets != null)
                  Text(
                    '${exercise.completedRoundsToday} / ${exercise.sets}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const Spacer(),
                if (exercise.isDoneToday)
                  Text(l10n.trainingAllRoundsDone, style: Theme.of(context).textTheme.bodySmall)
                else
                  FilledButton.tonal(
                    onPressed: onCompleteRound,
                    child: Text(l10n.trainingCompleteRound),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MealsTab extends StatelessWidget {
  final TrainingPlan plan;
  const _MealsTab({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meals = plan.meals ?? const [];

    if (meals.isEmpty) {
      return Center(child: Text(l10n.trainingMealsEmpty));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: meals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_mealTypeLabel(meal.mealType, l10n), style: Theme.of(context).textTheme.labelMedium),
                Text(meal.name, style: Theme.of(context).textTheme.titleSmall),
                if (meal.calories != null)
                  Text('${meal.calories} kcal', style: Theme.of(context).textTheme.bodySmall),
                if (meal.notes != null && meal.notes!.isNotEmpty)
                  Text(meal.notes!, style: Theme.of(context).textTheme.bodySmall),
                if (meal.images.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: meal.images.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 6),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          meal.images[index].url,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

String _mealTypeLabel(String type, AppLocalizations l10n) => switch (type) {
  'breakfast' => l10n.mealBreakfast,
  'lunch' => l10n.mealLunch,
  'dinner' => l10n.mealDinner,
  'snack' => l10n.mealSnack,
  _ => type,
};

class _ProgressTab extends ConsumerStatefulWidget {
  final int planId;
  final TrainingPlan plan;
  const _ProgressTab({required this.planId, required this.plan});

  @override
  ConsumerState<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends ConsumerState<_ProgressTab> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null && _notesController.text.trim().isEmpty) return;

    setState(() => _submitting = true);
    try {
      await ref.read(trainingApiProvider).logProgress(
        widget.planId,
        weight: weight,
        notes: _notesController.text.trim(),
      );
      _weightController.clear();
      _notesController.clear();
      ref.invalidate(trainingPlanDetailProvider(widget.planId));
      ref.invalidate(trainingWeeklySummaryProvider(widget.planId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.trainingProgressLogged)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(trainingWeeklySummaryProvider(widget.planId));
    final logs = widget.plan.progress ?? const [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        summaryAsync.when(
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          )),
          error: (_, _) => const SizedBox.shrink(),
          data: (summary) => _WeeklySummaryCard(summary: summary),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.trainingLogProgress, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(hintText: l10n.trainingWeightHint),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(hintText: l10n.trainingNotesHint),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(l10n.trainingLogProgress),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text(l10n.trainingProgressEmpty)),
          )
        else
          for (final log in logs)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.monitor_weight_outlined),
              title: Text(log.weight != null ? '${log.weight} kg' : ''),
              subtitle: Text(
                [
                  if (log.loggedOn != null) _formatDate(log.loggedOn!),
                  if (log.notes != null && log.notes!.isNotEmpty) log.notes!,
                ].join(' · '),
              ),
            ),
      ],
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final TrainingWeeklySummary summary;
  const _WeeklySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.trainingWeeklySummaryTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _stat(context, l10n.trainingAdherence,
                    summary.adherencePercent != null ? '${summary.adherencePercent}%' : '-'),
                _stat(context, l10n.trainingTargetRounds, '${summary.weeklyTargetRounds}'),
                _stat(context, l10n.trainingCompletedRoundsLabel, '${summary.completedRounds}'),
                _stat(context, l10n.trainingActiveDays, '${summary.activeDays}'),
                _stat(context, l10n.trainingCheckIns, '${summary.checkIns}'),
                if (summary.latestWeight != null)
                  _stat(context, l10n.trainingLatestWeight, '${summary.latestWeight} kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _BodyReportsTab extends ConsumerWidget {
  final int planId;
  const _BodyReportsTab({required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(trainingBodyReportsProvider(planId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.commonSomethingWentWrong),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => ref.invalidate(trainingBodyReportsProvider(planId)),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(child: Text(l10n.trainingBodyReportsEmpty));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _BodyReportCard(report: reports[index]),
        );
      },
    );
  }
}

class _BodyReportCard extends StatelessWidget {
  final BodyReport report;
  const _BodyReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.forMonth ?? '', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            _measureRow(context, l10n.bodyReportWeight, report.weightKg, 'kg', report.change.weightKg),
            _measureRow(context, l10n.bodyReportMuscle, report.muscleMassKg, 'kg', report.change.muscleMassKg),
            _measureRow(context, l10n.bodyReportFat, report.fatPercent, '%', report.change.fatPercent),
            _measureRow(context, l10n.bodyReportWater, report.waterPercent, '%', report.change.waterPercent),
            _measureRow(context, l10n.bodyReportBone, report.boneMassKg, 'kg', report.change.boneMassKg),
            _measureRow(
                context, l10n.bodyReportVisceralFat, report.visceralFat, '', report.change.visceralFat),
            if (report.notes != null && report.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(report.notes!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Widget _measureRow(BuildContext context, String label, double? value, String unit, double? delta) {
    if (value == null) return const SizedBox.shrink();
    final deltaText = delta == null || delta == 0
        ? null
        : '${delta > 0 ? '+' : ''}$delta';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$value$unit'),
          if (deltaText != null) ...[
            const SizedBox(width: 6),
            Text(
              deltaText,
              style: TextStyle(color: delta! > 0 ? Colors.green : Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
