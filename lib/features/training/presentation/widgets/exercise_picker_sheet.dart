import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_training_providers.dart';
import '../../data/models/exercise_library.dart';

/// Opens the exercise catalogue and returns the exercise the trainer picked,
/// or null when they dismissed it. Filtering is local: section chips, then
/// kind / equipment chips, then a name search.
Future<LibraryExercise?> pickLibraryExercise(BuildContext context) {
  return showModalBottomSheet<LibraryExercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _ExercisePickerSheet(),
  );
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet();

  @override
  ConsumerState<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  String _query = '';
  int? _sectionId;
  String? _kind;
  String? _equipment;

  bool _matches(LibraryExercise e) {
    if (_sectionId != null && e.categoryId != _sectionId) return false;
    if (_kind != null && e.kind != _kind) return false;
    if (_equipment != null && e.equipment != _equipment) return false;
    final q = _query.trim().toLowerCase();
    return q.isEmpty || e.name.toLowerCase().contains(q);
  }

  Widget _chips<T>({
    required String allLabel,
    required T? selected,
    required List<(T, String)> options,
    required ValueChanged<T?> onSelected,
  }) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(allLabel),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final (value, label) in options)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final library = ref.watch(exerciseLibraryProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: library.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(exerciseLibraryProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (lib) {
          final results = lib.exercises.where(_matches).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: l10n.trainingLibrarySearch,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              _chips<int>(
                allLabel: l10n.trainingLibraryAll,
                selected: _sectionId,
                options: [for (final s in lib.sections) (s.id, s.name)],
                onSelected: (v) => setState(() => _sectionId = v),
              ),
              const SizedBox(height: 4),
              _chips<String>(
                allLabel: l10n.trainingLibraryAll,
                selected: _kind,
                options: [for (final k in lib.kinds) (k.key, k.label)],
                onSelected: (v) => setState(() => _kind = v),
              ),
              const SizedBox(height: 4),
              _chips<String>(
                allLabel: l10n.trainingLibraryAll,
                selected: _equipment,
                options: [for (final e in lib.equipment) (e.key, e.label)],
                onSelected: (v) => setState(() => _equipment = v),
              ),
              const Divider(height: 16),
              Expanded(
                child: results.isEmpty
                    ? Center(child: Text(l10n.trainingLibraryEmpty))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final e = results[i];
                          final parts = [
                            lib.sectionName(e.categoryId),
                            lib.equipmentLabel(e.equipment),
                            if (e.defaultSets != null && e.defaultReps != null) '${e.defaultSets} × ${e.defaultReps}',
                          ].whereType<String>().join(' · ');
                          return ListTile(
                            leading: e.imageUrls.isEmpty
                                ? const SizedBox(width: 56, height: 40, child: Icon(Icons.fitness_center, size: 20))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      e.imageUrls.first,
                                      width: 56,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      cacheWidth: 168,
                                      errorBuilder: (_, _, _) => const SizedBox(width: 56, height: 40),
                                    ),
                                  ),
                            title: Text(e.name),
                            subtitle: Text(parts, style: theme.textTheme.bodySmall),
                            onTap: () => Navigator.of(context).pop(e),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
