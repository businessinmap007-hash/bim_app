import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/async_value_view.dart';
import '../../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../../discovery/application/discovery_providers.dart';
import '../../../application/categories_providers.dart';
import '../../../data/models/category_root.dart';
import '../../../data/models/specialty.dart';
import '../../category_icon_mapping.dart';
import '../category_root_chips_row.dart';
import '../recommended_businesses_list.dart';
import '../service_type_chips_row.dart';

/// Layout ج (Yelp-inspired): root categories as a persistent bar; tapping
/// one opens its specialties in a dropdown panel instead of navigating away
/// — see [[bim-web-layout-options]]. Picking a specialty from the panel
/// still pushes to the existing `/discovery` route (unchanged drill-down),
/// closing the panel first. A global recommended list fills the rest of the
/// screen, same presentation as layout أ's.
class BarAndMenuCategoriesLayout extends ConsumerStatefulWidget {
  const BarAndMenuCategoriesLayout({super.key});

  @override
  ConsumerState<BarAndMenuCategoriesLayout> createState() =>
      _BarAndMenuCategoriesLayoutState();
}

class _BarAndMenuCategoriesLayoutState
    extends ConsumerState<BarAndMenuCategoriesLayout> {
  int? _openCategoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final roots = ref.watch(categoryRootsProvider);
    final serviceId = ref.watch(selectedServiceTypeProvider);
    final categoryId = ref.watch(selectedCategoryRootIdProvider);

    return Column(
      children: [
        AsyncValueView<List<CategoryRoot>>(
          value: roots,
          onRetry: () => ref.invalidate(categoryRootsProvider),
          builder: (context, items) {
            if (items.isEmpty) {
              return SizedBox(
                height: 48,
                child: Center(child: Text(l10n.categoriesEmpty)),
              );
            }
            return SizedBox(
              height: 48,
              child: MouseWheelHorizontalScroll(
                builder: (context, controller) => ListView.separated(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = items[index];
                    final open = category.id == _openCategoryId;
                    return _CategoryChip(
                      category: category,
                      open: open,
                      onTap: () => setState(
                        () => _openCategoryId = open ? null : category.id,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        if (_openCategoryId != null) ...[
          const Divider(height: 1),
          _SpecialtiesPanel(
            key: ValueKey(_openCategoryId),
            categoryId: _openCategoryId!,
            onPicked: () => setState(() => _openCategoryId = null),
          ),
        ],
        const Divider(height: 1),
        const SizedBox(height: 8),
        const ServiceTypeChipsRow(),
        const CategoryRootChipsRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.categoriesRecommendedTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Expanded(child: RecommendedBusinessesList(serviceId: serviceId, categoryId: categoryId)),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryRoot category;
  final bool open;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = category.localizedName(
      Localizations.localeOf(context).languageCode,
    );

    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: open
                      ? AppColors.accentGold
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
                color: open
                    ? AppColors.accentGold
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialtiesPanel extends ConsumerWidget {
  final int categoryId;
  final VoidCallback onPicked;

  const _SpecialtiesPanel({
    super.key,
    required this.categoryId,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final specialties = ref.watch(specialtiesProvider(categoryId));

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: AsyncValueView<List<Specialty>>(
        value: specialties,
        onRetry: () => ref.invalidate(specialtiesProvider(categoryId)),
        builder: (context, items) {
          if (items.isEmpty) {
            return Text(l10n.specialtiesEmpty);
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((specialty) {
              final displayName = specialty.localizedName(
                Localizations.localeOf(context).languageCode,
              );
              return ActionChip(
                avatar: Icon(iconForCategoryChild(specialty.nameAr), size: 18),
                label: Text(displayName),
                onPressed: () {
                  onPicked();
                  context.push(
                    '/discovery',
                    extra: {'childId': specialty.id, 'title': displayName},
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
