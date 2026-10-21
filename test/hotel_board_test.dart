import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/hotel_board/application/hotel_board_providers.dart';
import 'package:bim_app/features/hotel_board/data/models/occupancy_board.dart';
import 'package:bim_app/features/hotel_board/presentation/screens/hotel_board_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Map<String, dynamic> _json() {
  final now = DateTime.now();
  final m = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  String day(int d) => '$m-${d.toString().padLeft(2, '0')} 14:00:00';

  return {
    'month': m,
    'days': 30,
    'first_weekday': DateTime(now.year, now.month, 1).weekday % 7,
    'kinds': [
      {
        'name': 'شاليه',
        'units': [
          {
            'id': 1,
            'label': 'شاليه — ٣ غرف',
            'stock': 5,
            'guest_scope': 'locals',
            'held_for_partners': 1,
            'booked': [for (var i = 0; i < 30; i++) (i == 9 || i == 10) ? (i == 10 ? 5 : 2) : 0],
            'via_partner': [for (var i = 0; i < 30; i++) i == 9 ? 1 : 0],
            'bookings': [
              {'id': 1, 'status': 'accepted', 'starts_at': day(10), 'ends_at': day(12), 'quantity': 2, 'guest': 'منى', 'source': 'partner', 'partner': 'النيل للسياحة', 'room_number': null, 'guest_origin': 'local'},
            ],
          },
        ],
      },
    ],
  };
}

void main() {
  test('a stay holds the nights from check-in up to, not including, check-out', () {
    final b = OccBooking.fromJson({'id': 1, 'status': 'accepted', 'starts_at': '2026-11-10 14:00:00', 'ends_at': '2026-11-12 12:00:00', 'quantity': 1});

    expect(b.holds(DateTime(2026, 11, 10)), isTrue);
    expect(b.holds(DateTime(2026, 11, 11)), isTrue);
    expect(b.holds(DateTime(2026, 11, 12)), isFalse);
    expect(b.holds(DateTime(2026, 11, 9)), isFalse);
  });

  testWidgets('the board shows the room type, its scope, the held rooms and the taken days; a tap lists who holds a day', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [hotelBoardProvider.overrideWith((ref, month) async => OccupancyBoardData.fromJson(_json()))],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HotelBoardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('شاليه — ٣ غرف'), findsOneWidget);
    expect(find.text('للمصريين والمقيمين فقط'), findsOneWidget);
    expect(find.textContaining('محجوزة لشركاء'), findsOneWidget);
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('5/5'), findsOneWidget);

    await tester.tap(find.text('5/5'));
    await tester.pumpAndSettle();

    expect(find.textContaining('منى'), findsOneWidget);
    expect(find.textContaining('النيل للسياحة'), findsOneWidget);
  });
}
