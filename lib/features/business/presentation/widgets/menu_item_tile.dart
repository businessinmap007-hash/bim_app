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
///
/// A goods-catalog item sold by a measured unit (كجم، لتر…) and carrying no
/// variant/extra choice gets an inline +/- stepper and its own "أضف" button
/// instead — per the owner's Tech Catalog Setup canvas ("عطارة الدقي" board):
/// a quick market list is a few taps of quantity then one add, not a sheet
/// open for every single item. [onDirectAdd] is how the caller wires that
/// add — routed through the caller's own cart (solo or shared), same as
/// [onTap] already is. A restaurant dish or anything WITH a choice keeps the
/// existing tap-opens-a-sheet flow untouched: [onDirectAdd] simply isn't
/// offered for those (`sale_unit_label` is null — see MenuDiscoveryController).
class MenuItemTile extends StatefulWidget {
  final MenuItemSummary item;
  final VoidCallback? onTap;
  final Future<void> Function(int qty)? onDirectAdd;

  const MenuItemTile({super.key, required this.item, this.onTap, this.onDirectAdd});

  bool get _offersStepper => onDirectAdd != null && !item.hasChoices && item.saleUnitLabel != null;

  @override
  State<MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<MenuItemTile> {
  int _qty = 1;
  bool _adding = false;

  MenuItemSummary get item => widget.item;

  void _inc() => setState(() => _qty++);

  /// Clamped at 1 for now — a real fraction-of-a-unit ("نص كيلو") needs the
  /// cart to carry a non-integer qty end to end (backend `qty` is `integer`
  /// everywhere: validation, pricing, orders, invoices), which this screen
  /// alone can't safely add. Tracked as a follow-up, not guessed at here.
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

  /// See MenuItemGridCard's identical getter — only a goods item (sold under
  /// a vocabulary branch) gets a produce emoji.
  String? get _placeholderEmoji {
    final branch = item.lineOption;
    return branch == null ? null : produceEmoji(branch.nameEn);
  }

  /// The offering heading (or a plain description) under the item's name —
  /// but not when it's just the item's own name again. A restaurant item
  /// with no modifiers on its line option gets a heading that's nothing but
  /// that line option's own name (MenuItem::heading()'s "option_combo"
  /// branch with an empty modifier list), which is exactly the item's own
  /// name whenever the merchant typed the item the same as its type — the
  /// common case for a single-item branch.
  String? get _subtitle {
    final label = item.offeringLabel ?? item.description;
    if (label.isEmpty || label.trim() == item.name.trim()) return null;
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final imageUrl = item.imageUrl ?? (item.imageUrls.isNotEmpty ? item.imageUrls.first : null);

    final offersStepper = widget._offersStepper;

    return Opacity(
      opacity: item.isOutOfStock ? 0.5 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // The stepper row below is its own tap targets; the card itself
          // has nothing left to open for a quick-add item.
          onTap: item.isOutOfStock || offersStepper ? null : widget.onTap,
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
                      if (_subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                          ),
                        ),
                      if (item.specSummary != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.specSummary!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 11),
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
                          else if (!offersStepper)
                            _ContextAction(hasChoices: item.hasChoices, label: l10n.menuCardViewOptions),
                        ],
                      ),
                      if (offersStepper && !item.isOutOfStock) ...[
                        const SizedBox(height: 8),
                        Divider(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 8),
                        _StepperRow(
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
      ),
    );
  }

  String _priceLabel(MenuItemSummary item, AppLocalizations l10n) {
    final unit = item.saleUnitLabel;
    final startingPrice = item.startingPrice;
    if (startingPrice != null) {
      final price = startingPrice.toStringAsFixed(0);
      return unit != null ? l10n.menuCardPricePerUnit(price, unit) : l10n.menuCardPriceFrom(price);
    }
    final price = item.basePrice.toStringAsFixed(0);
    return unit != null ? l10n.menuCardPricePerUnit(price, unit) : price;
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

/// The quick-add row for a goods-catalog item: a +/- stepper on one side, a
/// standalone "أضف" (add) pill on the other — one line, one glance, matching
/// the Tech Catalog Setup canvas's "بلا تفاصيل" storefront card exactly.
class _StepperRow extends StatelessWidget {
  final int qty;
  final bool adding;
  final VoidCallback onInc;
  final VoidCallback? onDec;
  final VoidCallback onAdd;
  final String addLabel;

  const _StepperRow({
    required this.qty,
    required this.adding,
    required this.onInc,
    required this.onDec,
    required this.onAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _StepperButton(icon: Icons.remove, filled: false, onTap: onDec),
            SizedBox(
              width: 32,
              child: Text('$qty', textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
            ),
            _StepperButton(icon: Icons.add, filled: true, onTap: onInc),
          ],
        ),
        InkWell(
          onTap: adding ? null : onAdd,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: adding
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 15, color: AppColors.accentGold),
                      const SizedBox(width: 6),
                      Text(
                        addLabel,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.accentGold, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.accentGold : null,
          border: filled ? null : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled
              ? AppColors.primaryNavy
              : (onTap == null ? Theme.of(context).disabledColor : Theme.of(context).iconTheme.color),
        ),
      ),
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
