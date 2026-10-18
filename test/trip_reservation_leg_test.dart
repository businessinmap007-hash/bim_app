import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/schedules/data/models/trip_reservation.dart';

void main() {
  Map<String, dynamic> row(Map<String, dynamic> leg) => {
    'id': 1,
    'trip_schedule_id': 9,
    'units': 1,
    'status': 'pending',
    'currency': 'EGP',
    'business': {'id': 4, 'name': 'Captain Ali'},
    'leg': leg,
  };

  test('a reservation reads its line, its day and the carrier', () {
    final r = TripReservation.fromJson(
      row({
        'id': 9,
        'mode': 'limousine',
        'is_return_leg': true,
        'origin': {
          'governorate': 'Cairo',
          'city': 'Cairo International Airport',
        },
        'destination': {'governorate': 'Damietta', 'city': null},
        'pattern': 'one_off',
        'trip_date': '2026-10-20',
        'departure_time': '14:30:00',
      }),
    );

    expect(r.businessName, 'Captain Ali');
    expect(r.leg!.isReturnLeg, isTrue);
    expect(r.leg!.originLabel, 'Cairo International Airport');
    // no city on that end: the governorate stands in
    expect(r.leg!.destinationLabel, 'Damietta');
    expect(r.leg!.departsAt, DateTime(2026, 10, 20, 14, 30));
  });

  test('a weekly leg has a weekday and a time but no single date', () {
    final r = TripReservation.fromJson(
      row({
        'id': 9,
        'mode': 'passenger',
        'is_return_leg': false,
        'origin': {'governorate': 'Cairo', 'city': null},
        'destination': {'governorate': 'Assiut', 'city': null},
        'pattern': 'weekly',
        'day_of_week': 2,
        'departure_time': '09:00:00',
      }),
    );

    expect(r.leg!.departsAt, isNull);
    expect(r.leg!.dayOfWeek, 2);
    expect(r.leg!.departureTime, '09:00:00');
  });

  test('an old payload without a leg still reads', () {
    final r = TripReservation.fromJson({
      'id': 1,
      'trip_schedule_id': 9,
      'units': 1,
      'status': 'pending',
      'currency': 'EGP',
    });
    expect(r.leg, isNull);
    expect(r.businessName, isNull);
  });
}
