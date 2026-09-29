import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The quick-add row for a goods-catalog item: a +/- stepper on one side, a
/// standalone "أضف" (add) pill on the other — one line, one glance, matching
/// the Tech Catalog Setup canvas's "بلا تفاصيل" storefront card exactly.
/// Shared by [MenuItemTile] (list mode) and [MenuItemGridCard] (grid mode)
/// so both offer the exact same add-to-cart components — «زيادة الكمية من
/// الكارت يجب ان يكون نفس المكونات قائمة او كارت» — المالك، 2026-09-29.
class MenuCardStepperRow extends StatelessWidget {
  final int qty;
  final bool adding;
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
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
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
                        size: 15,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        addLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w700,
                        ),
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

  const _StepperButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

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
          border: filled
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(
          icon,
          size: 16,
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
