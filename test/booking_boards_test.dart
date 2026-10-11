import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/application/booking_providers.dart';
import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/booking/presentation/widgets/appointment_board_tab.dart';
import 'package:bim_app/features/booking/presentation/widgets/booking_grid_widgets.dart';
import 'package:bim_app/features/booking/presentation/widgets/course_board_tab.dart';
import 'package:bim_app/features/course/application/course_providers.dart';
import 'package:bim_app/features/course/data/models/course.dart';
import 'package:bim_app/shared/widgets/arrival_notice_banner.dart';
import 'package:bim_app/features/business/application/business_page_providers.dart';
import 'package:bim_app/features/business/data/models/offering_item.dart';
import 'package:bim_app/features/booking/presentation/widgets/furnished_units_tab.dart';
import 'package:bim_app/features/booking/presentation/widgets/hourly_venue_tab.dart';
import 'package:bim_app/features/booking/presentation/widgets/table_booking_tab.dart';
import 'package:bim_app/l10n/app_localizations.dart';

DiscoveredUnit _unit(int id, String title, {double? price = 200, int? capacity, bool? available}) =>
    DiscoveredUnit(id: id, title: title, price: price, capacity: capacity, available: available, periodUnit: 'hour');

UnitCatalog _catalog(UnitShape shape, List<DiscoveredUnit> units) => UnitCatalog(
  serviceId: 5,
  shape: shape,
  kinds: [UnitKindGroup(name: 'ملاعب', itemType: 'rental', unitsCount: units.length, price: 200, offeringId: 9, units: units)],
);

DayGrid _grid(DateTime day) => DayGrid(
  hoursKnown: true,
  unitsTotal: 2,
  opens: '16:00',
  closes: '22:00',
  slots: [
    DayGridSlot(startsAt: DateTime(day.year, day.month, day.day, 16), endsAt: DateTime(day.year, day.month, day.day, 18), free: 2, unitIds: [1, 2]),
    DayGridSlot(startsAt: DateTime(day.year, day.month, day.day, 17), endsAt: DateTime(day.year, day.month, day.day, 19), free: 1, unitIds: [1]),
    DayGridSlot(startsAt: DateTime(day.year, day.month, day.day, 18), endsAt: DateTime(day.year, day.month, day.day, 20), free: 0),
  ],
);

Widget _host(Widget tab, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: const SliverAppBar(pinned: true, title: Text('نشاط')),
          ),
        ],
        body: tab,
      ),
    ),
  ),
);

FilledButton _bar(WidgetTester tester) => tester.widget<FilledButton>(find.descendant(of: find.byType(BookingSummaryBar), matching: find.byType(FilledButton)));

