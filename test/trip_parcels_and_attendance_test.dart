import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/schedules/data/models/trip_parcel.dart';
import 'package:bim_app/features/schedules/data/models/trip_reservation.dart';
import 'package:bim_app/features/schedules/data/models/trip_schedule.dart';

void main() {
  test('an off-app seat carries the passenger name, the fee state and both attendance marks', () {
    final r = TripReservation.fromJson({
      'id': 1,
      'trip_schedule_id': 2,
      'status': 'blocked',
      'source': 'offline',
      'passenger_name': 'Hassan',
      'rating_visible': false,
      'client_confirmed_at': '2026-10-15T10:00:00+03:00',
    });

    expect(r.isOffline, isTrue);
    expect(r.passengerName, 'Hassan');
    expect(r.ratingVisible, isFalse);
    expect(r.clientConfirmed, isTrue);
    expect(r.carrierConfirmed, isFalse);
  });

  test('a search result says when the leg is full', () {
    final full = TripScheduleResult.fromJson({
      'schedule': {'id': 1, 'mode': 'passenger', 'scope': 'domestic', 'schedule_pattern': 'on_demand', 'origin': <String, dynamic>{}, 'destination': <String, dynamic>{}},
      'trust': {'stars_average': 4.5, 'review_count': 3, 'success_rate': 1.0},
      'remaining_capacity': 0,
      'is_full': true,
    });

    expect(full.isFull, isTrue);
    expect(full.remainingCapacity, 0);
  });

  test('a parcel never shows the code to the carrier but does to the sender', () {
    final carrierView = TripParcel.fromJson({
      'id': 5,
      'status': 'loaded',
      'description': 'box',
      'sender': {'id': 1, 'name': 'A'},
      'receiver': {'user_id': null, 'name': 'Omar', 'phone': '010'},
      'has_code': true,
      'delivery_code': null,
    });
    final senderView = TripParcel.fromJson({
      'id': 5,
      'status': 'accepted',
      'description': 'box',
      'sender': {'id': 1, 'name': 'A'},
      'receiver': {'user_id': 9, 'name': 'Mona'},
      'has_code': true,
      'delivery_code': '2954gh',
      'price': 150,
      'seats': 1,
    });

    expect(carrierView.deliveryCode, isNull);
    expect(carrierView.hasCode, isTrue);
    expect(senderView.deliveryCode, '2954gh');
    expect(senderView.receiverUserId, 9);
    expect(senderView.isOpenForSender, isTrue);
    expect(senderView.price, 150);
  });
}
