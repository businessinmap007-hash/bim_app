import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/time/clock_format.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/trip_reservation.dart';

/// What a reservation is FOR, in one block: «from ← to», whether it is an empty return, and when it leaves — a date
/// for a one-off leg, «every Tuesday 9:00 AM» for a weekly one. Shared by the customer's and the carrier's lists.
/// «from → to» in a left-to-right language and «from ← to» in a right-to-left one: the arrow always points at the
/// destination, whichever way the line is read.
String routeArrow(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl ? '←' : '→';

class TripLegSummary extends StatelessWidget {
  final TripReservationLeg leg;

  const TripLegSummary({super.key, required this.leg});

  /// The leg's time as a person reads it; null when the leg names none.
  static String? when(BuildContext context, TripReservationLeg leg) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final arabic = locale.languageCode == 'ar';

    final departs = leg.departsAt;
    if (departs != null) {
      return LocalFormat.dayDate(context).addClock().format(departs);
    }

    final time = _clockOf(leg.departureTime, arabic);
    final dow = leg.dayOfWeek;
    if (dow != null) {
      // 0 = Sunday; 1 Jan 2023 was a Sunday
      final day = LocalFormat.latinDigits(
        DateFormat.EEEE(locale.toString()).format(DateTime(2023, 1, 1 + dow)),
      );
      return time == null
          ? l10n.tripLegEveryDay(day)
          : l10n.tripLegEveryDayAt(day, time);
    }

    return time;
  }

  static String? _clockOf(String? hhmm, bool arabic) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return ClockFormat.clock(DateTime(2000, 1, 1, h, m), arabic: arabic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final at = when(context, leg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '${leg.originLabel} ${routeArrow(context)} ${leg.destinationLabel}',
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (leg.isReturnLeg) ...[
              const SizedBox(width: 8),
              Chip(
                avatar: const Icon(Icons.u_turn_left, size: 16),
                label: Text(l10n.emptyReturnTitle),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        if (at != null) Text(at, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
