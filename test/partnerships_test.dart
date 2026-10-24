import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/partnerships/data/models/partnership.dart';
import 'package:bim_app/features/partnerships/presentation/widgets/partnership_widgets.dart';
import 'package:bim_app/features/booking/presentation/widgets/partner_rooms_section.dart';
import 'package:bim_app/l10n/app_localizations.dart';

void main() {
  test('a partnership reads its role, its other side and whether it waits for me', () {
    final p = Partnership.fromJson({
      'id': 4,
      'role': 'partner',
      'status': 'pending',
      'relationship_type': 'agency',
      'other': {'id': 9, 'name': 'فندق'},
      'terms': {'note': 'موسم الصيف'},
      'awaiting_my_answer': true,
    });

    expect(p.isOwner, isFalse);
    expect(p.awaitingMyAnswer, isTrue);
    expect(p.other?.name, 'فندق');
    expect(p.note, 'موسم الصيف');
    expect(p.isOpen, isTrue);
  });

  test('an allocation carries the room card, the contract price and the partner\'s final price', () {
    final a = Allocation.fromJson({
      'id': 1,
      'partnership_id': 4,
      'status': 'active',
      'quantity_total': 5,
      'quantity_available': 3,
      'contract_price': 800,
      'markup_type': 'fixed',
      'markup_value': 200,
      'final_price': 1000,
      'room': {
        'unit_id': 7,
        'label': 'شاليه — 101',
        'kind': 'شاليه',
        'images': [
          {'image': 'a.png'},
        ],
        'features': ['مطبخ مجهز'],
      },
    });

    expect(a.finalPrice, 1000);
    expect(a.contractPrice, 800);
    expect(a.room?.features, ['مطبخ مجهز']);
    expect(a.room?.images, hasLength(1));
  });

  test('the customer\'s partner room has a price and a hotel, and no contract fields', () {
    final catalog = UnitCatalog.fromJson({
      'kinds': [],
      'partner_rooms': [
        {
          'allocation_id': 2,
          'bookable_id': 7,
          'service_id': 3,
          'item_type': 'booking_stay',
          'label': 'شاليه',
          'price': 1000,
          'from': {'id': 1, 'name': 'تيوليب'},
          'available_quantity': 3,
          'available': true,
        },
      ],
    });

    expect(catalog.partnerRooms, hasLength(1));
    expect(catalog.partnerRooms.first.price, 1000);
    expect(catalog.partnerRooms.first.fromName, 'تيوليب');
    expect(catalog.hasUnits, isFalse);
  });

  testWidgets('the partner rooms section shows each room with the hotel and the price', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: PartnerRoomsSection(
            businessId: 1,
            rooms: [
              PartnerRoom(allocationId: 2, unitId: 7, serviceId: 3, itemType: 'booking_stay', label: 'شاليه', price: 1000, fromName: 'تيوليب', availableQuantity: 3),
            ],
          ),
        ),
      ),
    );

    expect(find.text('شاليه'), findsOneWidget);
    expect(find.textContaining('تيوليب'), findsOneWidget);
    expect(find.textContaining('1000'), findsOneWidget);
  });

  test('money prints whole amounts without decimals', () {
    expect(money(1000, 'EGP'), '1000 EGP');
    expect(money(950.5, 'EGP'), '950.50 EGP');
  });

  test('a hold the guest still has reads its dates and its minutes, and a room promised to a partner says so', () {
    final unit = DiscoveredUnit.fromJson({
      'id': 7,
      'label': 'غرفة',
      'available': false,
      'held_for_partner': true,
      'my_hold': {'id': 3, 'starts_at': '2026-11-10 00:00:00', 'ends_at': '2026-11-12 00:00:00', 'quantity': 1, 'seconds_left': 540},
    });

    expect(unit.heldForPartner, isTrue);
    expect(unit.myHold?.startsAt, DateTime(2026, 11, 10));
    expect(unit.myHold?.isLive, isTrue);
    expect(unit.myHold?.leftLabel, matches(RegExp(r'^0[89]:\d\d$')));
    expect(DiscoveredUnit.fromJson({'id': 8}).myHold, isNull);
  });

  test('a request to release a room reads the room and the dates', () {
    final r = ReleaseRequest.fromJson({'id': 4, 'room': 'شاليه', 'starts_at': '2026-11-10 00:00:00', 'ends_at': '2026-11-12 00:00:00', 'quantity': 1});

    expect(r.room, 'شاليه');
    expect(r.endsAt.difference(r.startsAt).inDays, 2);
  });
}
