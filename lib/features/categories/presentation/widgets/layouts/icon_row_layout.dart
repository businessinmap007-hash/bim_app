import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../category_roots_grid.dart';
import '../recommended_businesses_list.dart';

/// Layout أ (Fiverr-inspired): the compact category icon row, plus a
/// rating-ranked "recommended for you" list underneath — see
/// [[bim-web-layout-options]]. The default of the 3 selectable Categories
/// layouts (`CategoriesLayoutStyle.iconRow`).
class IconRowCategoriesLayout extends StatelessWidget {
  const IconRowCategoriesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 96, child: CategoryRootsGrid()),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.categoriesRecommendedTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        const Expanded(child: RecommendedBusinessesList()),
      ],
    );
  }
}
