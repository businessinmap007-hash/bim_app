import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/booking/presentation/widgets/day_use_tag.dart';
import 'package:bim_app/features/booking_settings/application/booking_settings_controller.dart';
import 'package:bim_app/features/booking_settings/data/booking_settings_api.dart';
import 'package:bim_app/features/booking_settings/data/models/room_models.dart';
import 'package:bim_app/features/booking_settings/presentation/widgets/day_use_section.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «واضف خدمة Day use للحجز فى الفنادق» — المالك، 2026-10-07.
class _FakeApi implements BookingSettingsApi {
  var current = const DayUseSettings();
  final saved = <DayUseSettings>[];

  @override
  Future<DayUseSettings> dayUse(int itemId) async => current;

  @override
  Future<DayUseSettings> saveDayUse(int itemId, DayUseSettings settings) async {
    saved.add(settings);
    current = settings;

    return settings;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, {List<Override> overrides = const []}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: home,
  ),
);

void main() {
  test('a room type tells the guest it is also sold as day use, and a booking knows it is one', () {
    final unit = DiscoveredUnit.fromJson({
      'id': 5,
      'label': 'غرفة مزدوجة',
      'day_use': {'from': '09:00', 'to': '18:00', 'price': 350},
    });
    expect(unit.dayUse?.from, '09:00');
    expect(unit.dayUse?.price, 350);
    expect(DiscoveredUnit.fromJson({'id': 6}).dayUse, isNull);

    final booking = Booking.fromJson({
      'id': 1,
      'status': 'accepted',
      'starts_at': '2026-10-10T09:00:00.000000Z',
      'ends_at': '2026-10-10T18:00:00.000000Z',
      'meta': {'day_use': true},
    });
    expect(booking.isDayUse, isTrue);
    expect(Booking.fromJson({'id': 2, 'status': 'accepted'}).isDayUse, isFalse);
  });

  testWidgets('a day-use booking shows its window', (tester) async {
    final booking = Booking.fromJson({
      'id': 1,
      'status': 'accepted',
      'starts_at': '2026-10-10T09:00:00.000000Z',
      'ends_at': '2026-10-10T18:00:00.000000Z',
      'meta': {'day_use': true},
    });
    await tester.pumpWidget(_app(Scaffold(body: DayUseTag(booking: booking))));

    expect(find.textContaining('Day use'), findsOneWidget);
    expect(find.textContaining('09:00'), findsOneWidget);
  });

  testWidgets('the hotel switches Day use on, sets a price and saves', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const Scaffold(body: SingleChildScrollView(child: DayUseSection(itemId: 5))), overrides: [bookingSettingsApiProvider.overrideWithValue(api)]));
    await tester.pumpAndSettle();

    // nothing but the switch until it is on
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '350');
    await tester.tap(find.text('حفظ Day use'));
    await tester.pumpAndSettle();

    expect(api.saved.single.enabled, isTrue);
    expect(api.saved.single.price, 350);
    expect(api.saved.single.from, '09:00');
    expect(api.saved.single.to, '18:00');
  });
}
