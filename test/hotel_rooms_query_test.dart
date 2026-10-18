import 'package:bim_app/features/hotel_rooms/data/hotel_rooms_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('switching governorate drops the old governorates city', () {
    const q = HotelRoomQuery(governorateId: 1, cityId: 10);

    final moved = q.copyWith(governorateId: 2, clearCity: true);

    expect(moved.governorateId, 2);
    expect(moved.cityId, isNull);
  });
}
