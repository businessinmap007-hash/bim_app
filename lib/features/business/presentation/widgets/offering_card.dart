import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/offering_item.dart';

/// One priced row on the "services" tab — a line + modifiers, already
/// labelled by the backend ("SUV — أوتوماتيك"), with a badge for whether
/// tapping it leads to booking or ordering. Tapping through to an actual
/// booking/order flow is a later module.
class OfferingCard extends StatelessWidget {
  final OfferingItem offering;
  final VoidCallback? onTap;

  const OfferingCard({super.key, required this.offering, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: offering.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: offering.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
        ),
        title: Text(offering.label, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${offering.price.toStringAsFixed(0)} ${offering.currency}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        trailing: _ActionBadge(isBookable: offering.isBookable, label: offering.isBookable ? l10n.businessActionBook : l10n.businessActionOrder),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      color: onSurface.withValues(alpha: 0.08),
      child: Icon(Icons.sell_outlined, color: onSurface),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final bool isBookable;
  final String label;
  const _ActionBadge({required this.isBookable, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = isBookable ? Theme.of(context).colorScheme.onSurface : AppColors.accentGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
