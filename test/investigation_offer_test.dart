import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/investigations/data/models/investigation.dart';

void main() {
  group('a lab or radiology centre’s offer', () {
    test('carries its tests, its packages and the fee of a sample at home', () {
      final offer = CenterOffer.fromJson({
        'tests': [
          {'option_id': 1, 'kind': 'lab', 'name': 'CBC', 'price': 100},
        ],
        'packages': [
          {
            'id': 9,
            'name': 'باقة الفحص الشامل',
            'price': 850,
            'note': 'صيام 10 ساعات',
            'is_active': true,
            'option_ids': [1, 2],
            'tests': ['CBC', 'سكر'],
          },
        ],
        'home_fee': 50,
      });

      expect(offer.tests.single.price, 100);
      expect(offer.packages.single.price, 850);
      expect(offer.packages.single.tests, ['CBC', 'سكر']);
      expect(offer.packages.single.optionIds, [1, 2]);
      expect(offer.homeFee, 50);
      expect(const CenterOffer().homeFee, isNull);
    });

    test('an order says when the patient asked, whether the sample is at home and what a package includes', () {
      final order = InvestigationOrder.fromJson({
        'id': 1,
        'status': 'sent',
        'requested_at': '2026-10-20T10:30:00+03:00',
        'home_collection': true,
        'home_fee': 50,
        'total': 300,
        'items': [
          {'id': 1, 'kind': 'package', 'name': 'باقة', 'price': 250, 'details': 'CBC، سكر'},
          {'id': 2, 'kind': 'lab', 'name': 'CBC', 'price': null},
        ],
      });

      expect(order.requestedAt, isNotNull);
      expect(order.homeCollection, isTrue);
      expect(order.homeFee, 50);
      expect(order.items.first.isPackage, isTrue);
      expect(order.items.first.details, 'CBC، سكر');
      expect(order.items.last.details, isNull);
    });

    test('times: closed days have none', () {
      final closed = CenterTimes.fromJson({'closed': true, 'times': <String>[]});
      final open = CenterTimes.fromJson({'closed': false, 'times': ['09:00', '09:30']});

      expect(closed.closed, isTrue);
      expect(open.times, ['09:00', '09:30']);
    });
  });
}
