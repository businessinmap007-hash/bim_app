import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/agenda/application/agenda_providers.dart';
import 'package:bim_app/features/agenda/data/agenda_api.dart';
import 'package:bim_app/features/agenda/data/models/agenda_item.dart';
import 'package:bim_app/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeAgendaApi implements AgendaApi {
  final weekRequests = <String>[];
  final dayRequests = <String>[];

  String _d(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<AgendaItem>> day(DateTime date) async {
    dayRequests.add(_d(date));
    return const [];
  }

  @override
  Future<AgendaWeek> week(DateTime date) async {
    weekRequests.add(_d(date));
    // Saturday 2026-09-19 .. Friday 2026-09-25, the way the server lays it out.
    final start = DateTime(2026, 9, 19);
    return AgendaWeek(
      from: start,
      to: start.add(const Duration(days: 6)),
      days: [
        for (var i = 0; i < 7; i++)
          AgendaWeekDay(
            date: start.add(Duration(days: i)),
            items: i == 1
                ? [
                    AgendaItem(
                      id: 1,
                      kind: 'personal',
                      title: 'Gym session',
                      startsAt: DateTime(2026, 9, 20, 18, 30),
                      endsAt: DateTime(2026, 9, 20, 19, 30),
                      blocking: true,
                    ),
                  ]
                : const [],
          ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeAgendaApi api) => ProviderScope(
  overrides: [agendaApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const AgendaScreen(),
  ),
);

void main() {
  testWidgets('the week view lays out seven days, empty ones included', (tester) async {
    final api = _FakeAgendaApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Week view'));
    await tester.pumpAndSettle();

    expect(api.weekRequests, hasLength(1));
    // The header shows the server's Saturday-to-Friday range.
    expect(find.text('Sep 19, 2026  →  Sep 25, 2026'), findsOneWidget);
    // Seven day cards: one with the task, six saying there is nothing.
    expect(find.text('Sat · Sep 19, 2026'), findsOneWidget);
    expect(find.text('Fri · Sep 25, 2026'), findsOneWidget);
    expect(find.text('6:30 PM – 7:30 PM  Gym session'), findsOneWidget);
    expect(find.text('Nothing'), findsNWidgets(6));
  });

  testWidgets('tapping a day opens it in the day view', (tester) async {
    final api = _FakeAgendaApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Week view'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sun · Sep 20, 2026'));
    await tester.pumpAndSettle();

    // Back to the day view, on the day that was tapped.
    expect(find.byTooltip('Week view'), findsOneWidget);
    expect(find.text('Sep 20, 2026'), findsOneWidget);
    expect(api.dayRequests, contains('2026-09-20'));
  });

  testWidgets('the arrows move a whole week in the week view and a day otherwise', (tester) async {
    final api = _FakeAgendaApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Week view'));
    await tester.pumpAndSettle();
    final first = DateTime.now();
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();

    expect(api.weekRequests, hasLength(2));
    final a = DateTime.parse(api.weekRequests[0]);
    final b = DateTime.parse(api.weekRequests[1]);
    // calendar days, not elapsed time: a week that crosses the clock change is 6 days 23 hours long and still a week
    int dayGap(DateTime x, DateTime y) => DateTime.utc(y.year, y.month, y.day).difference(DateTime.utc(x.year, x.month, x.day)).inDays;
    expect(dayGap(a, b), 7, reason: 'one tap is a week in the week view');
    expect(a.difference(DateTime(first.year, first.month, first.day)).inDays, 0);

    await tester.tap(find.byTooltip('Day view'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    final days = api.dayRequests.map(DateTime.parse).toList();
    expect(dayGap(days[days.length - 2], days.last), 1, reason: 'one tap is a day in the day view');
  });
}
