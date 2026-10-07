import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_training_providers.dart';
import '../../application/training_providers.dart';
import '../../data/models/food_library.dart';
import 'library_entry_forms.dart';

/// Opens «جدول التغذية» and returns the food the specialist picked and how many servings of it, or null when they
/// dismissed it. Filtering is local: section chips, then a name search. A food the specialist added themselves can be
/// corrected or deleted from here; the shared catalogue is read-only.
Future<PickedFood?> pickLibraryFood(BuildContext context) {
  return showModalBottomSheet<PickedFood>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _FoodPickerSheet(),
  );
}

class _FoodPickerSheet extends ConsumerStatefulWidget {
  const _FoodPickerSheet();

  @override
  ConsumerState<_FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends ConsumerState<_FoodPickerSheet> {
  String _query = '';
  int? _sectionId;

  bool _matches(LibraryFood f) {
    if (_sectionId != null && f.categoryId != _sectionId) return false;
    final q = _query.trim().toLowerCase();
    return q.isEmpty || f.name.toLowerCase().contains(q);
  }

  Future<void> _pick(LibraryFood food) async {
    final servings = await showDialog<double>(context: context, builder: (_) => _ServingsDialog(food: food));
    if (servings == null || !mounted) return;
    Navigator.of(context).pop(PickedFood(food, servings));
  }

  Future<void> _add(FoodLibrary lib) async {
    final added = await editLibraryFood(context, lib: lib);
    if (added != null) ref.invalidate(foodLibraryProvider);
  }

  Future<void> _edit(FoodLibrary lib, LibraryFood food) async {
    final changed = await editLibraryFood(context, lib: lib, existing: food);
    if (changed != null) ref.invalidate(foodLibraryProvider);
  }

  Future<void> _delete(LibraryFood food) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await confirmDeleteEntry(context, l10n.trainingDeleteOwnConfirm);
    if (!ok || !mounted) return;
    try {
      await ref.read(trainingApiProvider).deleteFood(food.id);
      ref.invalidate(foodLibraryProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final library = ref.watch(foodLibraryProvider);

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
              OutlinedButton(onPressed: () => ref.invalidate(foodLibraryProvider), child: Text(l10n.commonRetry)),
            ],
          ),
        ),
        data: (lib) {
          final results = lib.foods.where(_matches).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(l10n.trainingFoodTable, style: theme.textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  decoration: InputDecoration(hintText: l10n.trainingFoodSearch, prefixIcon: const Icon(Icons.search), isDense: true),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(l10n.trainingLibraryAll),
                        selected: _sectionId == null,
                        onSelected: (_) => setState(() => _sectionId = null),
                      ),
                    ),
                    for (final s in lib.sections)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(s.name),
                          selected: _sectionId == s.id,
                          onSelected: (_) => setState(() => _sectionId = s.id),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 16),
              Expanded(
                child: results.isEmpty
                    ? Center(child: Text(l10n.trainingFoodEmpty))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final f = results[i];

                          return ListTile(
                            title: Text(f.name),
                            subtitle: Text(
                              '${f.serving} · ${l10n.trainingFoodKcal(f.calories)}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: f.mine
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Chip(label: Text(l10n.trainingMine), visualDensity: VisualDensity.compact),
                                      PopupMenuButton<String>(
                                        onSelected: (v) => v == 'edit' ? _edit(lib, f) : _delete(f),
                                        itemBuilder: (_) => [
                                          PopupMenuItem(value: 'edit', child: Text(l10n.trainingEditEntry)),
                                          PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
                                        ],
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: () => _pick(f),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(l10n.trainingFoodApprox, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _add(lib),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.trainingAddOwnFood),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// How many servings: the calories follow the stepper, so the specialist sees what the meal will weigh in.
class _ServingsDialog extends StatefulWidget {
  final LibraryFood food;
  const _ServingsDialog({required this.food});

  @override
  State<_ServingsDialog> createState() => _ServingsDialogState();
}

class _ServingsDialogState extends State<_ServingsDialog> {
  double _servings = 1;

  String _g(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final f = widget.food;

    return AlertDialog(
      title: Text(f.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f.serving, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(l10n.trainingFoodServings)),
              IconButton(
                onPressed: _servings > 0.5 ? () => setState(() => _servings -= 0.5) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              SizedBox(width: 40, child: Text(_g(_servings), textAlign: TextAlign.center, style: theme.textTheme.titleMedium)),
              IconButton(onPressed: () => setState(() => _servings += 0.5), icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.trainingFoodKcal(f.caloriesFor(_servings)),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            l10n.trainingFoodMacros(_g(f.proteinG * _servings), _g(f.carbsG * _servings), _g(f.fatG * _servings)),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _servings), child: Text(l10n.commonSave)),
      ],
    );
  }
}
