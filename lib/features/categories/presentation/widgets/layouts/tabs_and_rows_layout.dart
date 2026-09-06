import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/async_value_view.dart';
import '../../../../discovery/application/discovery_providers.dart';
import '../../../../discovery/data/models/business_summary.dart';
import '../../../../discovery/presentation/widgets/business_card.dart';
import '../../../application/categories_providers.dart';
import '../../category_icon_mapping.dart';
import '../../../data/models/category_root.dart';

/// Layout ب (Airbnb-inspired): root categories as fixed tabs; the active
/// tab's top-rated businesses show as a horizontally-scrolling row
/// underneath instead of navigating away — see [[bim-web-layout-options]].
///
/// Only ONE row ("الأعلى تقييمًا") is built, not the two the original
/// mockup showed ("top rated" + "near you") — there is no distance/location
/// data on a business summary to build a real "near you" row from, and a
/// second row with fabricated data would be worse than one honest row.
class TabsAndRowsCategoriesLayout extends ConsumerStatefulWidget {
  const TabsAndRowsCategoriesLayout({super.key});

  @override
  ConsumerState<TabsAndRowsCategoriesLayout> createState() =>
      _TabsAndRowsCategoriesLayoutState();
}

class _TabsAndRowsCategoriesLayoutState
    extends ConsumerState<TabsAndRowsCategoriesLayout> {
  int? _activeCategoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final roots = ref.watch(categoryRootsProvider);

    return AsyncValueView<List<CategoryRoot>>(
      value: roots,
      onRetry: () => ref.invalidate(categoryRootsProvider),
      builder: (context, items) {
        if (items.isEmpty) {
          return Center(child: Text(l10n.categoriesEmpty));
        }

        final activeId = _activeCategoryId ?? items.first.id;

        return Column(
          children: [
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final category = items[index];
                  return _CategoryTab(
                    category: category,
                    active: category.id == activeId,
                    onTap: () =>
                        setState(() => _activeCategoryId = category.id),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.categoriesTopRatedTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // A KEYED subtree per category: without it, Flutter would
                    // reuse the same _TopRatedRow element across tab switches
                    // and its internal `ref.watch` would resolve against
                    // whichever categoryId that element was FIRST built
                    // with — the row would never actually refresh.
                    _TopRatedRow(key: ValueKey(activeId), categoryId: activeId),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final CategoryRoot category;
  final bool active;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.category,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = category.localizedName(
      Localizations.localeOf(context).languageCode,
    );
    final color = active
        ? AppColors.accentGold
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.accentGold : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconForCategory(category.nameAr), color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopRatedRow extends ConsumerWidget {
  final int categoryId;
  const _TopRatedRow({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(recommendedBusinessesProvider(categoryId));

    return AsyncValueView<List<BusinessSummary>>(
      value: items,
      onRetry: () => ref.invalidate(recommendedBusinessesProvider(categoryId)),
      builder: (context, list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text(l10n.categoriesRecommendedEmpty),
          );
        }
        return SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final business = list[index];
              return SizedBox(
                width: 240,
                child: BusinessCard(
                  business: business,
                  onTap: () => context.push('/business/${business.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
