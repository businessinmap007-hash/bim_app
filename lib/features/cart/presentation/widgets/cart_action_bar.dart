import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The ONE add-to-cart / buy-now bar, under every service — the menu sheet,
/// the product page and the retail storefront all draw this, never their own.
/// «شكل الازرار وامكانهم ومسمياتهم وايضا ظهور اضافة عربة المشتريات لابد ان
/// يكون موحد فى الشكل و السلوك على مستوى التطبيق تحت اى خدمة» — المالك،
/// 2026-10-02.
///
/// The shape is the one the owner approved on the product page the day
/// before («هل شكل الازرار كدا افضل»): the total once, on its own line (with
/// the quantity stepper beside it when the caller has one), then the two
/// actions side by side at the same height — «أضف للسلة» outlined with the
/// cart icon, «شراء مباشر» in gold. The price is never repeated on a button.
/// A shared cart checks out through its host all at once, so it offers only
/// «أضف للسلة», in gold.
class CartActionBar extends StatelessWidget {
  final double total;
  final VoidCallback? onAdd;
  final VoidCallback? onBuyNow;
  final bool submitting;
  final bool sharedCart;

  /// Sits at the start of the total line — the quantity stepper, when the
  /// caller doesn't already draw one of its own above.
  final Widget? leading;

  const CartActionBar({
    super.key,
    required this.total,
    required this.onAdd,
    this.onBuyNow,
    this.submitting = false,
    this.sharedCart = false,
    this.leading,
  });

  static const double buttonHeight = 52;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final addOnly = sharedCart || onBuyNow == null;

    final primary = SizedBox(
      height: buttonHeight,
      child: FilledButton(
        onPressed: addOnly ? onAdd : onBuyNow,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.primaryNavy,
          shape: shape,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        child: Text(addOnly ? l10n.cartAdd : l10n.cartBuyNow, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ?leading,
            const Spacer(),
            Text(l10n.techDetailTotal, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(width: 8),
            Text(
              '${NumberFormat.decimalPattern('en').format(total.round())} ${l10n.pharmacyCurrencyLabel}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (submitting)
          const SizedBox(
            height: buttonHeight,
            child: Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))),
          )
        else if (addOnly)
          SizedBox(width: double.infinity, child: primary)
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                    label: Text(l10n.cartAdd, maxLines: 1, overflow: TextOverflow.ellipsis),
                    style: OutlinedButton.styleFrom(
                      shape: shape,
                      side: BorderSide(color: theme.colorScheme.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: primary),
            ],
          ),
      ],
    );
  }
}

/// The quantity stepper that sits at the start of [CartActionBar]'s total
/// line — one shape for every service, same as the bar itself.
class CartQtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;
  const CartQtyStepper({super.key, required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded, size: 20),
          ),
          SizedBox(
            width: 28,
            child: Text('$qty', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
