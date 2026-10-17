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
}
