import 'package:flutter/material.dart';

import '../../../../shared/widgets/pin_badge_icon.dart';
import '../../data/models/category_root.dart';
import '../category_icon_mapping.dart';

class CategoryRootTile extends StatelessWidget {
  final CategoryRoot category;
  final VoidCallback onTap;

  const CategoryRootTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        // FittedBox instead of tuning a magic aspect ratio: whatever column
        // count or tile height the grid ends up with, the content shrinks
        // to fit rather than clipping — a two-line Arabic name in a narrow
        // cell overflowed twice (2.4px, then 7.6px) chasing exact numbers.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinBadgeIcon(icon: iconForCategory(category.nameAr), size: 38),
              const SizedBox(height: 6),
              SizedBox(
                width: 110,
                child: Text(
                  category.nameAr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
