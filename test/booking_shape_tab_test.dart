import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/application/booking_providers.dart';
import 'package:bim_app/features/booking/data/models/booking_form.dart';
import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/booking/presentation/widgets/booking_shape_tab.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «قسم الغرف الفردية اضيف تحتها الغرف وصورها وسعرها» — المالك، 2026-10-07: a room kind is a section with its rooms.
Map<String, dynamic> _catalogJson({bool withShape = true}) => {
  'service_id': 7,
  'shape': withShape
      ? {
          'code': 'hotel_rooms',
          'name': 'فندق',
          'pattern': 'stay',
          'settings': {'layout': 'sections', 'show_photos': true, 'show_price': true, 'offer_day_use': true, 'pick_order': 'unit_then_dates'},
        }
      : null,
  'kinds': [
    {
      'line_option_id': 1,
      'name': 'غرف مزدوجة',
      'item_type': 'booking_stay',
      'units_count': 2,
      'price': 800,
      'currency': 'EGP',
      'offering_id': 55,
      'units': [
        {
          'id': 1,
          'label': 'غرفة مزدوجة',
          'capacity': 2,
          'price': 950,
          'period_unit': 'night',
          'images': <dynamic>[],
          'modifiers': [
            {'name': 'إطلالة على المسبح', 'amount': 150},
          ],
          'day_use': {'from': '09:00', 'to': '17:00', 'price': 400},
        },
        {'id': 2, 'label': 'غرفة مزدوجة', 'capacity': 2, 'price': 800, 'period_unit': 'night', 'images': <dynamic>[], 'modifiers': <dynamic>[]},
      ],
    },
    {
      'line_option_id': 2,
      'name': 'غرف فردية',
      'item_type': 'booking_stay',
      'units_count': 1,
      'price': 500,
      'currency': 'EGP',
      'offering_id': 56,
      'units': [
        {'id': 3, 'label': 'غرفة فردية', 'capacity': 1, 'price': 500, 'period_unit': 'night', 'images': <dynamic>[], 'modifiers': <dynamic>[]},
      ],
    },
  ],
};

Widget _host(Map<String, dynamic> json) => ProviderScope(
  overrides: [unitCatalogProvider.overrideWith((ref, businessId) async => UnitCatalog.fromJson(json))],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: const SliverToBoxAdapter(child: SizedBox(height: 1)),
          ),
        ],
        body: BookingShapeTab(businessId: 9, fallback: const Center(child: Text('FALLBACK'))),
      ),
    ),
  ),
);

void main() {
  test('the catalog reads the shape and a room that carries a feature', () {
    final catalog = UnitCatalog.fromJson(_catalogJson());

    expect(catalog.shape!.sectioned, isTrue);
    expect(catalog.shape!.unitFirst, isTrue);
    expect(catalog.shape!.offerDayUse, isTrue);
    expect(catalog.kinds.first.units.first.features, ['إطلالة على المسبح']);
    expect(catalog.kinds.first.units.first.dayUse!.price, 400);
    expect(UnitCatalog.fromJson(_catalogJson(withShape: false)).shape, isNull);
  });

  test('a day use meal knows it belongs to the day use form', () {
    final night = BookingModifier.fromJson({'option_id': 1, 'name': 'نصف إقامة', 'group_id': 65, 'selection_type': 'single'});
    final day = BookingModifier.fromJson({'option_id': 2, 'name': 'غداء', 'group_id': 66, 'applies_to': 'day_use'});

    expect(night.isDayUse, isFalse);
    expect(day.isDayUse, isTrue);
  });

  test('the preview carries the lines the total is made of', () {
    final preview = BookingPreview.fromJson({
      'price': 2400,
      'price_breakdown': {
        'unit_price': 1200,
        'base_unit_price': 800,
        'periods_count': 2,
        'period_unit': 'night',
        'modifiers': [
          {'name': 'إطلالة على المسبح', 'amount': 150},
          {'name': 'نصف إقامة', 'amount': 250},
        ],
      },
    });

    expect(preview.total, 2400);
    expect(preview.baseUnitPrice, 800);
    expect(preview.periods, 2);
    expect(preview.lines.map((l) => l.amount), [150, 250]);
  });

  testWidgets('a room kind is a section with its rooms, their prices and the Day use card', (tester) async {
    await tester.pumpWidget(_host(_catalogJson()));
    await tester.pumpAndSettle();

    expect(find.text('غرف مزدوجة'), findsOneWidget, reason: 'the kind is the section header');
    expect(find.text('غرف فردية'), findsOneWidget);
    expect(find.text('950'), findsOneWidget, reason: 'the room that carries the pool view shows 800 + 150');
    expect(find.text('800'), findsOneWidget);
    expect(find.textContaining('إطلالة على المسبح'), findsWidgets);
    expect(find.text('Day use'), findsOneWidget);
    expect(find.text('FALLBACK'), findsNothing);
  });

  testWidgets('a trade without a shape keeps the priced list it always had', (tester) async {
    await tester.pumpWidget(_host(_catalogJson(withShape: false)));
    await tester.pumpAndSettle();

    expect(find.text('FALLBACK'), findsOneWidget);
    expect(find.text('950'), findsNothing);
  });
}
