import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/data/models/booking.dart';

void main() {
  group('the deposit taken outside the platform', () {
    test('is pending until the business says it arrived, then received or waived', () {
      final pending = ExternalDeposit.fromJson({'required': true, 'status': 'pending', 'amount': 200});
      final received = ExternalDeposit.fromJson({'required': true, 'status': 'received', 'amount': 200, 'method': 'cash'});
      final waived = ExternalDeposit.fromJson({'required': true, 'status': 'waived', 'amount': 200});
      const none = ExternalDeposit();

      expect(pending.isPending, isTrue);
      expect(pending.amount, 200);
      expect(received.isReceived, isTrue);
      expect(received.isPending, isFalse);
      expect(received.method, 'cash');
      expect(waived.isWaived, isTrue);
      expect(none.isPending, isFalse);
    });

    test('a booking carries it, and a booking of a business with no such term does not owe one', () {
      final owed = Booking.fromJson({
        'id': 1,
        'business_id': 2,
        'status': 'accepted',
        'external_deposit': {'required': true, 'status': 'pending', 'amount': 150},
      });
      final free = Booking.fromJson({'id': 2, 'business_id': 2, 'status': 'accepted'});

      expect(owed.externalDeposit.isPending, isTrue);
      expect(free.externalDeposit.isPending, isFalse);
    });
  });
}
