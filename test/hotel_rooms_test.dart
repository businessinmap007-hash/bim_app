import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/booking_settings/application/booking_settings_controller.dart';
import 'package:bim_app/features/booking_settings/data/booking_settings_api.dart';
import 'package:bim_app/features/booking_settings/data/models/booking_settings_models.dart';
import 'package:bim_app/features/booking_settings/data/models/room_models.dart';
import 'package:bim_app/features/booking_settings/presentation/widgets/bookable_rooms_section.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «العدد والرقم لكل غرفة يكون لدى الفندق فقط ويظهر عند بداية التنفيذ» — المالك، 2026-10-07.
class _FakeApi implements BookingSettingsApi {
  var current = const RoomsPayload(rooms: [RoomRow(id: 1, number: '101'), RoomRow(id: 2, number: '102')], openCount: 2);
  final added = <List<String>>[];

  @override
  Future<RoomsPayload> addRooms(int itemId, List<String> numbers) async {
    added.add(numbers);
    current = RoomsPayload(
      rooms: [...current.rooms, for (var i = 0; i < numbers.length; i++) RoomRow(id: 10 + i, number: numbers[i])],
      openCount: current.openCount + numbers.length,
    );

    return current;
  }

  @override
  Future<List<BookableItemRow>> bookableItems() async => const [];

  @override
  Future<RoomsPayload> rooms(int itemId) async => current;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('room numbers: lists, ranges and plain names', () {
    expect(parseRoomNumbers('101، 102 103'), ['101', '102', '103']);
    expect(parseRoomNumbers('110-113'), ['110', '111', '112', '113']);
    expect(parseRoomNumbers('A1, س301, 5–6, 101, 101'), ['A1', 'س301', '5', '6', '101']);
    expect(parseRoomNumbers('  '), isEmpty);
    // a reversed or absurd range is not expanded
    expect(parseRoomNumbers('9-3'), ['9-3']);
  });

  test('a booking reads its room number and whether it is a hotel stay', () {
    final stay = Booking.fromJson({
      'id': 1,
      'status': 'in_progress',
      'bookable': {'item_type': 'booking_stay', 'title': 'غرفة مزدوجة'},
      'room': {'id': 7, 'number': '305'},
    });

    expect(stay.bookableItemType, 'booking_stay');
    expect(stay.room?.number, '305');
    expect(Booking.fromJson({'id': 2, 'status': 'accepted'}).room, isNull);
  });

  testWidgets('the hotel sees its rooms and adds a range in one go', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookingSettingsApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const Scaffold(body: SingleChildScrollView(child: BookableRoomsSection(itemId: 5))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الغرف'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
    expect(find.text('2 متاحة'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '110-112');
    await tester.tap(find.text('أضف'));
    await tester.pumpAndSettle();

    expect(api.added.single, ['110', '111', '112']);
    expect(find.text('111'), findsOneWidget);
    expect(find.text('5 متاحة'), findsOneWidget);
  });
}
