import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/training_templates_providers.dart';
import '../../data/models/template_item.dart';
import '../../data/models/training_template.dart';

class TrainingTemplateEditScreen extends ConsumerStatefulWidget {
  final int templateId;
  const TrainingTemplateEditScreen({super.key, required this.templateId});

  @override
  ConsumerState<TrainingTemplateEditScreen> createState() => _TrainingTemplateEditScreenState();
}

class _TrainingTemplateEditScreenState extends ConsumerState<TrainingTemplateEditScreen> {
  final _titleController = TextEditingController();
  final _goalController = TextEditingController();
  final _notesController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String? _error;

  void _seedFrom(TrainingTemplate t) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = t.title;
    _goalController.text = t.goal ?? '';
    _notesController.text = t.notes ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = l10n.validationRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(trainingTemplateEditControllerProvider(widget.templateId).notifier)
          .updateBase(
            title: _titleController.text.trim(),
            goal: _goalController.text.trim(),
            notes: _notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSave)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(trainingTemplateEditControllerProvider(widget.templateId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingTemplateEditTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.read(trainingTemplateEditControllerProvider(widget.templateId).notifier).load(),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (template) {
          _seedFrom(template);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.trainingTemplateTitleHint),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _goalController,
                decoration: InputDecoration(labelText: l10n.trainingTemplateGoalHint),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.trainingTemplateNotesHint),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonSave),
              ),
              const SizedBox(height: 24),
              _ExercisesSection(template: template),
              const SizedBox(height: 24),
              _MealsSection(template: template),
            ],
          );
        },
      ),
    );
  }
}

const _dayLabelsFallback = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

String _dayLabel(AppLocalizations l10n, int day) => switch (day) {
  0 => l10n.clinicWeekday0,
  1 => l10n.clinicWeekday1,
  2 => l10n.clinicWeekday2,
  3 => l10n.clinicWeekday3,
  4 => l10n.clinicWeekday4,
  5 => l10n.clinicWeekday5,
  6 => l10n.clinicWeekday6,
  _ => _dayLabelsFallback[day % 7],
};

class _ExercisesSection extends ConsumerWidget {
  final TrainingTemplate template;
  const _ExercisesSection({required this.template});

  Future<void> _openForm(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final restController = TextEditingController();
    int? day;
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.trainingTemplateAddExercise, style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.trainingExerciseNameHint),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: day,
                    decoration: InputDecoration(labelText: l10n.trainingExerciseDayHint),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.trainingExerciseDayAny)),
                      for (var i = 0; i < 7; i++) DropdownMenuItem(value: i, child: Text(_dayLabel(l10n, i))),
                    ],
                    onChanged: (v) => setSheetState(() => day = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.trainingExerciseSetsHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: repsController,
                    decoration: InputDecoration(labelText: l10n.trainingExerciseRepsHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: restController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.trainingExerciseRestHint),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.validationRequired);
                        return;
                      }
                      try {
                        await ref
                            .read(trainingTemplateEditControllerProvider(template.id).notifier)
                            .addExercise(
                              dayOfWeek: day,
                              name: nameController.text.trim(),
                              sets: int.tryParse(setsController.text.trim()),
                              reps: repsController.text.trim(),
                              restSeconds: int.tryParse(restController.text.trim()),
                            );
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      } catch (e) {
                        setSheetState(() => error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
                      }
                    },
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TemplateExercise exercise) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.trainingRemoveRowConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(trainingTemplateEditControllerProvider(template.id).notifier).removeExercise(exercise.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.trainingTemplateExercisesSection, style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.trainingTemplateAddExercise),
            ),
          ],
        ),
        for (final e in template.exercises)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              title: Text(e.name),
              subtitle: Text(
                [
                  if (e.dayOfWeek != null) _dayLabel(l10n, e.dayOfWeek!),
                  if (e.sets != null) '${e.sets}×${e.reps ?? ''}',
                ].join(' · '),
              ),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, e)),
            ),
          ),
      ],
    );
  }
}

const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

class _MealsSection extends ConsumerWidget {
  final TrainingTemplate template;
  const _MealsSection({required this.template});

  String _mealTypeLabel(String type, AppLocalizations l10n) => switch (type) {
    'breakfast' => l10n.mealBreakfast,
    'lunch' => l10n.mealLunch,
    'dinner' => l10n.mealDinner,
    'snack' => l10n.mealSnack,
    _ => type,
  };

  Future<void> _openForm(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    String mealType = 'breakfast';
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.trainingTemplateAddMeal, style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: mealType,
                    decoration: InputDecoration(labelText: l10n.trainingMealTypeLabel),
                    items: [
                      for (final t in _mealTypes) DropdownMenuItem(value: t, child: Text(_mealTypeLabel(t, l10n))),
                    ],
                    onChanged: (v) => setSheetState(() => mealType = v ?? mealType),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.trainingMealNameHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.trainingMealCaloriesHint),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.validationRequired);
                        return;
                      }
                      try {
                        await ref
                            .read(trainingTemplateEditControllerProvider(template.id).notifier)
                            .addMeal(
                              mealType: mealType,
                              name: nameController.text.trim(),
                              calories: int.tryParse(caloriesController.text.trim()),
                            );
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      } catch (e) {
                        setSheetState(() => error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
                      }
                    },
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TemplateMeal meal) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.trainingRemoveRowConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(trainingTemplateEditControllerProvider(template.id).notifier).removeMeal(meal.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.trainingTemplateMealsSection, style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.trainingTemplateAddMeal),
            ),
          ],
        ),
        for (final m in template.meals)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              title: Text(m.name),
              subtitle: Text(
                [
                  _mealTypeLabel(m.mealType, l10n),
                  if (m.calories != null) '${m.calories} kcal',
                ].join(' · '),
              ),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, m)),
            ),
          ),
      ],
    );
  }
}
