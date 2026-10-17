import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/booking/data/models/relationship_summary.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _base(Map<String, dynamic> extra) => {
  'id': 7,
  'status': 'accepted',
  'price': 350,
  'business': {'id': 1, 'name': 'Hotel'},
  'user': {'id': 1, 'name': 'Hotel', 'phone': '010'},
  ...extra,
};

void main() {
  test('a guest with no account shows his own name, not the business account that stands in for him', () {
    final b = Booking.fromJson(_base({
      'guest': {'name': 'Hassan', 'phone': '01099990000'},
      'attendance': {'client': true, 'business': false},
    }));

    expect(b.isGuest, isTrue);
    expect(b.customerName, 'Hassan');
    expect(b.customerPhone, '01099990000');
    expect(b.customerId, isNull);
    expect(b.clientAttended, isTrue);
    expect(b.businessAttended, isFalse);
    expect(b.previousDealings, isNull);
  });

  test('a customer with an account carries his earlier dealings and who confirmed attendance', () {
    final b = Booking.fromJson(_base({
      'user': {'id': 9, 'name': 'Salma', 'phone': '011'},
      'guest': null,
      'attendance': {'client': false, 'business': false},
      'client_history': {'previous_dealings': 3},
    }));

    expect(b.isGuest, isFalse);
    expect(b.customerName, 'Salma');
    expect(b.customerId, 9);
    expect(b.previousDealings, 3);
    expect(b.clientAttended, isFalse);
  });

  test('an older server that says nothing about guests or attendance still parses', () {
    final b = Booking.fromJson(_base({}));

    expect(b.isGuest, isFalse);
    expect(b.clientAttended, isFalse);
    expect(b.previousDealings, isNull);
  });

  test('what a customer and a business have been through is read from the detail and from the form', () {
    final b = Booking.fromJson(_base({
      'relationship': {'total': 5, 'completed': 3, 'not_completed': 1, 'ongoing': 1, 'disputes': 2, 'open_disputes': 1},
    }));

    expect(b.relationship!.total, 5);
    expect(b.relationship!.completed, 3);
    expect(b.relationship!.notCompleted, 1);
    expect(b.relationship!.disputes, 2);
    expect(b.relationship!.openDisputes, 1);
    expect(b.relationship!.isEmpty, isFalse);

    expect(Booking.fromJson(_base({})).relationship, isNull);
    expect(const RelationshipSummary().isEmpty, isTrue);
  });
}
