import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/produce_emoji.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../data/models/menu_item_summary.dart';

/// One item card on the "menu" tab — modeled on the item-card pattern from
/// [[ux-references-doc]]'s single-vendor menu review (docs/ux-references.md
/// §1): a bigger image with a "Bestseller" badge, a starting price when the
/// item has more than one size, and a contextual trailing action (a plain
/// add glyph for a fixed-price item vs. a "view options" chevron for one
/// that needs a choice first) instead of one generic tap target.
class MenuItemTile extends StatelessWidget {
  final MenuItemSummary item;
  final VoidCallback? onTap;

  const MenuItemTile({super.key, required this.item, this.onTap});

  /// See MenuItemGridCard's identical getter — only a goods item (sold under
  /// a vocabulary branch) gets a produce emoji.
  String? get _placeholderEmoji {
    final branch = item.lineOption;
    return branch == null ? null : produceEmoji(branch.nameEn);
  }

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
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => _ImagePlaceholder(emoji: _placeholderEmoji),
                              )
                            : _ImagePlaceholder(emoji: _placeholderEmoji),
                      ),
                    ),
                    if (item.isFeatured)
                      PositionedDirectional(
                        top: 6,
                        start: 6,
                        child: _BestsellerBadge(label: l10n.menuCardBestseller),
                      ),
                    if (item.imageUrls.length > 1)
                      PositionedDirectional(
                        bottom: -4,
                        end: -4,
                        child: _PhotoCountBadge(
                          count: item.imageUrls.length,
                          onTap: () => FullScreenGallery.show(context, urls: item.imageUrls),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                      if ((item.offeringLabel ?? item.description).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.offeringLabel ?? item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _priceLabel(item, l10n),
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (item.isOutOfStock)
                            Text(l10n.businessOutOfStock, style: TextStyle(fontSize: 10, color: theme.colorScheme.error))
                          else
                            _ContextAction(hasChoices: item.hasChoices, label: l10n.menuCardViewOptions),
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

  String _priceLabel(MenuItemSummary item, AppLocalizations l10n) {
    final unit = item.saleUnitLabel;
    final startingPrice = item.startingPrice;
    if (startingPrice != null) {
      return l10n.menuCardPriceFrom(startingPrice.toStringAsFixed(0));
    }
    final price = item.basePrice.toStringAsFixed(0);
    return unit != null ? '$price $unit' : price;
  }
}

class _BestsellerBadge extends StatelessWidget {
  final String label;
  const _BestsellerBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentGold,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
      ),
    );
  }
}

/// A fixed-price item shows a plain add glyph (tapping the card adds it
/// straight away, no choice to make); one with variants/extras shows a
/// "view options" chevron instead, since tapping opens the picker first.
class _ContextAction extends StatelessWidget {
  final bool hasChoices;
  final String label;
  const _ContextAction({required this.hasChoices, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!hasChoices) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.accentGold.withValues(alpha: 0.15),
        child: const Icon(Icons.add, size: 18, color: AppColors.accentGold),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
        Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.primary),
      ],
    );
  }
}

/// The small "how many photos" badge on a catalog item's thumbnail — tap
/// opens the full gallery starting from the first photo.
class _PhotoCountBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _PhotoCountBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryNavy,
          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
        ),
        child: Text(
          '$count',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final String? emoji;
  const _ImagePlaceholder({this.emoji});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      alignment: Alignment.center,
      color: onSurface.withValues(alpha: 0.08),
      child: emoji != null
          ? Text(emoji!, style: const TextStyle(fontSize: 28))
          : Icon(Icons.restaurant_menu_outlined, color: onSurface),
    );
  }
}
