import 'package:flutter/material.dart';

/// «صباحًا / مساءً» — every clock a person reads or sets in the app is a 12-hour clock with its AM/PM mark
/// («9:00 ص»), never «21:00». The wire format stays "HH:mm" (the server stores and compares 24-hour strings); this is
/// only what the screen says and what the time picker offers.
class ClockFormat {
  ClockFormat._();

  /// "HH:mm" or "HH:mm:ss" (what the API sends) → «9:00 م». Null / unparsable → [fallback].
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

  /// A [TimeOfDay] as «9:00 م» — unlike `TimeOfDay.format`, never the phone's own 24-hour setting.
  static String of(BuildContext context, TimeOfDay t) =>
      time(context, DateTime(2000, 1, 1, t.hour, t.minute));

  /// A [TimeOfDay] back to the wire's "HH:mm".
  static String wire(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// A moment's clock: «9:00 م» / «9:00 PM». Latin digits like every other number in the app (prices, counts), so the
  /// clock never reorders itself inside right-to-left text; only the AM/PM mark follows the language.
  static String time(BuildContext context, DateTime at) {
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final m = at.minute.toString().padLeft(2, '0');
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final mark = at.hour < 12 ? (arabic ? 'ص' : 'AM') : (arabic ? 'م' : 'PM');

    return '$h:$m $mark';
  }

  /// «2026-10-14 9:00 م» — the compact date + clock the lists use.
  static String dateTime(BuildContext context, DateTime at) {
    final d =
        '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}';

    return '$d ${time(context, at)}';
  }

  /// «9:00 ص – 10:30 ص»; a missing end leaves just the start.
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
