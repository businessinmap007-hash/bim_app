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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
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
              const SizedBox(height: 4),
              SizedBox(
                width: iconSize * 2.4,
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
