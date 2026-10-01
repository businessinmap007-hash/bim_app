import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/produce_emoji.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../data/models/menu_item_summary.dart';
import 'menu_card_stepper.dart';

/// One item's card in the menu's grid display mode — a square photo up
/// front, then name/price, two-or-three per row. See [MenuItemTile] for the
/// list-mode counterpart this mirrors (same badges, same tap targets, and —
/// for a goods item sold by a measured unit — the SAME +/- stepper and
/// "أضف" button via [onDirectAdd], not just a plain price label). «زيادة
/// الكمية من الكارت يجب ان يكون نفس المكونات قائمة او كارت» — المالك،
/// 2026-09-29: switching to grid mode used to drop the add-to-cart stepper
/// entirely (this card had no [onDirectAdd] at all), so a goods item could
/// only be added through the sheet, not straight from the card like list
/// mode already allowed.
class MenuItemGridCard extends StatefulWidget {
  final MenuItemSummary item;
  final VoidCallback? onTap;
  final Future<void> Function(int qty)? onDirectAdd;
  const MenuItemGridCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDirectAdd,
  });

  bool get _offersStepper =>
      onDirectAdd != null && !item.hasChoices && item.saleUnitLabel != null;

  @override
  State<MenuItemGridCard> createState() => _MenuItemGridCardState();
}

class _MenuItemGridCardState extends State<MenuItemGridCard> {
  int _qty = 1;
  bool _adding = false;

  MenuItemSummary get item => widget.item;

  void _inc() => setState(() => _qty++);

  /// See MenuItemTile's identical method for why this stays clamped at 1.
  void _dec() {
    if (_qty <= 1) return;
    setState(() => _qty--);
  }

  Future<void> _add() async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await widget.onDirectAdd!(_qty);
      if (mounted) setState(() => _qty = 1);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  /// See MenuItemTile's identical getter — only a goods item (sold under a
  /// vocabulary branch) gets a produce emoji.
  String? get _placeholderEmoji {
    final branch = item.lineOption;
    return branch == null ? null : produceEmoji(branch.nameEn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final imageUrl =
        item.imageUrl ??
        (item.imageUrls.isNotEmpty ? item.imageUrls.first : null);
    final offersStepper = widget._offersStepper;

    return Opacity(
      opacity: item.isOutOfStock ? 0.5 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // The stepper row below is its own tap targets; the card itself
          // has nothing left to open for a quick-add item — same rule
          // MenuItemTile's list mode already follows.
          onTap: item.isOutOfStock || offersStepper ? null : widget.onTap,
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
                              errorWidget: (context, url, error) =>
                                  _ImagePlaceholder(emoji: _placeholderEmoji),
                            )
                          : _ImagePlaceholder(emoji: _placeholderEmoji),
                    ),
                    if (item.isFeatured)
                      PositionedDirectional(
                        top: 6,
                        start: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.menuCardBestseller,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                    if (item.imageUrls.length > 1)
                      PositionedDirectional(
                        bottom: 6,
                        end: 6,
                        child: InkWell(
                          onTap: () => FullScreenGallery.show(
                            context,
                            urls: item.imageUrls,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: Text(
                              '${item.imageUrls.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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
                    // «ارفع السعر ليكون على نفس سطر الصنف فى عرض الشبكة فى
                    // شاشة العميل» — المالك، 2026-09-29: for a goods item
                    // (stepper offered), the price sits on the name's own
                    // line instead of its own row below — same pattern
                    // MenuItemTile's list mode already uses. Also what
                    // fixed a real overflow: the extra stepper row this
                    // card gained needed the vertical room this line frees
                    // up.
                    if (offersStepper)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _priceLabel(item, l10n),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    if (item.brandName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.brandName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (item.availableQuantity != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.businessMenuAvailableQuantity(
                            item.availableQuantity!,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (item.isOutOfStock)
                      Text(
                        l10n.businessOutOfStock,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.error,
                        ),
                      )
                    else if (!offersStepper)
                      Text(
                        _priceLabel(item, l10n),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentGold,
                        ),
                      ),
                    if (offersStepper && !item.isOutOfStock) ...[
                      Divider(height: 1, color: theme.dividerColor),
                      const SizedBox(height: 8),
                      MenuCardStepperRow(
                        qty: _qty,
                        adding: _adding,
                        onInc: _inc,
                        onDec: _qty > 1 ? _dec : null,
                        onAdd: _add,
                        addLabel: l10n.menuCardAddShort,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _priceLabel(MenuItemSummary item, AppLocalizations l10n) {
    final unit = item.saleUnitLabel;
    final price = (item.startingPrice ?? item.basePrice).toStringAsFixed(0);
    return unit != null ? l10n.menuCardPricePerUnit(price, unit) : price;
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
          ? Text(emoji!, style: const TextStyle(fontSize: 36))
          : Icon(Icons.restaurant_menu_outlined, color: onSurface),
    );
  }
}
