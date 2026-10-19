import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/owner_listings/data/owner_listings_api.dart';

void main() {
  test(
    'a listing reads its card, its place ids and its photos — and carries no phone',
    () {
      final l = OwnerListing.fromJson({
        'id': 5,
        'category': {'key': 'car', 'name': 'سيارة'},
        'deal': 'rent',
        'title': 'Kia Cerato',
        'price': 600,
        'price_unit': 'day',
        'currency': 'EGP',
        'governorate': 'القاهرة',
        'city': 'مدينة نصر',
        'place': {'country_id': 1, 'governorate_id': 3, 'city_id': 77},
        'cover': 'files/uploads/a.jpg',
        'images_count': 2,
        'status': 'active',
        'mine': true,
        'attributes': [
          {'key': 'year', 'label': 'سنة الصنع', 'value': '2021'},
        ],
        'raw_attributes': {'year': 2021, 'transmission': 'automatic'},
        'images': [
          {'id': 1, 'image': 'files/uploads/a.jpg'},
          {'id': 2, 'image': 'files/uploads/b.jpg'},
        ],
        'owner': {'id': 9, 'name': 'Ali'},
        'inquiries_count': 3,
      });

      expect(l.isLive, isTrue);
      expect(l.place, 'مدينة نصر · القاهرة');
      expect(l.governorateId, 3);
      expect(l.cityId, 77);
      expect(l.images.length, 2);
      expect(l.attributes.single.value, '2021');
      expect(l.rawAttributes['transmission'], 'automatic');
      expect(l.inquiriesCount, 3);
    },
  );

  test(
    'an inquiry knows who asked for the swap and shows the number only once revealed',
    () {
      final asked = OwnerInquiry.fromJson({
        'id': 1,
        'status': 'reveal_requested',
        'role': 'seller',
        'listing': {
          'id': 5,
          'title': 'Kia',
          'price': 640000,
          'deal': 'sale',
          'status': 'active',
        },
        'other': {'id': 2, 'name': 'Buyer'},
        'reveal': {
          'requested_by_me': false,
          'requested_by_other': true,
          'fee_total': 500,
          'my_share': 250,
          'payer': 'split',
        },
        'other_phone': null,
      });
      expect(asked.requestedByOther, isTrue);
      expect(asked.revealed, isFalse);
      expect(asked.otherPhone, isNull);
      expect(asked.myShare, 250);
      expect(asked.isBuyer, isFalse);

      final done = OwnerInquiry.fromJson({
        'id': 1,
        'status': 'revealed',
        'role': 'buyer',
        'listing': {'id': 5, 'title': 'Kia'},
        'other': {'id': 3, 'name': 'Seller'},
        'reveal': {
          'requested_by_me': false,
          'requested_by_other': false,
          'fee_total': 500,
          'my_share': 250,
        },
        'other_phone': '01012345678',
      });
      expect(done.revealed, isTrue);
      expect(done.otherPhone, '01012345678');
    },
  );

  test(
    'a field applies to the deals it names — the mileage of a rented car is not asked',
    () {
      final f = OwnerField.fromJson({
        'key': 'mileage_km',
        'type': 'int',
        'label': 'Mileage',
        'deals': ['sale', 'swap'],
      });
      expect(f.appliesTo('sale'), isTrue);
      expect(f.appliesTo('rent'), isFalse);

      final g = OwnerField.fromJson({
        'key': 'year',
        'type': 'int',
        'label': 'Year',
      });
      expect(g.appliesTo('rent'), isTrue);
    },
  );
}
