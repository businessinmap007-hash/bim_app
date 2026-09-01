import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/category_root.dart';
import '../category_icon_mapping.dart';

class CategoryRootTile extends StatelessWidget {
  final CategoryRoot category;
  final VoidCallback onTap;
  final double iconSize;
  final Color iconColor;

  const CategoryRootTile({
    super.key,
    required this.category,
    required this.onTap,
    required this.iconSize,
    this.iconColor = AppColors.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final displayName = category.localizedName(languageCode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        // Always the light-theme card look, in both app themes — a
        // deliberate fixed choice (not colorScheme.surface) since the icons
        // are drawn for a light backdrop and read as "floating" on a dark
        // one with nothing behind them.
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        // FittedBox is a safety net, not the sizing mechanism — iconSize is
        // computed from the actual column width so the icon itself reads as
        // sized "for the screen", not squeezed to fit as a last resort.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconForCategory(category.nameAr),
                color: iconColor,
                size: iconSize,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: iconSize * 2.4,
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // A fixed dark color, not a theme-derived one — the card
                  // is always light now, so a theme's own (light, in dark
                  // mode) text color would be unreadable on it.
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
