import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/categories_providers.dart';
import 'category_root_tile.dart';

/// The root-category row — every root as one compact, horizontally
/// scrolling strip of icon+label (no cards, no grid), matching the pattern
/// picked in [[bim-web-layout-options]] over a boxed grid or tabs-with-
/// preview-rows. Used by the Categories tab (`AllCategoriesScreen`), which
/// is also the app's default landing tab (see `HomeShell`) — this row is
/// the first thing a person sees after signing in.
class CategoryRootsGrid extends ConsumerWidget {
  const CategoryRootsGrid({super.key});

  static const double _rowHeight = 96;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roots = ref.watch(categoryRootsProvider);

    return roots.when(
      // A plain AsyncValueView's error state (icon + message + button, sized
      // for a full-screen area) doesn't fit the fixed _rowHeight strip this
      // lives in — it used to overflow the moment this, the very first
      // network call after login, lost the race and came back an error. Kept
      // to that height and horizontal, matching the sibling chip rows below.
      loading: () => SizedBox(height: _rowHeight, child: const Center(child: CircularProgressIndicator())),
      error: (_, _) => SizedBox(
        height: _rowHeight,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 20, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text(l10n.commonSomethingWentWrong, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: l10n.commonRetry,
                onPressed: () => ref.invalidate(categoryRootsProvider),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return SizedBox(
            height: _rowHeight,
            child: Center(child: Text(l10n.categoriesEmpty)),
          );
        }

        return SizedBox(
          height: _rowHeight,
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = items[index];
                return CategoryRootTile(
                  category: category,
                  // Gold reads on both backgrounds; the brand-navy "ink" used
                  // for the other half is near-invisible in dark mode (same
                  // root cause as app_theme.dart's `interactive` comment), so
                  // the alternate swaps to the theme's own onSurface instead
                  // of the hardcoded navy.
                  iconColor: index.isEven
                      ? AppColors.accentGold
                      : Theme.of(context).colorScheme.onSurface,
                  onTap: () => context.push(
                    '/categories/${category.id}/specialties',
                    extra: category.localizedName(
                      Localizations.localeOf(context).languageCode,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
