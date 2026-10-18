import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/empty_returns/data/empty_returns_api.dart';

void main() {
  test(
    'an empty return reads its price, the saving, the time as Cairo digits and the driver trust',
    () {
      final offer = EmptyReturnOffer.fromJson({
        'id': 7,
        'status': 'active',
        'driver': {'id': 3, 'name': 'Captain', 'logo': null},
        'origin': {'governorate_id': 1, 'city_id': 10, 'city': 'Cairo'},
        'destination': {
          'governorate_id': 2,
          'city_id': 20,
          'city': 'Alexandria',
        },
        'departs_at': '2026-10-20T14:00:00Z',
        'price': 900,
        'reference_price': 1800,
        'saving_percent': 50,
        'currency': 'EGP',
        'seats': 3,
        'is_ahead': true,
        'exact_match': true,
        'trust': {
          'has_active_guarantee': true,
          'stars_average': 4.5,
          'review_count': 12,
        },
      });

      expect(offer.id, 7);
      expect(offer.price, 900);
      expect(offer.savingPercent, 50);
      expect(offer.exactMatch, isTrue);
      expect(offer.hasGuarantee, isTrue);
      expect(offer.reviewCount, 12);
      expect(offer.originCity, 'Cairo');
      // 14:00 UTC on 20 Oct is 17:00 in Cairo (summer time)
      expect(offer.departsAt!.hour, 17);
    },
  );

  test('a quote that needs the distance has no price', () {
    final q = EmptyReturnQuote.fromJson({
      'known': false,
      'needs_distance': true,
    });
    expect(q.known, isFalse);
    expect(q.needsDistance, isTrue);
    expect(q.suggestedPrice, isNull);
  });
}
