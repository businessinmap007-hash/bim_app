import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/albums/application/albums_controller.dart';
import 'package:bim_app/features/albums/data/models/album.dart';
import 'package:bim_app/features/business/data/models/business_profile.dart';
import 'package:bim_app/features/business/presentation/screens/business_info_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _host(BusinessProfile profile) => ProviderScope(
  overrides: [businessAlbumsProvider(profile.id).overrideWith((ref) async => <Album>[])],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: BusinessInfoBody(profile: profile)),
  ),
);

BusinessProfile _profile({Map<String, dynamic>? hours, bool openNow = true}) => BusinessProfile.fromJson({
  'id': 7,
  'name': 'صالون النجمة',
  'phone': '0100',
  'open_now': openNow,
  'working_hours': hours,
});

Map<String, dynamic> _day(int day, {bool? closed, String? open, String? close}) => {
  'day': day,
  'is_closed': closed,
  'open': open,
  'close': close,
};

WorkingHours _week(List<WorkingDay> days) => WorkingHours(timezone: 'Africa/Cairo', days: days);

WorkingDay _d(int day, {bool? closed = false, String? open, String? close, bool all = false}) =>
    WorkingDay(day: day, isClosed: closed, open: open, close: close, is24h: all);

// 2026-10-14 is a Wednesday = the server's day 3
DateTime _at(int h, int m) => DateTime(2026, 10, 14, h, m);

void main() {
  group('what the business says right now', () {
    final week = _week([_d(3, open: '09:00', close: '22:00')]);

    test('open, with the closing time, while it is far away', () {
      final s = week.statusAt(_at(12, 0));
      expect(s.state, HoursState.open);
      expect(s.at, _at(22, 0));
    });

    test('inside the last two hours it counts down', () {
      final s = week.statusAt(_at(20, 1));
      expect(s.state, HoursState.closesIn);
      expect(s.left, const Duration(hours: 1, minutes: 59));
    });

    test('exactly two hours before closing it starts', () {
      expect(week.statusAt(_at(20, 0)).state, HoursState.closesIn);
      expect(week.statusAt(_at(19, 59)).state, HoursState.open);
    });

    test('before opening it says when it opens; after closing it is closed', () {
      final before = week.statusAt(_at(7, 30));
      expect(before.state, HoursState.opensAt);
      expect(before.at, _at(9, 0));
      expect(week.statusAt(_at(22, 30)).state, HoursState.closedNow);
    });

    test('a closed day, an all-day day, and a day it never wrote', () {
      expect(_week([_d(3, closed: true)]).statusAt(_at(12, 0)).state, HoursState.closedToday);
      expect(_week([_d(3, all: true, open: '00:00', close: '23:59')]).statusAt(_at(3, 0)).state, HoursState.allDay);
      expect(_week([_d(3, closed: null)]).statusAt(_at(12, 0)).state, HoursState.unknown);
    });

    test('a window past midnight is open after midnight and counts down to its end', () {
      // Tuesday (2) 20:00 → 02:00; it is now Wednesday 00:30
      final overnight = _week([_d(2, open: '20:00', close: '02:00'), _d(3, closed: true)]);
      final s = overnight.statusAt(_at(0, 30));
      expect(s.state, HoursState.closesIn);
      expect(s.left, const Duration(hours: 1, minutes: 30));
    });
  });

  testWidgets('the About tab says only whether it is open — no week listing', (tester) async {
    final profile = _profile(
      hours: {
        'timezone': 'Africa/Cairo',
        'days': [for (var d = 0; d < 7; d++) _day(d, closed: false, open: '00:00', close: '23:59')]
            .map((e) => {...e, 'is_24h': true})
            .toList(),
      },
    );

    await tester.pumpWidget(_host(profile));
    await tester.pumpAndSettle();

    expect(find.text('ساعات العمل'), findsOneWidget);
    expect(find.text('مفتوح الآن'), findsOneWidget);
    expect(find.text('مفتوح 24 ساعة'), findsOneWidget);
    // the week is not drawn
    expect(find.text('السبت'), findsNothing);
    expect(find.text('الجمعة'), findsNothing);
  });

  testWidgets('a business that wrote no hours has no hours card', (tester) async {
    await tester.pumpWidget(_host(_profile()));
    await tester.pumpAndSettle();

    expect(find.text('ساعات العمل'), findsNothing);
  });

  testWidgets('a business closed all day is labelled closed now and closed today', (tester) async {
    await tester.pumpWidget(
      _host(
        _profile(
          hours: {'timezone': 'Africa/Cairo', 'days': [for (var d = 0; d < 7; d++) _day(d, closed: true)]},
          openNow: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مغلق الآن'), findsOneWidget);
    expect(find.text('مغلق اليوم'), findsOneWidget);
  });
}
