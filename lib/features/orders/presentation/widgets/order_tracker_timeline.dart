import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/placed_order.dart';

/// A Bosta-style vertical step tracker for one order, built purely from
/// [PlacedOrder]'s own fields -- `prepStatus` (accepted/preparing/ready),
/// `deliveryStage` (assigned/picked_up/delivered, delivery orders only) and
/// the coarse `status` (pending/completed/cancelled). Same widget for the
/// customer and business detail screens; a cancelled/rejected order gets a
/// banner instead of a stepper, since there's no meaningful "how far did it
/// get" to show once it's dead.
class OrderTrackerTimeline extends StatelessWidget {
  final PlacedOrder order;
  const OrderTrackerTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (order.status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.orderTrackerCancelledTitle, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    }

    final steps = _stepLabels(order, l10n);
    final currentIndex = _currentIndex(order, steps.length);
    final isFullyDone = order.status == 'completed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            label: steps[i],
            isDone: i < currentIndex || (i == currentIndex && isFullyDone),
            isCurrent: i == currentIndex && !isFullyDone,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }

  List<String> _stepLabels(PlacedOrder order, AppLocalizations l10n) {
    final base = [l10n.orderTrackerPlaced, l10n.orderTrackerAccepted, l10n.orderTrackerPreparing, l10n.orderTrackerReady];

    if (order.fulfillmentType == 'delivery') {
      return [...base, l10n.orderTrackerDriverAssigned, l10n.orderTrackerPickedUpByDriver, l10n.orderTrackerDelivered];
    }

    return [...base, order.fulfillmentType == 'dine_in' ? l10n.orderTrackerCompletedDineIn : l10n.orderTrackerCompletedPickup];
  }

  /// The index (into the step list built above) of the furthest step reached
  /// so far -- deliberately a pure function of the order's own fields, no
  /// widget state, so it's trivial to re-derive after any refresh.
  int _currentIndex(PlacedOrder order, int stepCount) {
    if (order.status == 'completed') return stepCount - 1;

    switch (order.prepStatus) {
      case 'accepted':
        return 1;
      case 'preparing':
        return 2;
      case 'ready':
        if (order.fulfillmentType != 'delivery') return 3;
        return switch (order.deliveryStage) {
          'assigned' => 4,
          'picked_up' => 5,
          'delivered' => 6,
          _ => 3,
        };
      default:
        return 0;
    }
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  const _StepRow({required this.label, required this.isDone, required this.isCurrent, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final active = isDone || isCurrent;
    final color = active ? AppColors.accentGold : Theme.of(context).hintColor.withValues(alpha: 0.4);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.accentGold : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.black)
                    : isCurrent
                    ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)))
                    : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: color.withValues(alpha: 0.4))),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              label,
              style: TextStyle(
                color: active ? null : Theme.of(context).hintColor,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
