import '../../../cart/presentation/widgets/weight_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The quick-add row for a goods-catalog item: a +/- stepper on one side, a
/// standalone "أضف" (add) pill on the other — one line, one glance, matching
/// the Tech Catalog Setup canvas's "بلا تفاصيل" storefront card exactly.
/// Shared by [MenuItemTile] (list mode) and [MenuItemGridCard] (grid mode)
/// so both offer the exact same add-to-cart components — «زيادة الكمية من
/// الكارت يجب ان يكون نفس المكونات قائمة او كارت» — المالك، 2026-09-29.
class MenuCardStepperRow extends StatelessWidget {
  final double qty;
  final bool adding;

  /// «كيلو وربع ونص»: for food sold by the kilo the stepper is the weight picker (grams as chips, kilos as
  /// a stepper); the pill stays «أضف».
  final ValueChanged<double>? onWeightChanged;
  final VoidCallback onInc;
  final VoidCallback? onDec;
  final VoidCallback onAdd;
  final String addLabel;

  const MenuCardStepperRow({
    super.key,
    required this.qty,
    required this.adding,
    required this.onInc,
    required this.onDec,
    required this.onAdd,
    required this.addLabel,
    this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // «RenderFlex overflowed by 5.2 pixels on the right» — المالك،
    // 2026-09-29, hit inside a narrow grid card (2-3 to a row) where this
    // row shares the widget verbatim with the much wider list tile.
    // Trimmed every fixed dimension a little rather than special-casing
    // grid vs. list — keeps this ONE shared component, per the owner's own
    // "نفس المكونات قائمة او كارت" requirement, with real margin left over
    // for a longer localized label or a larger system font size.
    final pill = _AddPill(adding: adding, onAdd: onAdd, addLabel: addLabel);
    if (onWeightChanged != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeightPicker(value: qty, onChanged: onWeightChanged!),
          const SizedBox(height: 6),
          Align(alignment: AlignmentDirectional.centerEnd, child: pill),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _StepperButton(icon: Icons.remove, filled: false, onTap: onDec),
            SizedBox(
              width: 26,
              child: Text(
                formatQty(qty),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
            ),
            _StepperButton(icon: Icons.add, filled: true, onTap: onInc),
          ],
        ),
        Flexible(child: pill),
      ],
    );
  }
}

class _AddPill extends StatelessWidget {
  final bool adding;
  final VoidCallback onAdd;
  final String addLabel;
  const _AddPill({required this.adding, required this.onAdd, required this.addLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
            onTap: adding ? null : onAdd,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.14),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: adding
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentGold,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 13,
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            addLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.accentGold : null,
          border: filled
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(
          icon,
          size: 15,
          color: filled
              ? AppColors.primaryNavy
              : (onTap == null
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
}