void main() {
  testWidgets('hourly venue: a taken time cannot be picked and a unit not free at the chosen time is greyed', (tester) async {
    final today = DateTime.now();
    final shape = const UnitShape(code: 'hourly_venue', name: 'ملاعب', pattern: 'duration');
    final catalog = _catalog(shape, [_unit(1, 'ملعب خماسي أ'), _unit(2, 'ملعب خماسي ب')]);

    await tester.pumpWidget(
      _host(
        HourlyVenueTab(businessId: 7, catalog: catalog, shape: shape),
        [dayGridProvider.overrideWith((ref, params) async => _grid(today))],
      ),
    );
    await tester.pumpAndSettle();

    // three start times, the last one (no unit free) cannot be tapped
    final chips = find.descendant(of: find.byType(BookingTimeGrid), matching: find.byType(InkWell));
    expect(chips, findsNWidgets(3));
    expect(_bar(tester).onPressed, isNull);

    // 17:00: only unit 1 is free then, so unit 2 is marked unavailable
    await tester.tap(chips.at(1));
    await tester.pumpAndSettle();
    expect(find.text('غير متاحة في هذه المواعيد'), findsOneWidget);

    // the free unit is picked: the bar can book
    await tester.tap(find.text('ملعب خماسي أ'));
    await tester.pumpAndSettle();
    expect(_bar(tester).onPressed, isNotNull);
  });

  testWidgets('table: the tables listed are the ones free at the chosen time', (tester) async {
    final today = DateTime.now();
    final shape = const UnitShape(code: 'table', name: 'طاولة', pattern: 'table');
    final catalog = _catalog(shape, [_unit(1, 'طاولة قرب النافذة', capacity: 4), _unit(2, 'ركن عائلي', capacity: 8)]);

    await tester.pumpWidget(
      _host(
        TableBookingTab(businessId: 7, catalog: catalog, shape: shape),
        [dayGridProvider.overrideWith((ref, params) async => _grid(today))],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ركن عائلي'), findsNothing); // no time yet: no tables
    expect(_bar(tester).onPressed, isNull);

    final chips = find.descendant(of: find.byType(BookingTimeGrid), matching: find.byType(InkWell));
    await tester.tap(chips.at(1)); // 17:00 — only unit 1 is free
    await tester.pumpAndSettle();
    expect(find.text('طاولة قرب النافذة'), findsOneWidget);
    expect(find.text('ركن عائلي'), findsNothing);

    await tester.tap(find.text('طاولة قرب النافذة'));
    await tester.pumpAndSettle();
    expect(_bar(tester).onPressed, isNotNull);
  });

  testWidgets('furnished units: only the units free on the dates are offered, and one must be picked to go on', (tester) async {
    final shape = const UnitShape(code: 'furnished_units', name: 'شاليهات', pattern: 'stay');
    final units = [_unit(1, 'شاليه بحري', price: 1800, capacity: 6, available: true), _unit(2, 'شقة عائلية', price: 1100, capacity: 4, available: false)];
    final catalog = _catalog(shape, units);

    await tester.pumpWidget(
      _host(
        FurnishedUnitsTab(businessId: 7, catalog: catalog, shape: shape),
        [
          unitDiscoveryProvider.overrideWith(
            (ref, params) async => [
              UnitKindGroup(name: 'شاليهات', itemType: 'booking_stay', unitsCount: 2, offeringId: 9, price: 1800, units: units),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('شاليه بحري'), findsOneWidget);
    expect(find.text('شقة عائلية'), findsNothing);
    expect(_bar(tester).onPressed, isNull);

    await tester.tap(find.text('شاليه بحري'));
    await tester.pumpAndSettle();
    expect(_bar(tester).onPressed, isNotNull);
  });

  testWidgets('appointment: the service and its length, a day, a time — a held time cannot be picked', (tester) async {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final shape = const UnitShape(code: 'appointment', name: 'موعد', pattern: 'appointment');
    const service = OfferingItem(
      id: 11,
      source: 'price',
      label: 'قص وتصفيف',
      price: 150,
      currency: 'EGP',
      serviceId: 1,
      itemType: 'booking_appointment',
      action: 'book',
      durationMinutes: 45,
    );
    DayGridSlot slot(int h, int free) => DayGridSlot(startsAt: DateTime(day.year, day.month, day.day, h), endsAt: DateTime(day.year, day.month, day.day, h, 45), free: free);

    await tester.pumpWidget(
      _host(
        AppointmentBoardTab(businessId: 7, shape: shape, fallback: const Text('fallback')),
        [
          businessOfferingsProvider.overrideWith((ref, id) async => [service]),
          appointmentGridProvider.overrideWith((ref, p) async => DayGrid(hoursKnown: true, slots: [slot(10, 1), slot(11, 0), slot(12, 1)])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('قص وتصفيف'), findsOneWidget);
    expect(find.text('45 دقيقة'), findsOneWidget);
    expect(_bar(tester).onPressed, isNull);

    final chips = find.descendant(of: find.byType(BookingTimeGrid), matching: find.byType(InkWell));
    expect(chips, findsNWidgets(3));
    await tester.tap(chips.at(1)); // held: nothing happens
    await tester.pumpAndSettle();
    expect(_bar(tester).onPressed, isNull);

    await tester.tap(chips.at(2));
    await tester.pumpAndSettle();
    expect(_bar(tester).onPressed, isNotNull);
  });

  testWidgets('appointment: a business with no bookable service keeps the page it always had', (tester) async {
    final shape = const UnitShape(code: 'appointment', name: 'موعد', pattern: 'appointment');

    await tester.pumpWidget(
      _host(
        AppointmentBoardTab(businessId: 7, shape: shape, fallback: const Text('fallback')),
        [businessOfferingsProvider.overrideWith((ref, id) async => <OfferingItem>[])],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('fallback'), findsOneWidget);
  });

  testWidgets('course: a full group cannot be joined, a level narrows the groups, enrolling needs a group', (tester) async {
    final shape = const UnitShape(code: 'course', name: 'كورس', pattern: 'course');
    final course = CourseInfo(
      id: 5,
      serviceId: 1,
      name: 'اللغة الإنجليزية',
      price: 1600,
      groups: [
        CourseGroup(id: 1, offeringId: 5, name: 'مجموعة المساء', level: 'متوسط', scheduleText: 'الأحد والثلاثاء · 7 م', startsOn: DateTime(2026, 10, 19), seats: 8, seatsTaken: 3, seatsLeft: 5),
        CourseGroup(id: 2, offeringId: 5, name: 'مجموعة الصباح', level: 'مبتدئ', scheduleText: 'السبت والإثنين · 10 ص', startsOn: DateTime(2026, 10, 24), seats: 8, seatsTaken: 8, seatsLeft: 0),
      ],
    );

    await tester.pumpWidget(
      _host(
        CourseBoardTab(businessId: 7, shape: shape, fallback: const Text('fallback')),
        [courseDiscoveryProvider.overrideWith((ref, id) async => [course])],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مجموعة المساء'), findsOneWidget);
    expect(find.textContaining('اكتملت المقاعد'), findsOneWidget);
    expect(_bar(tester).onPressed, isNull);

    // the full group does nothing when tapped
    await tester.tap(find.text('مجموعة الصباح'));
    await tester.pumpAndSettle();
    expect(_bar(tester).onPressed, isNull);

    await tester.tap(find.text('مجموعة المساء'));
    await tester.pumpAndSettle();
    expect(_bar(tester).onPressed, isNotNull);

    // a level narrows the list
    await tester.tap(find.text('مبتدئ'));
    await tester.pumpAndSettle();
    expect(find.text('مجموعة المساء'), findsNothing);
    expect(_bar(tester).onPressed, isNull, reason: 'the chosen group left the list');
  });

  testWidgets('arrival notice: drawn when the business wrote one, nothing otherwise', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [ArrivalNoticeBanner(message: 'يجب التواجد قبل الموعد بـ 15 دقيقة.'), ArrivalNoticeBanner(message: null)],
          ),
        ),
      ),
    );

    expect(find.text('يجب التواجد قبل الموعد بـ 15 دقيقة.'), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
