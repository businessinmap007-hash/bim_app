import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/placed_order.dart';

/// «تقسيط»: an order's payments by month, each with its date and amount — shown
/// to the customer on their order and to the merchant on the incoming order.
/// Draws nothing for an order paid in one go.
class InstallmentSchedule extends StatelessWidget {
  final List<OrderInstallment> installments;
  const InstallmentSchedule({super.key, required this.installments});

  @override
  Widget build(BuildContext context) {
    if (installments.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(l10n.ordersInstallmentsTitle, style: Theme.of(context).textTheme.titleSmall),
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
                Text(p.amount.toStringAsFixed(0), style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
      ],
    );
  }
}
