import 'package:bim_app/features/hotel_rooms/data/hotel_rooms_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'a room carries its hotel, its class and the partners offers; the cheaper partner is spotted',
    () {
      final room = HotelRoom.fromJson({
        'hotel': {
          'id': 5,
          'name': 'فندق النخيل',
          'class': {'id': 3, 'name': 'خمس نجوم'},
          'governorate': 'القاهرة',
          'city': 'مدينة نصر',
        },
        'room': {
          'unit_id': 11,
          'name': 'غرفة مزدوجة',
          'capacity': 2,
          'image': {'id': 1, 'image': 'rooms/a.jpg'},
        },
        'price': 2000,
        'best_price': 1650,
        'currency': 'EGP',
        'partner_offers': [
          {
            'allocation_id': 9,
            'seller': {'id': 7, 'name': 'وكالة السفر'},
            'price': 1650,
            'available_quantity': 3,
          },
        ],
      });

      expect(room.hotelName, 'فندق النخيل');
      expect(room.className, 'خمس نجوم');
      expect(room.city, 'مدينة نصر');
      expect(room.partnerOffers.single.sellerName, 'وكالة السفر');
      expect(room.cheaperPartner?.price, 1650);
      expect(room.bestPrice, 1650);
    },
  );

  test(
    'a partner offer that is dearer than the hotel is not called cheaper',
    () {
      final room = HotelRoom.fromJson({
        'hotel': {'id': 5, 'name': 'h'},
        'room': {'unit_id': 1, 'name': 'r'},
        'price': 1000,
        'partner_offers': [
          {'allocation_id': 1, 'price': 1200},
        ],
      });

      expect(room.cheaperPartner, isNull);
    },
  );

  test(
    'the query counts its filters and clearing the governorate clears the city',
    () {
      const q = HotelRoomQuery(
        classId: 1,
        governorateId: 2,
        cityId: 3,
        priceMax: 2000,
      );

      expect(q.activeCount, 4);
      expect(q.copyWith(clearGovernorate: true).cityId, isNull);
      expect(q.copyWith(clearGovernorate: true).classId, 1);
      expect(const HotelRoomQuery().activeCount, 0);
      final stay = HotelRoomQuery(
        checkIn: DateTime(2026, 11, 1),
        checkOut: DateTime(2026, 11, 4),
      );
      expect(stay.hasDates, isTrue);
      expect(stay.activeCount, 1);
      expect(stay.copyWith(clearDates: true).hasDates, isFalse);
      expect(
        const HotelRoomQuery(classId: 1) == const HotelRoomQuery(classId: 1),
        isTrue,
      );
    },
  );

  test(
    'a room carries what a booking of it needs and, with dates, the stays total',
    () {
      final room = HotelRoom.fromJson({
        'hotel': {'id': 5, 'name': 'h'},
        'room': {
          'unit_id': 11,
          'offering_id': 40,
          'service_id': 2,
          'item_type': 'booking_stay',
          'name': 'r',
        },
        'price': 1000,
        'total': 3000,
        'nights': 3,
      });

      expect(room.offeringId, 40);
      expect(room.serviceId, 2);
      expect(room.itemType, 'booking_stay');
      expect(room.total, 3000);
      expect(room.nights, 3);
    },
  );
}
