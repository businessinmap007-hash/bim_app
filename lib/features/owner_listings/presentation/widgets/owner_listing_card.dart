import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/owner_listings_api.dart';
import 'owner_listing_photo.dart';

/// «للبيع / للإيجار / للتبديل».
String ownerDealLabel(AppLocalizations l10n, String deal) => switch (deal) {
  'rent' => l10n.olDealRent,
  'swap' => l10n.olDealSwap,
  _ => l10n.olDealSale,
};

/// The price in words: «640,000 جنيه» / «6,000 جنيه في الشهر» / «السعر بالاتفاق».
String ownerPriceText(AppLocalizations l10n, OwnerListing l) {
  final price = l.price;
  if (price == null || price <= 0) return l10n.olPriceOpen;

  final digits = price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  final unit = switch (l.priceUnit) {
    'day' => ' ${l10n.olPerDay}',
    'week' => ' ${l10n.olPerWeek}',
    'month' => ' ${l10n.olPerMonth}',
    _ => '',
  };

  return '$digits ${l10n.olCurrency}$unit';
}

/// One listing in a list: its photo, what it is, what it costs, where it is.
class OwnerListingCard extends StatelessWidget {
  final OwnerListing listing;
  final VoidCallback onTap;
  final Widget? footer;

  const OwnerListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OwnerListingPhoto(path: listing.cover, width: 110, height: 110),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ownerPriceText(l10n, listing),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            Text(
                              ownerDealLabel(l10n, listing.deal),
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              listing.categoryName,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (listing.place.isNotEmpty)
                          Text(listing.place, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}
