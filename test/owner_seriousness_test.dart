import 'package:bim_app/features/owner_listings/data/owner_listings_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'the requirement says who needs a deposit and whether the wallet can pay',
    () {
      final r = OwnerRequirement.fromJson({
        'required': true,
        'guarantee_ok': false,
        'needs_deposit': true,
        'deposit_amount': 100,
        'balance': 40.5,
        'min_level': {'code': 'bronze', 'name': 'برونزي'},
      });

      expect(r.needsDeposit, isTrue);
      expect(r.enoughBalance, isFalse);
      expect(r.minLevelName, 'برونزي');

      const free = OwnerRequirement();
      expect(free.required, isFalse);
      expect(free.needsDeposit, isFalse);
    },
  );

  test('a listing carries its own deposit and where it stands', () {
    final held = OwnerListing.fromJson({
      'id': 1,
      'title': 'x',
      'mine': true,
      'deposit': {'amount': 100, 'state': 'held'},
    });
    final none = OwnerListing.fromJson({
      'id': 2,
      'title': 'y',
      'deposit': null,
    });

    expect(held.depositAmount, 100);
    expect(held.depositState, 'held');
    expect(none.depositAmount, isNull);
  });

  test(
    'a listing says who may see it, and the place filter is part of the search',
    () {
      final city = OwnerListing.fromJson({
        'id': 3,
        'title': 'z',
        'visibility': 'city',
      });
      final plain = OwnerListing.fromJson({'id': 4, 'title': 'w'});

      expect(city.visibility, 'city');
      expect(plain.visibility, 'all');

      const a = OwnerBrowseQuery(governorateId: 1, cityId: 2);
      const b = OwnerBrowseQuery(governorateId: 1, cityId: 2);
      const c = OwnerBrowseQuery(governorateId: 1);
      expect(a, b);
      expect(a == c, isFalse);
    },
  );
}
