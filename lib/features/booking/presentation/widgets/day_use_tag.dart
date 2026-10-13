import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/booking.dart';
import '../../../../core/time/clock_format.dart';

/// «Day use · 09:00–18:00» — shown on a hotel booking that holds a room for a window of the day, no night.
class DayUseTag extends StatelessWidget {
  final Booking booking;
  const DayUseTag({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final from = booking.startsAt;
    final to = booking.endsAt;
    if (!booking.isDayUse || from == null || to == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(l10n.bookingDayUseTag(ClockFormat.time(context, from), ClockFormat.time(context, to)), style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
