import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/application/booking_providers.dart';
import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/booking/presentation/widgets/booking_grid_widgets.dart';
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
}
