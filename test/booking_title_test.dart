import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/data/models/booking.dart';

void main() {
  Map<String, dynamic> json({String? title}) => {
    'id': 1,
    'status': 'pending',
    'price': '300.00',
    'service': {'name_ar': 'حجز', 'name_en': 'Booking'},
    'title': ?title,
  };

  test('the booking is named by the server title when there is one', () {
    expect(Booking.fromJson(json(title: 'Bone X-ray')).serviceName('en'), 'Bone X-ray');
  });

  test('without a title it falls back to the service name', () {
    expect(Booking.fromJson(json()).serviceName('en'), 'Booking');
    expect(Booking.fromJson(json(title: '  ')).serviceName('ar'), 'حجز');
  });
}
