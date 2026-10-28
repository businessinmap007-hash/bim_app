import 'package:flutter/material.dart';

import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/booking.dart';

/// «تفاصيل الإقامة»: what a hotel stay is made of, as it was priced — the adults, each child and what it pays, the extra beds, the
/// single rate, the cots, the meal plan and the gala nights. The hotel reads it on the booking to prepare the room.
class StayDetailsCard extends StatelessWidget {
  final StayDetails details;
  const StayDetailsCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    String pct(double p) => '${p % 1 == 0 ? p.toStringAsFixed(0) : p.toStringAsFixed(2)}%';

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.stayDetailsTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            row(l10n.stayAdults, '${details.adults}'),
            if (details.children.isNotEmpty)
              row(
                l10n.stayChildren,
                details.children
                    .map((c) => c.singleParent
                        ? l10n.stayChildSingleParent(c.age, c.percent <= 0 ? l10n.childFree : pct(c.percent))
                        : l10n.stayChildLine(c.age, c.percent <= 0 ? l10n.childFree : pct(c.percent)))
                    .join('\n'),
              ),
            if (details.extraBeds > 0) row(l10n.extraBedTitle, '× ${details.extraBeds}'),
            if (details.cots > 0) row(l10n.cotTitle, '× ${details.cots}'),
            if (details.mealPlans.isNotEmpty) row(l10n.stayMealPlan, details.mealPlans.join('، ')),
            if (details.singleOccupancyPercent != null) row(l10n.stayOccupancy, l10n.singleOccupancyLine(pct(details.singleOccupancyPercent!))),
            for (final g in details.galaDinners)
              row(
                l10n.galaTitle,
                '${g.name} · ${DateTime.tryParse(g.date) == null ? g.date : LocalFormat.date(context).format(DateTime.parse(g.date))}',
              ),
            if (details.ratePlan == 'non_refundable') row(l10n.ratePlanChoose, l10n.ratePlanNonRefundable),
          ],
        ),
      ),
    );
  }
}
