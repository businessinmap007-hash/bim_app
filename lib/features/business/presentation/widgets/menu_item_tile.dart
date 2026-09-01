import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/menu_item_summary.dart';

/// One item row on the "menu" tab. Variants/extras exist on [item] but a
/// price-picker + add-to-cart flow is a later module — the price shown here
/// is the base price, with a "starting from" hint when variants exist.
class MenuItemTile extends StatelessWidget {
  final MenuItemSummary item;
  final VoidCallback? onTap;

  const MenuItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final imageUrl = item.imageUrl ?? (item.imageUrls.isNotEmpty ? item.imageUrls.first : null);

    return Opacity(
      opacity: item.isOutOfStock ? 0.5 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: item.isOutOfStock ? null : onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 52,
              height: 52,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const _ImagePlaceholder(),
                    )
                  : const _ImagePlaceholder(),
            ),
          ),
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            item.offeringLabel ?? item.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _priceLabel(item),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
              ),
              if (item.isOutOfStock)
                Text(l10n.businessOutOfStock, style: TextStyle(fontSize: 10, color: theme.colorScheme.error)),
            ],
          ),
        ),
      ),
    );
  }

  String _priceLabel(MenuItemSummary item) {
    final unit = item.saleUnitLabel;
    final price = item.basePrice.toStringAsFixed(0);
    return unit != null ? '$price $unit' : price;
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      color: onSurface.withValues(alpha: 0.08),
      child: Icon(Icons.restaurant_menu_outlined, color: onSurface),
    );
  }
}
