import 'package:bim_app/core/time/clock_format.dart';
import 'package:bim_app/core/time/local_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Pumps a one-widget app in [locale] and hands the widget's own BuildContext to [read].
Future<String> _say(
  WidgetTester tester,
  Locale locale,
  String Function(BuildContext) read,
) async {
  late String out;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (context) {
          out = read(context);

          return const SizedBox();
        },
      ),
    ),
  );

  return out;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
  });

  test('parse reads the API clock with or without seconds and refuses junk', () {
    expect(ClockFormat.parse('21:30'), const TimeOfDay(hour: 21, minute: 30));
    expect(ClockFormat.parse('09:05:00'), const TimeOfDay(hour: 9, minute: 5));
    expect(ClockFormat.parse('25:00'), isNull);
    expect(ClockFormat.parse('abc'), isNull);
    expect(ClockFormat.parse(null), isNull);
  });

  test('wire writes the 24-hour string the server stores', () {
    expect(ClockFormat.wire(const TimeOfDay(hour: 7, minute: 5)), '07:05');
    expect(ClockFormat.wire(const TimeOfDay(hour: 21, minute: 0)), '21:00');
  });

  testWidgets('an evening hour reads «م» and a morning one «ص» in Arabic', (
    tester,
  ) async {
    final evening = await _say(
      tester,
      const Locale('ar'),
      (c) => ClockFormat.hhmm(c, '21:00'),
    );
    final morning = await _say(
      tester,
      const Locale('ar'),
      (c) => ClockFormat.hhmm(c, '09:30:00'),
    );

    expect(evening, contains('م'));
    expect(evening, isNot(contains('21')));
    expect(morning, contains('ص'));
  });

  testWidgets('English reads AM / PM', (tester) async {
    final pm = await _say(
      tester,
      const Locale('en'),
      (c) => ClockFormat.hhmm(c, '21:00'),
    );
    final am = await _say(
      tester,
      const Locale('en'),
      (c) => ClockFormat.hhmm(c, '00:15'),
    );

    expect(pm, contains('9:00'));
    expect(pm, contains('PM'));
    expect(am, contains('12:15'));
    expect(am, contains('AM'));
  });

  testWidgets('a missing clock says the fallback, not a fake midnight', (
    tester,
  ) async {
    final out = await _say(tester, const Locale('en'), (c) => ClockFormat.hhmm(c, null));

    expect(out, '--:--');
  });

  testWidgets('dateTime writes the date in the language with the 12-hour clock after it', (tester) async {
    final en = await _say(
      tester,
      const Locale('en'),
      (c) => ClockFormat.dateTime(c, DateTime(2026, 10, 14, 15, 5)),
    );
    expect(en, 'Oct 14, 2026 · 3:05 PM');

    final ar = await _say(
      tester,
      const Locale('ar'),
      (c) => ClockFormat.dateTime(c, DateTime(2026, 10, 14, 15, 5)),
    );
    expect(ar, contains('أكتوبر'));
    expect(ar, contains('14'));
    expect(ar, endsWith('3:05 م'));
    // Latin digits only: intl's Arabic data would write ١٤ / ٢٠٢٦
    expect(RegExp('[٠-٩]').hasMatch(ar), isFalse);
  });

  testWidgets('the numeric date reads day-first in Arabic and month-first in English', (tester) async {
    final day = DateTime(2026, 10, 20);
    final ar = await _say(tester, const Locale('ar'), (c) => LocalFormat.numeric(c).format(day));
    final en = await _say(tester, const Locale('en'), (c) => LocalFormat.numeric(c).format(day));

    expect(ar, '20/10/2026');
    expect(en, '10/20/2026');
  });

  testWidgets('addClock appends the clock to any date format', (tester) async {
    final at = DateTime(2026, 10, 20, 9, 30);
    final out = await _say(
      tester,
      const Locale('en'),
      (c) => LocalFormat.numeric(c).addClock().format(at),
    );

    expect(out, '10/20/2026 · 9:30 AM');
  });
}
