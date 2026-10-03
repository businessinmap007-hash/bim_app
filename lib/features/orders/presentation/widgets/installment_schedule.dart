import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/placed_order.dart';

/// «تقسيط»: an order's payments by month, each with its date and amount, and
/// what is paid so far against what is left — shown to the customer on their
/// order, to the merchant on the incoming order (who also records a payment as
/// collected through [onCollect]) and to the customer when the order is placed.
/// Draws nothing for an order paid in one go.
class InstallmentSchedule extends StatelessWidget {
  final List<OrderInstallment> installments;
  /// The merchant's «تحصيل» / take-back; null hides the buttons (the customer's view).
  final Future<void> Function(OrderInstallment payment, bool paid)? onCollect;
  const InstallmentSchedule({super.key, required this.installments, this.onCollect});

  @override
  Widget build(BuildContext context) {
    if (installments.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final paid = installments.where((p) => p.paidAt != null).fold<double>(0, (a, p) => a + p.amount);
    final remaining = installments.where((p) => p.paidAt == null).fold<double>(0, (a, p) => a + p.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(l10n.ordersInstallmentsTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          l10n.ordersInstallmentsPaidSummary(paid.round().toString(), remaining.round().toString()),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        for (final p in installments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 26, child: Text('${p.seq}', style: Theme.of(context).textTheme.bodySmall)),
                Expanded(
                  child: Text(
                    p.dueOn == null ? '' : p.dueOn!.toIso8601String().substring(0, 10),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (p.paidAt != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Text(l10n.ordersInstallmentPaid, style: TextStyle(color: AppColors.success, fontSize: 12)),
                  ),
                if (onCollect != null && p.paidAt == null)
                  TextButton(onPressed: () => onCollect!(p, true), child: Text(l10n.ordersInstallmentCollect)),
                if (onCollect != null && p.paidAt != null)
                  IconButton(
                    tooltip: l10n.ordersInstallmentUndo,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.undo, size: 18),
                    onPressed: () => onCollect!(p, false),
                  ),
                Text(p.amount.toStringAsFixed(0), style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
      ],
    );
  }
}
