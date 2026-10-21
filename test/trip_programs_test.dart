import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/business/data/models/business_profile.dart';
import 'package:bim_app/features/trip_programs/application/trip_programs_providers.dart';
import 'package:bim_app/features/trip_programs/data/models/trip_program.dart';
import 'package:bim_app/features/trip_programs/presentation/screens/trip_program_view_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Map<String, dynamic> _json({required bool roomAvailable}) => {
  'id': 5,
  'business_id': 9,
  'title': 'الجلالة ٣ ليالٍ',
  'summary': 'رحلة عائلية',
  'status': 'published',
  'days': [
    {
      'id': 1,
      'title': 'الوصول',
      'items': [
        {'id': 1, 'kind': 'text', 'body': 'استقبال الثامنة صباحًا'},
        {
          'id': 2,
          'kind': 'room',
          'body': null,
          'room_available': roomAvailable,
          'room': roomAvailable
              ? {
                  'allocation_id': 3,
                  'bookable_id': 7,
                  'service_id': 1,
                  'item_type': 'booking_stay',
                  'label': 'شاليه بثلاث غرف',
                  'features': ['مطبخ مجهز'],
                  'price': 4200,
                  'currency': 'EGP',
                  'from': {'id': 1, 'name': 'تيوليب'},
                  'available_quantity': 3,
                  'available': true,
                }
              : null,
        },
      ],
    },
  ],
};

Widget _app(TripProgram program) => ProviderScope(
  overrides: [publishedTripProgramProvider.overrideWith((ref, key) async => program)],
  child: MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const TripProgramViewScreen(businessId: 9, programId: 5),
  ),
);

void main() {
  test('a programme reads its days, its words and its room card with the company\'s price', () {
    final p = TripProgram.fromJson(_json(roomAvailable: true));

    expect(p.isPublished, isTrue);
    expect(p.days.single.items.map((i) => i.kind), ['text', 'room']);
    expect(p.days.single.items[1].room?.price, 4200);
    expect(p.days.single.items[1].room?.fromName, 'تيوليب');
  });

  test('the page sections carry the partner rooms and programmes flags', () {
    final s = BusinessSections.fromJson({'booking': true, 'partner_rooms': true, 'programs': true});

    expect(s.partnerRooms, isTrue);
    expect(s.programs, isTrue);
    expect(BusinessSections.fromJson(const {}).programs, isFalse);
  });

  testWidgets('the reader sees the day, the words and the room with a book button', (tester) async {
    await tester.pumpWidget(_app(TripProgram.fromJson(_json(roomAvailable: true))));
    await tester.pumpAndSettle();

    expect(find.text('الجلالة ٣ ليالٍ'), findsOneWidget);
    expect(find.text('استقبال الثامنة صباحًا'), findsOneWidget);
    expect(find.text('شاليه بثلاث غرف'), findsOneWidget);
    expect(find.text('مطبخ مجهز'), findsOneWidget);
    expect(find.textContaining('4200'), findsOneWidget);
    expect(find.text('احجز هذه الغرفة'), findsOneWidget);
  });

  testWidgets('a room the hotel stopped leaves a note instead of a card', (tester) async {
    await tester.pumpWidget(_app(TripProgram.fromJson(_json(roomAvailable: false))));
    await tester.pumpAndSettle();

    expect(find.text('استقبال الثامنة صباحًا'), findsOneWidget);
    expect(find.text('الغرفة لم تعد متاحة'), findsOneWidget);
    expect(find.text('احجز هذه الغرفة'), findsNothing);
  });
}
