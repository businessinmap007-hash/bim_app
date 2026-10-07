import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/business/data/models/business_profile.dart';
import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/booking/presentation/widgets/day_use_tag.dart';
import 'package:bim_app/features/booking_settings/application/booking_settings_controller.dart';
import 'package:bim_app/features/booking_settings/data/booking_settings_api.dart';
import 'package:bim_app/features/booking_settings/data/models/room_models.dart';
import 'package:bim_app/features/booking_settings/data/models/booking_settings_models.dart';
import 'package:bim_app/features/booking_settings/presentation/screens/bookable_item_edit_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «واضف خدمة Day use للحجز فى الفنادق» — المالك، 2026-10-07.
class _FakeApi implements BookingSettingsApi {
  var current = const DayUseSettings();
  final saved = <DayUseSettings>[];

  final updated = <int>[];

  @override
  Future<DayUseSettings> dayUse(int itemId) async => current;

  @override
  Future<BookableItemRow> updateBookableItem(
    int id, {
    required int serviceId,
    required String itemType,
    required String code,
    int? lineOptionId,
    String? description,
    int? capacity,
    int? quantity,
    String? status,
  }) async {
    updated.add(id);

    return _room;
  }

  @override
  Future<DayUseSettings> saveDayUse(int itemId, DayUseSettings settings) async {
    saved.add(settings);
    current = settings;

    return settings;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _room = BookableItemRow(id: 5, serviceId: 1, itemType: 'booking_stay', code: 'A', label: 'غرفة مزدوجة', quantity: 1, isActive: true);

/// The controller's own load needs a whole API; the editor only needs the item it edits.
class _Controller extends BookingSettingsController {
  _Controller(super.api) {
    state = state.copyWith(items: [_room]);
  }
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

  test('a page says whether the business sells bookings, so it can lead with «الحجز»', () {
    final hotel = BusinessSections.fromJson({'posts': true, 'menu': false, 'services': true, 'booking': true});
    expect(hotel.booking, isTrue);
    expect(BusinessSections.fromJson({'posts': true, 'menu': false, 'services': true}).booking, isFalse);
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

  testWidgets('the room type has ONE save bar: Day use is saved with the rest, and the bar then says it is saved', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(
      const BookableItemEditScreen(itemId: 5),
      overrides: [
        bookingSettingsApiProvider.overrideWithValue(api),
        bookingSettingsControllerProvider.overrideWith((ref) => _Controller(ref.watch(bookingSettingsApiProvider))),
      ],
    ));
    await tester.pumpAndSettle();

    // nothing changed yet: the bar already says it is saved, and it is the only save button
    expect(find.text('تم الحفظ'), findsOneWidget);
    expect(find.text('حفظ'), findsNothing);

    await tester.scrollUntilVisible(find.byType(Switch), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('حفظ'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'سعر Day use'), '350');
    await tester.pump();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(api.updated, [5]);
    expect(api.saved.single.enabled, isTrue);
    expect(api.saved.single.price, 350);
    expect(api.saved.single.from, '09:00');
    expect(api.saved.single.to, '18:00');
    // saved: no snack bar, the bar just says so
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('تم الحفظ'), findsOneWidget);
  });
}
