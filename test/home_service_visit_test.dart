import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/service_requests/data/service_requests_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a home-service request reads the signed links to its photos', () {
    final r = ServiceRequestModel.fromJson({
      'id': 5,
      'kind': 'home_service',
      'title': 'أحتاج سباك · المنصورة',
      'status': 'open',
      'photos': ['https://x/a?signature=1', 'https://x/b?signature=2'],
    });
    expect(r.isHomeService, isTrue);
    expect(r.photos, hasLength(2));
    expect(ServiceRequestModel.fromJson({'id': 6, 'kind': 'ride', 'status': 'open'}).photos, isEmpty);
  });

  test('the visit booking reads the address the customer chose and the photos', () {
    final b = Booking.fromJson({
      'id': 9,
      'status': 'accepted',
      'home_visit': {
        'address': {'line': 'برج الأطباء الدور 3، المنصورة', 'lat': 31.04, 'lng': 31.38},
        'photos': ['https://x/a'],
      },
    });
    expect(b.homeVisit!.addressLine, startsWith('برج الأطباء'));
    expect(b.homeVisit!.hasPin, isTrue);
    expect(b.homeVisit!.photos.single, 'https://x/a');
    expect(Booking.fromJson({'id': 10, 'status': 'accepted'}).homeVisit, isNull);
  });
}
