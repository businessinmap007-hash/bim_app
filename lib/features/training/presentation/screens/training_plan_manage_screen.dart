import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_training_providers.dart';
import '../../data/models/body_report.dart';

const _statuses = ['active', 'paused', 'completed', 'cancelled'];
const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  'active' => l10n.trainingPlanStatusActive,
  'paused' => l10n.trainingPlanStatusPaused,
  'completed' => l10n.trainingPlanStatusCompleted,
  'cancelled' => l10n.trainingPlanStatusCancelled,
  _ => status,
};

String _mealTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  'breakfast' => l10n.mealTypeBreakfast,
  'lunch' => l10n.mealTypeLunch,
  'dinner' => l10n.mealTypeDinner,
  'snack' => l10n.mealTypeSnack,
  _ => type,
};

/// Api\V2\TrainingPlanController — a trainer manages one client's plan:
/// exercises, meals, status, and monthly body-composition readings. Chat and
/// weekly-adherence summaries aren't wired up here — a deliberate first-slice
/// cut, not a missing capability the backend lacks.
class TrainingPlanManageScreen extends ConsumerStatefulWidget {
  final int planId;
  const TrainingPlanManageScreen({super.key, required this.planId});

  @override
  ConsumerState<TrainingPlanManageScreen> createState() => _TrainingPlanManageScreenState();
}

class _TrainingPlanManageScreenState extends ConsumerState<TrainingPlanManageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trainingPlanManageControllerProvider(widget.planId).notifier).loadBodyReports());
  }

  Future<void> _changeStatus(String status) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(trainingPlanManageControllerProvider(widget.planId).notifier).setStatus(status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _addExercise() async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    int? dayOfWeek;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.trainingAddExercise, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.trainingExerciseName)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  initialValue: dayOfWeek,
                  decoration: InputDecoration(labelText: l10n.tripScheduleDayLabel),
                  items: [
                    DropdownMenuItem<int?>(value: null, child: Text(l10n.trainingAnyDay)),
                    for (var d = 0; d < 7; d++)
                      DropdownMenuItem<int?>(value: d, child: Text(_dayLabel(l10n, d))),
                  ],
                  onChanged: (v) => setSheetState(() => dayOfWeek = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.trainingSets),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: repsCtrl,
                        decoration: InputDecoration(labelText: l10n.trainingReps, hintText: '10-12'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(l10n.commonSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || nameCtrl.text.trim().isEmpty || !mounted) return;
    try {
      await ref
          .read(trainingPlanManageControllerProvider(widget.planId).notifier)
          .addExercise(
            name: nameCtrl.text.trim(),
            dayOfWeek: dayOfWeek,
            sets: int.tryParse(setsCtrl.text.trim()),
            reps: repsCtrl.text.trim().isEmpty ? null : repsCtrl.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _addMeal() async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();
    String mealType = 'breakfast';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.trainingAddMeal, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final type in _mealTypes)
                      ChoiceChip(
                        label: Text(_mealTypeLabel(l10n, type)),
                        selected: mealType == type,
                        onSelected: (_) => setSheetState(() => mealType = type),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.trainingMealName)),
                const SizedBox(height: 8),
                TextField(
                  controller: caloriesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.trainingCalories),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(l10n.commonSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || nameCtrl.text.trim().isEmpty || !mounted) return;
    try {
      await ref
          .read(trainingPlanManageControllerProvider(widget.planId).notifier)
          .addMeal(
            mealType: mealType,
            name: nameCtrl.text.trim(),
            calories: int.tryParse(caloriesCtrl.text.trim()),
          );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _addBodyReport() async {
    final l10n = AppLocalizations.of(context)!;
    final weightCtrl = TextEditingController();
    final muscleCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final waterCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.trainingAddBodyReport, style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.trainingBodyReportHint, style: Theme.of(sheetContext).textTheme.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.trainingWeightKg),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: muscleCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.trainingMuscleKg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.trainingFatPercent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: waterCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.trainingWaterPercent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(trainingPlanManageControllerProvider(widget.planId).notifier)
          .addBodyReport(
            weightKg: double.tryParse(weightCtrl.text.trim()),
            muscleMassKg: double.tryParse(muscleCtrl.text.trim()),
            fatPercent: double.tryParse(fatCtrl.text.trim()),
            waterPercent: double.tryParse(waterCtrl.text.trim()),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  String _dayLabel(AppLocalizations l10n, int day) => switch (day) {
    0 => l10n.weekdaySunday,
    1 => l10n.weekdayMonday,
    2 => l10n.weekdayTuesday,
    3 => l10n.weekdayWednesday,
    4 => l10n.weekdayThursday,
    5 => l10n.weekdayFriday,
    _ => l10n.weekdaySaturday,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(trainingPlanManageControllerProvider(widget.planId));
    final plan = state.plan;

    return Scaffold(
      appBar: AppBar(title: Text(plan?.title ?? l10n.trainingPlansTitle)),
      body: state.isLoading && plan == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && plan == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(trainingPlanManageControllerProvider(widget.planId).notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : plan == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(plan.clientName ?? '', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final status in _statuses)
                      ChoiceChip(
                        label: Text(_statusLabel(l10n, status)),
                        selected: plan.status == status,
                        onSelected: (_) => _changeStatus(status),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.trainingExercisesSection, style: Theme.of(context).textTheme.titleSmall),
                    ),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addExercise),
                  ],
                ),
                if ((plan.exercises ?? []).isEmpty) Text(l10n.trainingExercisesEmpty),
                for (final exercise in plan.exercises ?? [])
                  Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      title: Text(exercise.name),
                      subtitle: Text(
                        [
                          if (exercise.dayOfWeek != null) _dayLabel(l10n, exercise.dayOfWeek!),
                          if (exercise.sets != null) '${exercise.sets} × ${exercise.reps ?? '-'}',
                        ].join(' · '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(trainingPlanManageControllerProvider(widget.planId).notifier)
                            .removeExercise(exercise.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.trainingMealsSection, style: Theme.of(context).textTheme.titleSmall),
                    ),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addMeal),
                  ],
                ),
                if ((plan.meals ?? []).isEmpty) Text(l10n.trainingMealsEmpty),
                for (final meal in plan.meals ?? [])
                  Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      title: Text(meal.name),
                      subtitle: Text(
                        '${_mealTypeLabel(l10n, meal.mealType)}${meal.calories != null ? ' · ${meal.calories} kcal' : ''}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(trainingPlanManageControllerProvider(widget.planId).notifier)
                            .removeMeal(meal.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.trainingBodyReportsSection, style: Theme.of(context).textTheme.titleSmall),
                    ),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addBodyReport),
                  ],
                ),
                if (state.isLoadingReports) const Center(child: CircularProgressIndicator()),
                if (!state.isLoadingReports && state.bodyReports.isEmpty) Text(l10n.trainingBodyReportsEmpty),
                for (final report in state.bodyReports)
                  Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      title: Text(report.forMonth ?? '—'),
                      subtitle: Text(_reportSummary(report)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(trainingPlanManageControllerProvider(widget.planId).notifier)
                            .deleteBodyReport(report.id),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _reportSummary(BodyReport r) {
    final parts = <String>[];
    if (r.weightKg != null) parts.add('${r.weightKg} kg');
    if (r.fatPercent != null) parts.add('${r.fatPercent}% fat');
    if (r.muscleMassKg != null) parts.add('${r.muscleMassKg} kg muscle');
    return parts.join(' · ');
  }
}
