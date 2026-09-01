import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/rating_summary.dart';

/// Stars + review count beside the open/closed badge — the same two facts
/// BusinessCard shows in a discovery-list row, expanded for the profile
/// header.
class BusinessRatingRow extends StatelessWidget {
  final RatingSummary rating;
  final bool openNow;

  const BusinessRatingRow({super.key, required this.rating, required this.openNow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        if (rating.hasReviews) ...[
          const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.starsAverage.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Text(
            '(${rating.reviewCount})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
        ] else
          Text(
            l10n.businessRatingNoReviews,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
        const SizedBox(width: 12),
        _OpenBadge(isOpenNow: openNow),
      ],
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpenNow;
  const _OpenBadge({required this.isOpenNow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = isOpenNow ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpenNow ? l10n.businessOpenNow : l10n.businessClosedNow,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
