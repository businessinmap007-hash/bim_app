import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/training_providers.dart';
import '../../data/models/exercise_library.dart';
import '../../data/models/food_library.dart';

/// «مع امكانية اضافة من المتخصص لنوع غذاء او تمرين» — the forms a specialist adds or corrects THEIR OWN food or
/// exercise with. The shared catalogue is never edited from the app.
Future<bool> confirmDeleteEntry(BuildContext context, String message) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
      ],
    ),
  );

  return ok == true;
}

/// Adds (or, with [existing], corrects) one of the specialist's own foods. Returns it, or null when dismissed.
Future<LibraryFood?> editLibraryFood(BuildContext context, {required FoodLibrary lib, LibraryFood? existing}) {
  return showModalBottomSheet<LibraryFood>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _FoodForm(lib: lib, existing: existing),
  );
}

/// Adds (or corrects) one of the specialist's own exercises. Returns it, or null when dismissed.
Future<LibraryExercise?> editLibraryExercise(BuildContext context, {required ExerciseLibrary lib, LibraryExercise? existing}) {
  return showModalBottomSheet<LibraryExercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ExerciseForm(lib: lib, existing: existing),
  );
}

class _FoodForm extends ConsumerStatefulWidget {
  final FoodLibrary lib;
  final LibraryFood? existing;
  const _FoodForm({required this.lib, this.existing});

  @override
  ConsumerState<_FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends ConsumerState<_FoodForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _serving = TextEditingController(text: widget.existing?.serving);
  late final _calories = TextEditingController(text: widget.existing?.calories.toString());
  late final _protein = TextEditingController(text: _num(widget.existing?.proteinG));
  late final _carbs = TextEditingController(text: _num(widget.existing?.carbsG));
  late final _fat = TextEditingController(text: _num(widget.existing?.fatG));
  late int? _categoryId = widget.existing?.categoryId ?? (widget.lib.sections.isEmpty ? null : widget.lib.sections.first.id);
  String? _error;
  bool _saving = false;

  static String _num(double? v) => v == null || v == 0 ? '' : v.toString();

  @override
  void dispose() {
    for (final c in [_name, _serving, _calories, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _d(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final calories = int.tryParse(_calories.text.trim());
    if (_name.text.trim().isEmpty || _serving.text.trim().isEmpty || calories == null || _categoryId == null) {
      setState(() => _error = l10n.validationRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref.read(trainingApiProvider).saveFood(
        id: widget.existing?.id,
        categoryId: _categoryId!,
        name: _name.text.trim(),
        serving: _serving.text.trim(),
        calories: calories,
        proteinG: _d(_protein),
        carbsG: _d(_carbs),
        fatG: _d(_fat),
      );
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.trainingAddOwnFood, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: InputDecoration(labelText: l10n.trainingFoodSection),
              items: [for (final s in widget.lib.sections) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.trainingFoodName)),
            const SizedBox(height: 8),
            TextField(controller: _serving, decoration: InputDecoration(labelText: l10n.trainingFoodServingLabel)),
            const SizedBox(height: 8),
            TextField(
              controller: _calories,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.trainingFoodCalories),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (c, label) in [
                  (_protein, l10n.trainingFoodProtein),
                  (_carbs, l10n.trainingFoodCarbs),
                  (_fat, l10n.trainingFoodFat),
                ]) ...[
                  Expanded(
                    child: TextField(
                      controller: c,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: label),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseForm extends ConsumerStatefulWidget {
  final ExerciseLibrary lib;
  final LibraryExercise? existing;
  const _ExerciseForm({required this.lib, this.existing});

  @override
  ConsumerState<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends ConsumerState<_ExerciseForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _sets = TextEditingController(text: widget.existing?.defaultSets?.toString());
  late final _reps = TextEditingController(text: widget.existing?.defaultReps);
  late final _instructions = TextEditingController(text: widget.existing?.instructions);
  late int? _categoryId = widget.existing?.categoryId ?? (widget.lib.sections.isEmpty ? null : widget.lib.sections.first.id);
  late String? _equipment = widget.existing?.equipment;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _sets, _reps, _instructions]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty || _categoryId == null) {
      setState(() => _error = l10n.validationRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref.read(trainingApiProvider).saveLibraryExercise(
        id: widget.existing?.id,
        categoryId: _categoryId!,
        name: _name.text.trim(),
        sets: int.tryParse(_sets.text.trim()),
        reps: _reps.text.trim(),
        equipment: _equipment,
        instructions: _instructions.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.trainingAddOwnExercise, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: InputDecoration(labelText: l10n.trainingExerciseSection),
              items: [for (final s in widget.lib.sections) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.trainingExerciseName)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sets,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.trainingSets),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _reps, decoration: InputDecoration(labelText: l10n.trainingReps))),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _equipment,
              decoration: InputDecoration(labelText: l10n.trainingLibraryEquipment),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('—')),
                for (final e in widget.lib.equipment) DropdownMenuItem<String?>(value: e.key, child: Text(e.label)),
              ],
              onChanged: (v) => setState(() => _equipment = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _instructions,
              maxLines: 2,
              maxLength: 255,
              decoration: InputDecoration(labelText: l10n.trainingExerciseInstructions),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
