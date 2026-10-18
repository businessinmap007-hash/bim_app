import 'package:bim_app/features/service_requests/data/service_requests_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'a customer request carries its offers and the booking once one is chosen',
    () {
      final request = ServiceRequestModel.fromJson({
        'id': 7,
        'kind': 'ride',
        'title': 'مشوار: مدينة نصر ← 6 أكتوبر',
        'status': 'accepted',
        'budget': 190,
        'booking_id': 55,
        'params': {
          'origin': {'governorate_id': 1, 'city_id': 10, 'city': 'مدينة نصر'},
          'destination': {
            'governorate_id': 2,
            'city_id': 20,
            'city': '6 أكتوبر',
          },
          'passengers': 2,
          'distance_km': 38.4,
        },
        'offers': [
          {
            'id': 1,
            'price': 170,
            'accepts_budget': false,
            'status': 'accepted',
            'eta_minutes': 8,
            'business': {'id': 9, 'name': 'أحمد'},
          },
          {
            'id': 2,
            'price': 200,
            'accepts_budget': false,
            'status': 'rejected',
            'business': {'id': 10, 'name': 'محمود'},
          },
        ],
      });

      expect(request.origin?.city, 'مدينة نصر');
      expect(request.destination?.cityId, 20);
      expect(request.passengers, 2);
      expect(request.bookingId, 55);
      expect(request.offers.first.isAccepted, isTrue);
      expect(request.offers.first.businessName, 'أحمد');
      expect(request.offers.last.isPending, isFalse);
    },
  );

  test('a business sees only its own offer and the customer first name', () {
    final request = ServiceRequestModel.fromJson({
      'id': 8,
      'kind': 'ride',
      'title': 't',
      'status': 'open',
      'offers_count': 3,
      'requester': {'first_name': 'يوسف'},
      'my_offer': {
        'id': 4,
        'price': 150,
        'accepts_budget': true,
        'status': 'pending',
      },
      'params': <String, dynamic>{},
    });

    expect(request.requesterFirstName, 'يوسف');
    expect(request.offersCount, 3);
    expect(request.myOffer?.acceptsBudget, isTrue);
    expect(request.offers, isEmpty);
    expect(request.passengers, 1);
  });

  test('a quote that needs the distance says so', () {
    final quote = RideQuoteResult.fromJson({
      'known': false,
      'needs_distance': true,
    });

    expect(quote.needsDistance, isTrue);
    expect(quote.suggestedPrice, isNull);
  });

  test('a car request reads its words and the listing an offer points at', () {
    final request = ServiceRequestModel.fromJson({
      'id': 9,
      'kind': 'car_wanted',
      'title': 'أريد سيارة · سيدان',
      'status': 'open',
      'budget': 450000,
      'params': {
        'deal': 'rent',
        'days': 7,
        'year_min': 2018,
        'vehicle_type': {'id': 3, 'name': 'سيدان'},
        'brand': {'id': 5, 'name': 'تويوتا'},
      },
      'offers': [
        {
          'id': 1,
          'price': 430000,
          'status': 'pending',
          'item': {'id': 77, 'name': 'كورولا ٢٠٢٠', 'price': 430000},
          'business': {'id': 4, 'name': 'معرض النور'},
        },
      ],
    });

    expect(request.isCarWanted, isTrue);
    expect(request.isRentalWanted, isTrue);
    expect(request.days, 7);
    expect(request.yearMin, 2018);
    expect(request.vehicleTypeName, 'سيدان');
    expect(request.brandName, 'تويوتا');
    expect(request.offers.single.itemName, 'كورولا ٢٠٢٠');
    expect(request.offers.single.itemId, 77);
  });
}
