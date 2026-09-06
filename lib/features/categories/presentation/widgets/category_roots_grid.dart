import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/categories_providers.dart';
import '../../data/models/category_root.dart';
import 'category_root_tile.dart';

/// The root-category grid — every root as one no-scroll-needed card grid,
/// tapping through to its specialties. Shared by the Home tab and the
/// Categories tab (identical content, reached two different ways) rather
/// than each screen re-implementing its own version of the same grid.
class CategoryRootsGrid extends ConsumerWidget {
  const CategoryRootsGrid({super.key});

  static const _gridPadding = 6.0;
  static const _gridSpacing = 4.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roots = ref.watch(categoryRootsProvider);

    return AsyncValueView<List<CategoryRoot>>(
      value: roots,
      onRetry: () => ref.invalidate(categoryRootsProvider),
      builder: (context, items) {
        if (items.isEmpty) {
          return Center(child: Text(l10n.categoriesEmpty));
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(categoryRootsProvider),
          child: ResponsiveCenter(
            // The whole grid — every row, all at once — sized to exactly
            // fill this screen's available height, not a fixed
            // childAspectRatio picked by eye. That's the only way "no
            // scroll needed" holds regardless of device height, and it's
            // what lets the icon grow (bigger available cell = bigger
            // icon) without re-guessing a ratio each time.
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Columns grow with width (Breakpoints.gridColumnsFor: 4
                // mobile / 6 tablet / 8 desktop) instead of a fixed 3 — on a
                // wide browser window, 3 columns forced each tile into a
                // huge, very wide-but-short rectangle, and the icon (sized
                // from tile WIDTH alone) then had to be crushed back down by
                // FittedBox to fit that short height, leaving the label
                // unreadably small despite the card itself looking oversized.
                final columns = Breakpoints.gridColumnsFor(
                  constraints.maxWidth,
                );
                final rows = (items.length / columns).ceil();
                final tileWidth =
                    (constraints.maxWidth -
                        _gridPadding * 2 -
                        _gridSpacing * (columns - 1)) /
                    columns;
                final tileHeight =
                    (constraints.maxHeight -
                        _gridPadding * 2 -
                        _gridSpacing * (rows - 1)) /
                    rows;
                final aspectRatio = tileWidth / tileHeight;
                final iconSize = tileWidth * 0.9;

                return GridView.builder(
                  padding: const EdgeInsets.all(_gridPadding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: _gridSpacing,
                    crossAxisSpacing: _gridSpacing,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final category = items[index];
                    return CategoryRootTile(
                      category: category,
                      iconSize: iconSize,
                      iconColor: index.isEven
                          ? AppColors.accentGold
                          : AppColors.primaryNavy,
                      onTap: () => context.push(
                        '/categories/${category.id}/specialties',
                        extra: category.localizedName(
                          Localizations.localeOf(context).languageCode,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
