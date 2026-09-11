import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/produce_emoji.dart';
import '../../../../shared/utils/retail_quantity_format.dart';
import '../../data/models/catalog_product_listing.dart';

/// One card on the Categories screen's "Retail" service feed — a single
/// LISTING, so it carries the seller's own name AND what they're actually
/// selling at what price, not just a bare business card. Tapping opens that
/// seller's whole retail storefront (see RetailStorefrontScreen).
class RetailListingCardTile extends StatelessWidget {
  final RetailListingCard listing;
  final VoidCallback onTap;

  const RetailListingCardTile({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outOfStock = listing.stock != null && listing.stock! <= 0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: outOfStock ? 0.6 : 1,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: listing.productImage != null
                        ? CachedNetworkImage(
                            imageUrl: listing.productImage!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _ProductPlaceholder(nameEn: listing.productNameEn),
                          )
                        : _ProductPlaceholder(nameEn: listing.productNameEn),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: listing.businessLogo != null
                                  ? CachedNetworkImage(imageUrl: listing.businessLogo!, fit: BoxFit.cover)
                                  : Container(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              listing.businessName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                            ),
                          ),
                        ],
                      ),
                      if (listing.minOrderQty != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.retailStorefrontMinQtyLabel(
                            formatRetailQty(listing.minOrderQty!, listing.unit),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 11),
                        ),
                      ],
                      if (!outOfStock && listing.stock != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.retailListingAvailableQtyBadge(
                            formatRetailQty(listing.stock!, listing.unit),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${listing.price.toStringAsFixed(0)} ${listing.currency}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentGold,
                            ),
                          ),
                          if (outOfStock)
                            Text(
                              AppLocalizations.of(context)!.businessOutOfStock,
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.error),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductPlaceholder extends StatelessWidget {
  final String? nameEn;
  const _ProductPlaceholder({this.nameEn});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      color: onSurface.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Text(produceEmoji(nameEn), style: const TextStyle(fontSize: 28)),
    );
  }
}
