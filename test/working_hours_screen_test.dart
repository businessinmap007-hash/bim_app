import 'package:bim_app/features/booking_settings/application/booking_settings_controller.dart';
import 'package:bim_app/features/booking_settings/data/booking_settings_api.dart';
import 'package:bim_app/features/booking_settings/data/models/booking_settings_models.dart';
import 'package:bim_app/features/booking_settings/presentation/screens/working_hours_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// «انقل ساعات العمل الى اعدادات البزنس … واضف زر مفتوح 24 ساعة» — المالك، 2026-10-13.
class _FakeApi implements BookingSettingsApi {
  final saved = <List<WorkingDay>>[];

  @override
  Future<WorkingHours> hours() async => WorkingHours(
    isOpenNow: true,
    days: [
      for (var d = 0; d < 7; d++)
        d == 5
            ? const WorkingDay(day: 5, isClosed: true)
            : WorkingDay(day: d, isClosed: false, open: '09:00', close: '17:00'),
    ],
  );

  @override
  Future<WorkingHours> updateHours(List<WorkingDay> days) async {
    saved.add(days);

    return WorkingHours(isOpenNow: true, days: days);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The controller's own load fetches prices, units and check times too; the hours page only needs the week.
class _Controller extends BookingSettingsController {
  _Controller(super.api);

  @override
  Future<void> loadAll() async {
    final api = _api;
    state = state.copyWith(isLoading: false, hours: await api.hours());
  }

  BookingSettingsApi get _api => _holder!;
  static BookingSettingsApi? _holder;
}

Widget _app(_FakeApi api) {
  _Controller._holder = api;

  return ProviderScope(
    overrides: [bookingSettingsControllerProvider.overrideWith((ref) => _Controller(api))],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WorkingHoursScreen(),
    ),
  );
}

void main() {
  testWidgets('hours read with ص/م and «مفتوح 24 ساعة» opens every day that is not closed, then saves it', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    // the stored 24-hour strings read as a 12-hour clock
    expect(find.text('9:00 ص'), findsWidgets);
    expect(find.text('5:00 م'), findsWidgets);

    await tester.tap(find.text('مفتوح 24 ساعة'));
    await tester.pumpAndSettle();

    // six open days now say so (the closed Friday keeps its word)
    expect(find.text('مفتوح 24 ساعة'), findsNWidgets(7)); // the button + six days
    expect(find.text('مغلق'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('حفظ المواعيد'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('حفظ المواعيد'));
    await tester.pumpAndSettle();

    final sent = api.saved.single;
    expect(sent.where((d) => d.is24h), hasLength(6));
    expect(sent.firstWhere((d) => d.day == 5).is24h, isFalse);
    expect(sent.firstWhere((d) => d.day == 5).isClosed, isTrue);
  });

  testWidgets('a day that is open all day goes back to picked hours with one tap', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مفتوح 24 ساعة'));
    await tester.pumpAndSettle();
    expect(find.text('مفتوح 24 ساعة'), findsNWidgets(7));

    // the first day's own «24 ساعة» chip (skip the bulk button)
    await tester.tap(find.text('مفتوح 24 ساعة').at(1));
    await tester.pumpAndSettle();

    expect(find.text('مفتوح 24 ساعة'), findsNWidgets(6));
    expect(find.text('وقت الفتح'), findsWidgets);
  });

  test('WorkingDay carries the all-day flag from the API', () {
    final day = WorkingDay.fromJson({'day': 2, 'is_closed': false, 'open': '00:00', 'close': '23:59', 'is_24h': true});
    expect(day.is24h, isTrue);
    expect(WorkingDay.fromJson({'day': 3}).is24h, isFalse);
    expect(const WorkingDay(day: 1).allDay().is24h, isTrue);
  });
}
