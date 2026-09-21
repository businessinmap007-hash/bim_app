import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../../shared/widgets/person_card.dart';
import '../../application/training_providers.dart';
import '../../data/models/body_report.dart';
import '../../data/models/set_log.dart';
import '../../data/models/training_plan.dart';
import '../../data/models/weekly_summary.dart';
import '../widgets/set_log_sheet.dart';
import 'training_chat_screen.dart';
import 'training_monthly_summary_screen.dart';

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
      data: (plan) => plan.isPending
          ? _PendingPlanScreen(planId: planId, plan: plan)
          : DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(plan.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.insights_outlined),
                tooltip: l10n.trainingMonthlySummary,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TrainingMonthlySummaryScreen(planId: planId)),
                ),
              ),
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

/// The trainer's plan is `pending` until I confirm it (see
/// TrainingPlanService::accept()) — same PersonCard the trainer sees right
/// after assigning it, populated with the TRAINER's own info here instead.
class _PendingPlanScreen extends ConsumerStatefulWidget {
  final int planId;
  final TrainingPlan plan;
  const _PendingPlanScreen({required this.planId, required this.plan});

  @override
  ConsumerState<_PendingPlanScreen> createState() => _PendingPlanScreenState();
}

class _PendingPlanScreenState extends ConsumerState<_PendingPlanScreen> {
  bool _submitting = false;

  Future<void> _respond(bool accept) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      if (accept) {
        await ref.read(trainingApiProvider).accept(widget.planId);
      } else {
        await ref.read(trainingApiProvider).decline(widget.planId);
      }
      ref.invalidate(trainingPlanDetailProvider(widget.planId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept ? l10n.trainingPlanAccepted : l10n.trainingPlanDeclined)),
        );
        if (!accept) Navigator.of(context).pop();
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
    final plan = widget.plan;

    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.trainingPlanPendingPrompt, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            PersonCard.forBusiness(
              name: plan.trainerName ?? '',
              phone: plan.trainerPhone,
              logoUrl: plan.trainerLogoUrl,
              subtitle: plan.goal,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => _respond(false),
                    child: Text(l10n.staffInvitationDecline),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : () => _respond(true),
                    child: _submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.staffInvitationAccept),
                  ),
                ),
              ],
            ),
          ],
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
    final messenger = ScaffoldMessenger.of(context);
    final entry = await showSetLogSheet(
      context,
      title: l10n.trainingLogSetTitle(exercise.completedRoundsToday + 1),
      initialReps: firstNumber(exercise.reps),
      initialWeight: _plannedWeight(exercise),
    );
    if (entry == null) return;
    try {
      final result = await ref
          .read(trainingApiProvider)
          .completeRound(planId, exercise.id, reps: entry.reps, weight: entry.weight);
      ref.invalidate(trainingPlanDetailProvider(planId));
      ref.invalidate(trainingWeeklySummaryProvider(planId));
      messenger.showSnackBar(
        SnackBar(content: Text(result.sessionCompleted ? l10n.trainingSessionDone : l10n.trainingRoundCompleted)),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  /// The weight to start the next set at: this week's target for THAT set
  /// (the programme's climb applied), else the last set's weight, else the
  /// flat prescription.
  double? _plannedWeight(PlanExercise exercise) {
    final targets = exercise.currentTargets;
    final next = exercise.completedRoundsToday;
    if (targets.isNotEmpty) return next < targets.length ? targets[next] : targets.last;
    return exercise.todayRounds.isNotEmpty ? exercise.todayRounds.last.weight : exercise.targetWeight;
  }

  /// Correct the reps/weight of a set already confirmed today.
  Future<void> _editSet(BuildContext context, WidgetRef ref, PlanExercise exercise, LoggedSet set) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final entry = await showSetLogSheet(
      context,
      title: l10n.trainingLogSetTitle(set.roundNumber),
      initialReps: set.reps,
      initialWeight: set.weight,
      allowSkip: false,
    );
    if (entry == null) return;
    try {
      await ref.read(trainingApiProvider).updateRound(planId, exercise.id, set.id, reps: entry.reps, weight: entry.weight);
      ref.invalidate(trainingPlanDetailProvider(planId));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
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

    // «Push» / «Pull» / «Legs» for a day, when the trainer named it.
    String dayTitle(int day) {
      final label = byDay[day]!.map((e) => e.dayLabel).firstWhere((l) => l != null && l.isNotEmpty, orElse: () => null);
      return label == null ? _weekdayName(l10n, day) : '${_weekdayName(l10n, day)} · $label';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (plan.weekNumber != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Chip(
              avatar: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(
                plan.totalWeeks != null
                    ? l10n.trainingWeekOf(plan.weekNumber! > plan.totalWeeks! ? plan.totalWeeks! : plan.weekNumber!, plan.totalWeeks!)
                    : l10n.trainingWeekNumber(plan.weekNumber!),
              ),
            ),
          ),
        for (final day in dayKeys) ...[
          if (day != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(dayTitle(day), style: Theme.of(context).textTheme.titleSmall),
            ),
          for (final e in byDay[day]!) ...[
            _ExerciseCard(
              exercise: e,
              onCompleteRound: () => _completeRound(context, ref, e),
              onEditSet: (set) => _editSet(context, ref, e, set),
            ),
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
  final ValueChanged<LoggedSet> onEditSet;
  const _ExerciseCard({required this.exercise, required this.onCompleteRound, required this.onEditSet});

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
                if (exercise.currentTargets.isEmpty && exercise.targetWeight != null)
                  Text('${l10n.trainingWeightLabel}: ${formatWeight(exercise.targetWeight)} ${l10n.trainingKgUnit}'),
                if (exercise.restSeconds != null)
                  Text('${l10n.trainingRestLabel}: ${exercise.restSeconds}s'),
              ],
            ),
            if (exercise.currentTargets.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l10n.trainingWeightsThisWeek(formatWeightList(exercise.currentTargets)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (exercise.nextTargets.isNotEmpty)
                Text(
                  l10n.trainingWeightsNextWeek(formatWeightList(exercise.nextTargets)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                ),
            ],
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(exercise.notes!, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (exercise.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: MouseWheelHorizontalScroll(
                  builder: (context, controller) => ListView.separated(
                    controller: controller,
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
              ),
            ],
            if (exercise.images.isEmpty && exercise.libraryImageUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: exercise.libraryImageUrls.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => Dialog(
                        child: InteractiveViewer(child: Image.network(exercise.libraryImageUrls[index])),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        exercise.libraryImageUrls[index],
                        width: 144,
                        height: 96,
                        fit: BoxFit.cover,
                        cacheWidth: 432,
                        errorBuilder: (_, _, _) => const SizedBox(width: 144, height: 96),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (exercise.todayRounds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final set in exercise.todayRounds)
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      label: Text('${set.roundNumber}: ${set.label}'),
                      onPressed: () => onEditSet(set),
                    ),
                ],
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
                    child: MouseWheelHorizontalScroll(
                      builder: (context, controller) => ListView.separated(
                        controller: controller,
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
