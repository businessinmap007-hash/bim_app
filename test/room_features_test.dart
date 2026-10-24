import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/booking_settings/data/models/room_models.dart';

void main() {
  test('a numbered room carries its own features and a stay sees which free rooms match what the guest asked', () {
    final room = RoomRow.fromJson({'id': 1, 'number': '102', 'feature_ids': [854], 'features': ['إطلالة على المسبح']});
    expect(room.featureIds, [854]);
    expect(room.features, ['إطلالة على المسبح']);
    expect(room.matches, isTrue, reason: 'a room outside a stay is never «not matching»');

    final stay = BookingRoomsPayload.fromJson({
      'uses_rooms': true,
      'requested': ['إطلالة على المسبح'],
      'free': [
        {'id': 1, 'number': '102', 'matches': true},
        {'id': 2, 'number': '101', 'matches': false},
      ],
    });
    expect(stay.requested, ['إطلالة على المسبح']);
    expect(stay.free.map((r) => r.matches), [true, false]);
  });
}
