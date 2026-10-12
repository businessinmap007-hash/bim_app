import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/time/egypt_time.dart';

void main() {
  test('an instant is shown on Cairo\'s wall clock, with daylight saving', () {
    // October (EEST, +3): 06:00Z is 09:00 in Cairo
    final summer = EgyptTime.parse('2026-10-10T06:00:00.000000Z');
    expect(summer.hour, 9);
    expect(summer.isUtc, isFalse);

    // January (EET, +2): 06:00Z is 08:00 in Cairo
    expect(EgyptTime.parse('2027-01-10T06:00:00Z').hour, 8);

    // an offset in the string is an instant too
    expect(EgyptTime.parse('2026-10-10T09:00:00+03:00').hour, 9);
    expect(EgyptTime.parse('2026-10-10T09:00:00+00:00').hour, 12);
  });

  test('wall-clock digits with no zone are already Cairo\'s and stay as they are', () {
    expect(EgyptTime.parse('2026-10-10 19:30:00').hour, 19);
    expect(EgyptTime.parse('2026-10-10T19:30:00').minute, 30);

    final day = EgyptTime.parse('2026-10-10');
    expect(day.year, 2026);
    expect(day.hour, 0);
  });

  test('tryParse is null for empty and unreadable input', () {
    expect(EgyptTime.tryParse(null), isNull);
    expect(EgyptTime.tryParse(''), isNull);
    expect(EgyptTime.tryParse('not a date'), isNull);
    expect(EgyptTime.tryParse('2026-10-10T06:00:00Z')?.hour, 9);
  });

  test('now and today are on Cairo\'s clock whatever the phone says', () {
    final now = EgyptTime.now();
    final nowInstantInCairo = EgyptTime.fromInstant(DateTime.now().toUtc());

    expect(now.difference(nowInstantInCairo).inSeconds.abs() < 5, isTrue);
    expect(EgyptTime.today().hour, 0);
    expect(EgyptTime.today().day, now.day);
  });

  test('a value sent back keeps its Cairo digits', () {
    final at = EgyptTime.parse('2026-10-10T06:00:00Z');

    // no `Z`, no offset: the server stores exactly these digits, which are Cairo's
    expect(at.toIso8601String(), startsWith('2026-10-10T09:00:00'));
    expect(at.toIso8601String().endsWith('Z'), isFalse);
  });
}
