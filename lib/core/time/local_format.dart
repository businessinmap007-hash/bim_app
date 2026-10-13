import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'clock_format.dart';

/// A date in the person's language, written the way that language writes it — «20 أكتوبر 2026» / «Oct 20, 2026» —
/// never the US month-first «10/20/2026» a bare `LocalFormat.numeric(context)` falls back to, and with Latin digits like every other
/// number in the app (intl's Arabic data would otherwise write «٢٠» and the digits then reorder inside RTL text).
///
/// Built from the screen's [BuildContext], used like a `DateFormat`: `LocalFormat.date(context).format(d)`, and
/// `.addClock()` appends the 12-hour clock («9:00 م» / «9:00 PM»).
class LocalFormat {
  final DateFormat _format;
  final bool _arabic;
  final bool _clock;

  const LocalFormat._(this._format, this._arabic, this._clock);

  static (String, bool) _lang(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return (locale.toString(), locale.languageCode == 'ar');
  }

  /// «20 أكتوبر 2026» / «Oct 20, 2026».
  factory LocalFormat.date(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.yMMMd(l), ar, false);
  }

  /// With the weekday: «الثلاثاء، 20 أكتوبر 2026» / «Tue, Oct 20, 2026».
  factory LocalFormat.dayDate(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.yMMMEd(l), ar, false);
  }

  /// «الثلاثاء، 20 أكتوبر» / «Tue, Oct 20» — no year.
  factory LocalFormat.weekdayMonthDay(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.MMMEd(l), ar, false);
  }

  /// «20 أكتوبر» / «Oct 20».
  factory LocalFormat.monthDay(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.MMMd(l), ar, false);
  }

  /// «أكتوبر 2026» / «October 2026».
  factory LocalFormat.monthYear(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.yMMMM(l), ar, false);
  }

  /// Digits only, in the order the language reads them: «20/10/2026» in Arabic (day first), «10/20/2026» in English.
  factory LocalFormat.numeric(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.yMd(l), ar, false);
  }

  /// The short weekday name — «ث» / «Tue».
  factory LocalFormat.weekday(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.E(l), ar, false);
  }

  /// The day of the month, as Latin digits.
  factory LocalFormat.dayNumber(BuildContext context) {
    final (l, ar) = _lang(context);

    return LocalFormat._(DateFormat.d(l), ar, false);
  }

  /// This format followed by « · 9:00 م».
  LocalFormat addClock() => LocalFormat._(_format, _arabic, true);

  String format(DateTime at) {
    final date = latinDigits(_format.format(at));

    return _clock ? '$date · ${ClockFormat.clock(at, arabic: _arabic)}' : date;
  }

  /// Arabic-Indic digits → Latin, and the direction marks intl wraps Arabic dates in dropped.
  static String latinDigits(String value) {
    final out = StringBuffer();
    for (final r in value.runes) {
      if (r >= 0x0660 && r <= 0x0669) {
        out.writeCharCode(r - 0x0660 + 0x30);
      } else if (r >= 0x06F0 && r <= 0x06F9) {
        out.writeCharCode(r - 0x06F0 + 0x30);
      } else if (r == 0x200E || r == 0x200F || r == 0x061C) {
        continue;
      } else {
        out.writeCharCode(r);
      }
    }

    return out.toString();
  }
}
