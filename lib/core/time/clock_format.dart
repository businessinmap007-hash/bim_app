import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// «صباحًا / مساءً» — every clock a person reads or sets in the app is a 12-hour clock with its AM/PM mark
/// («٩:٠٠ ص»), never «21:00». The wire format stays "HH:mm" (the server stores and compares 24-hour strings); this is
/// only what the screen says and what the time picker offers.
class ClockFormat {
  ClockFormat._();

  static String _localeOf(BuildContext context) =>
      Localizations.localeOf(context).toString();

  /// "HH:mm" or "HH:mm:ss" (what the API sends) → «٩:٠٠ م». Null / unparsable → [fallback].
  static String hhmm(
    BuildContext context,
    String? value, {
    String fallback = '--:--',
  }) {
    final t = parse(value);
    if (t == null) return fallback;

    return time(context, DateTime(2000, 1, 1, t.hour, t.minute));
  }

  /// "HH:mm[:ss]" → a [TimeOfDay], or null when it is not a clock.
  static TimeOfDay? parse(String? value) {
    if (value == null) return null;
    final parts = value.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;

    return TimeOfDay(hour: h, minute: m);
  }

  /// A [TimeOfDay] as «٩:٠٠ م» — unlike `TimeOfDay.format`, never the phone's own 24-hour setting.
  static String of(BuildContext context, TimeOfDay t) =>
      time(context, DateTime(2000, 1, 1, t.hour, t.minute));

  /// A [TimeOfDay] back to the wire's "HH:mm".
  static String wire(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// A moment's clock: «٩:٠٠ م».
  static String time(BuildContext context, DateTime at) =>
      DateFormat.jm(_localeOf(context)).format(at);

  /// «2026-10-14 ٩:٠٠ م» — the compact date + clock the lists use.
  static String dateTime(BuildContext context, DateTime at) {
    final d =
        '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}';

    return '$d ${time(context, at)}';
  }

  /// «٩:٠٠ ص – ١٠:٣٠ ص»; a missing end leaves just the start.
  static String range(BuildContext context, DateTime start, DateTime? end) =>
      end == null
      ? time(context, start)
      : '${time(context, start)} – ${time(context, end)}';

  /// The platform time picker, always on the 12-hour dial with AM/PM (whatever the phone's own 24-hour setting says).
  static Future<TimeOfDay?> pick(
    BuildContext context, {
    required TimeOfDay initial,
  }) => showTimePicker(
    context: context,
    initialTime: initial,
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
