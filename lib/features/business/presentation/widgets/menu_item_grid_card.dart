import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../data/models/menu_item_summary.dart';

/// One item's card in the menu's grid display mode — a square photo up
/// front, then name/price, two per row. See MenuItemTile for the list-mode
/// counterpart this mirrors (same badges, same tap targets).
class MenuItemGridCard extends StatelessWidget {
  final MenuItemSummary item;
  final VoidCallback? onTap;
  const MenuItemGridCard({super.key, required this.item, this.onTap});

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
        child: InkWell(
          onTap: item.isOutOfStock ? null : onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const _ImagePlaceholder(),
                            )
                          : const _ImagePlaceholder(),
                    ),
                    if (item.isFeatured)
                      PositionedDirectional(
                        top: 6,
                        start: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            l10n.menuCardBestseller,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                          ),
                        ),
                      ),
                    if (item.imageUrls.length > 1)
                      PositionedDirectional(
                        bottom: 6,
                        end: 6,
                        child: InkWell(
                          onTap: () => FullScreenGallery.show(context, urls: item.imageUrls),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                            child: Text(
                              '${item.imageUrls.length}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                    if (item.availableQuantity != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.businessMenuAvailableQuantity(item.availableQuantity!),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (item.isOutOfStock)
                      Text(l10n.businessOutOfStock, style: TextStyle(fontSize: 11, color: theme.colorScheme.error))
                    else
                      Text(_priceLabel(item), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.accentGold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _priceLabel(MenuItemSummary item) {
    final unit = item.saleUnitLabel;
    final startingPrice = item.startingPrice;
    final price = (startingPrice ?? item.basePrice).toStringAsFixed(0);
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
