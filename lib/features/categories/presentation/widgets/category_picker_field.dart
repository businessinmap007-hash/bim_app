import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/categories_providers.dart';
import '../../data/models/category_root.dart';
import '../../data/models/specialty.dart';

/// A picked leaf category — `childId` is exactly what the backend calls
/// `category_child_id` (registration) / `child_id` (discovery).
class CategorySelection {
  final int childId;
  final String label;
  const CategorySelection({required this.childId, required this.label});
}

/// A tap-to-pick field for a taxonomy specialty (root -> specialty), used
/// wherever a category id is collected — business registration today,
/// category-based search/filtering later. Never a free-text/numeric field:
/// the id space isn't something a user should type from memory.
class CategoryPickerField extends StatelessWidget {
  final CategorySelection? value;
  final ValueChanged<CategorySelection> onChanged;
  final String? errorText;

  const CategoryPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final selection = await showModalBottomSheet<CategorySelection>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const _CategoryPickerSheet(),
        );
        if (selection != null) onChanged(selection);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.categoryPickerFieldLabel,
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value?.label ?? l10n.categoryPickerChooseHint,
          style: value == null ? TextStyle(color: Theme.of(context).hintColor) : null,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet();

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  CategoryRoot? _selectedRoot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final selectedRoot = _selectedRoot;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    if (selectedRoot != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => _selectedRoot = null),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        selectedRoot == null
                            ? l10n.categoryPickerChooseRoot
                            : selectedRoot.localizedName(languageCode),
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: selectedRoot == null
                    ? _RootList(
                        scrollController: scrollController,
                        onSelected: (root) => setState(() => _selectedRoot = root),
                      )
                    : _SpecialtyList(
                        scrollController: scrollController,
                        categoryId: selectedRoot.id,
                        onSelected: (specialty) => Navigator.of(context).pop(
                          CategorySelection(
                            childId: specialty.id,
                            label: specialty.localizedName(languageCode),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RootList extends ConsumerWidget {
  final ScrollController scrollController;
  final ValueChanged<CategoryRoot> onSelected;

  const _RootList({required this.scrollController, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roots = ref.watch(categoryRootsProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    return roots.when(
      data: (items) => ListView.separated(
        controller: scrollController,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final root = items[index];
          return ListTile(
            title: Text(root.localizedName(languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSelected(root),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.commonSomethingWentWrong)),
    );
  }
}

class _SpecialtyList extends ConsumerWidget {
  final ScrollController scrollController;
  final int categoryId;
  final ValueChanged<Specialty> onSelected;

  const _SpecialtyList({
    required this.scrollController,
    required this.categoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final specialties = ref.watch(specialtiesProvider(categoryId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return specialties.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(l10n.specialtiesEmpty));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final specialty = items[index];
            return ListTile(
              title: Text(specialty.localizedName(languageCode)),
              onTap: () => onSelected(specialty),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.commonSomethingWentWrong)),
    );
  }
}
