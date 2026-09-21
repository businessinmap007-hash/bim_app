import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/agenda/application/agenda_providers.dart';
import 'package:bim_app/features/agenda/data/agenda_api.dart';
import 'package:bim_app/features/agenda/data/models/agenda_item.dart';
import 'package:bim_app/features/agenda/data/models/agenda_settings.dart';
import 'package:bim_app/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:bim_app/features/agenda/presentation/screens/agenda_settings_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeAgendaApi implements AgendaApi {
  Map<String, Object?>? recurring;
  int recurringCalls = 0;
  int rotations = 0;
  String url = 'https://example.test/api/v2/agenda/feed/OLD.ics';

  @override
  Future<List<AgendaItem>> day(DateTime date) async => const [];

  @override
  Future<({int created, int skipped})> addRecurring({
    required String title,
    required String startTime,
    required int durationMinutes,
    required String frequency,
    List<int> weekdays = const [],
    int weeks = 4,
    String? notes,
    bool remind = false,
  }) async {
    recurringCalls++;
    recurring = {
      'title': title,
      'startTime': startTime,
      'duration': durationMinutes,
      'frequency': frequency,
      'weekdays': weekdays,
      'weeks': weeks,
      'remind': remind,
    };
    return (created: 7, skipped: 2);
  }

  @override
  Future<String> feedUrl() async => url;

  @override
  Future<String> rotateFeedUrl() async {
    rotations++;
    url = 'https://example.test/api/v2/agenda/feed/NEW.ics';
    return url;
  }

  @override
  Future<MealTimes> mealTimes() async => const MealTimes(breakfastAt: '08:00', lunchAt: '14:00', dinnerAt: '20:00');

  @override
  Future<ReminderPreferences> reminderPreferences() async => const ReminderPreferences(
    appointmentFirstLeadMinutes: 60,
    appointmentSecondLeadMinutes: null,
    agendaLeadMinutes: 15,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, _FakeAgendaApi api) => ProviderScope(
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
    home: home,
  ),
);

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a weekly task is sent to the recurring endpoint with its weekdays', (tester) async {
    final api = _FakeAgendaApi();
    await tester.pumpWidget(_app(const AgendaScreen(), api));
    await tester.pumpAndSettle();

    await _openSheet(tester);
    await tester.enterText(find.byType(TextField).first, 'Gym');
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Sun'));
    await tester.tap(find.widgetWithText(FilterChip, 'Tue'));
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(api.recurringCalls, 1);
    expect(api.recurring?['title'], 'Gym');
    expect(api.recurring?['frequency'], 'weekly');
    expect(api.recurring?['weekdays'], [0, 2]);
    expect(api.recurring?['weeks'], 4);
    expect(api.recurring?['startTime'], matches(RegExp(r'^\d{2}:\d{2}$')));
    expect(api.recurring?['duration'], 30, reason: 'no end time falls back to the server default');
    expect(find.text('Added 7 tasks; skipped 2 that clashed with other commitments.'), findsOneWidget);
  });

  testWidgets('weekly with no weekday picked is refused before any request', (tester) async {
    final api = _FakeAgendaApi();
    await tester.pumpWidget(_app(const AgendaScreen(), api));
    await tester.pumpAndSettle();

    await _openSheet(tester);
    await tester.enterText(find.byType(TextField).first, 'Gym');
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Pick at least one day.'), findsOneWidget);
    expect(api.recurringCalls, 0);
  });

  testWidgets('the settings screen shows the calendar link, copies it and rotates it', (tester) async {
    final api = _FakeAgendaApi();
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clipboard = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(_app(const AgendaSettingsScreen(), api));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Copy link'), 300);
    expect(find.text('https://example.test/api/v2/agenda/feed/OLD.ics'), findsOneWidget);

    await tester.tap(find.text('Copy link'));
    await tester.pump();
    expect(clipboard, 'https://example.test/api/v2/agenda/feed/OLD.ics');

    await tester.tap(find.text('Create a new link'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Create a new link')));
    await tester.pumpAndSettle();

    expect(api.rotations, 1);
    expect(find.text('https://example.test/api/v2/agenda/feed/NEW.ics'), findsOneWidget);
  });
}
