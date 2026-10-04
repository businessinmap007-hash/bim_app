import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/menu_item_summary.dart';

/// «كاش أو أقساط» — how the customer pays for what they picked. Cash is the price; each plan shows what
/// a unit costs on it and the month. Nothing when the item sells for cash only.
class PaymentPlanPicker extends StatelessWidget {
  /// What ONE unit costs in cash (the picked size or condition already applied).
  final double cashUnitPrice;
  final List<MenuItemPaymentPlan> plans;

  /// null = cash.
  final int? selectedPlanId;
  final ValueChanged<int?> onChanged;

  const PaymentPlanPicker({
    super.key,
    required this.cashUnitPrice,
    required this.plans,
    required this.selectedPlanId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return RadioGroup<int>(
      groupValue: selectedPlanId ?? 0,
      // 0 is cash; a plan's own id otherwise.
      onChanged: (value) =>
          onChanged(value == null || value == 0 ? null : value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cartPaymentChoose, style: theme.textTheme.titleSmall),
          RadioListTile<int>(
            contentPadding: EdgeInsets.zero,
            value: 0,
            title: Text(l10n.paymentPlanCash),
            secondary: Text(cashUnitPrice.toStringAsFixed(0)),
          ),
          for (final plan in plans)
            RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              value: plan.id,
              title: Text(l10n.paymentPlanMonths(plan.months)),
              subtitle: Text(
                (plan.down ?? 0) > 0
                    ? l10n.variantInstallmentNoteDown(
                        plan.months,
                        plan.down!.round().toString(),
                        plan.monthly(cashUnitPrice).round().toString(),
                      )
                    : l10n.variantInstallmentNote(
                        plan.months,
                        plan.monthly(cashUnitPrice).round().toString(),
                      ),
              ),
              secondary: Text(plan.unitPrice(cashUnitPrice).toStringAsFixed(0)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
