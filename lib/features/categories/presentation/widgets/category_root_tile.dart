import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/category_root.dart';
import '../category_icon_mapping.dart';

/// One category in the compact icon row — a tinted circle + a label
/// underneath, no card/border/shadow. Deliberately lighter than the old
/// boxed-grid tile: a horizontal strip of these reads as a single unit, not
/// as a stack of separate cards, matching the "one row, no boxes" pattern
/// picked over the boxed-grid and the tabs+preview-rows alternatives (see
/// [[bim-web-layout-options]]).
class CategoryRootTile extends StatelessWidget {
  final CategoryRoot category;
  final VoidCallback onTap;
  final Color iconColor;

  const CategoryRootTile({
    super.key,
    required this.category,
    required this.onTap,
    this.iconColor = AppColors.accentGold,
  });

  static const double _circleSize = 56;
  static const double _itemWidth = 76;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final displayName = category.localizedName(languageCode);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_circleSize),
      child: SizedBox(
        width: _itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.14),
              ),
              child: Icon(
                iconForCategory(category.nameAr),
                color: iconColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
