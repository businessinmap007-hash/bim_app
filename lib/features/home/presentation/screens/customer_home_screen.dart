import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../categories/application/categories_providers.dart';
import '../../../categories/data/models/category_root.dart';
import '../../../categories/presentation/widgets/category_root_tile.dart';

/// The customer's landing screen: root categories, per
/// business-in-map-roadmap.md's own priority order (accounts first, then
/// the category/discovery directory). Tapping a category drills into its
/// specialties, then into the business list for that specialty.
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  static const _columns = 3;
  static const _gridPadding = 10.0;
  static const _gridSpacing = 6.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roots = ref.watch(categoryRootsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeCustomerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.authLogout,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView<List<CategoryRoot>>(
        value: roots,
        onRetry: () => ref.invalidate(categoryRootsProvider),
        builder: (context, items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.categoriesEmpty));
          }

          final rows = (items.length / _columns).ceil();

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
                  final tileWidth =
                      (constraints.maxWidth -
                          _gridPadding * 2 -
                          _gridSpacing * (_columns - 1)) /
                      _columns;
                  final tileHeight =
                      (constraints.maxHeight -
                          _gridPadding * 2 -
                          _gridSpacing * (rows - 1)) /
                      rows;
                  final aspectRatio = tileWidth / tileHeight;
                  final iconSize = tileWidth * 0.78;

                  return GridView.builder(
                    padding: const EdgeInsets.all(_gridPadding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _columns,
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
      ),
    );
  }
}
