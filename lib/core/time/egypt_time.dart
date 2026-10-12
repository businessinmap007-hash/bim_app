import 'package:flutter/material.dart' show TimeOfDay;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// «توقيت القاهرة دائمًا» — the platform runs on Cairo's clock, whatever zone the phone itself is set to.
///
/// The server sends every date-time as a true instant (an ISO string with `Z` / an offset) or as plain wall-clock
/// digits that are already Cairo's. This is the one place that turns either into a `DateTime` whose DIGITS are what a
/// Cairo wall clock shows, so the rest of the app reads `.hour`, formats with `DateFormat`, or compares with
/// [EgyptTime.now] without ever asking which zone the phone is in. Egypt observes daylight saving, so the zone is the
/// tz database's `Africa/Cairo`, never a fixed offset.
///
/// The returned value is a non-UTC `DateTime` carrying Cairo digits: `.toLocal()` on it is a no-op, and sending it
/// back with `toIso8601String()` writes the same wall-clock digits the server stores.
class EgyptTime {
  EgyptTime._();

  static const zoneName = 'Africa/Cairo';

  static tz.Location? _cairo;

  static tz.Location get _location {
    if (_cairo == null) {
      tz_data.initializeTimeZones();
      _cairo = tz.getLocation(zoneName);
    }
    return _cairo!;
  }

  static DateTime _wall(tz.TZDateTime t) =>
      DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second, t.millisecond, t.microsecond);

  /// The current moment on Cairo's wall clock.
  static DateTime now() => _wall(tz.TZDateTime.now(_location));

  /// Today's date at 00:00, on Cairo's wall clock.
  static DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }

  /// The time of day on Cairo's wall clock — for a time picker's initial value.
  static TimeOfDay timeOfDay() {
    final n = now();
    return TimeOfDay(hour: n.hour, minute: n.minute);
  }

  /// A true instant, written as Cairo's wall-clock digits.
  static DateTime fromInstant(DateTime instant) => _wall(tz.TZDateTime.from(instant, _location));

  /// `DateTime.parse`, on Cairo's clock: a string carrying `Z` or an offset is an instant and is converted to Cairo's
  /// digits; one with none is already wall-clock digits and is returned as they are.
  static DateTime parse(String source) {
    final parsed = DateTime.parse(source.trim());
    return parsed.isUtc ? fromInstant(parsed) : parsed;
  }

  static DateTime? tryParse(String? source) {
    if (source == null) return null;
    final parsed = DateTime.tryParse(source.trim());
    if (parsed == null) return null;
    return parsed.isUtc ? fromInstant(parsed) : parsed;
  }
}
