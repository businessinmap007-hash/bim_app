import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/booking_settings/data/models/room_models.dart';

void main() {
  variants();
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

void variants() {
  test('two cards of one room type are told apart by the features they were priced with', () {
    final plain = DiscoveredUnit.fromJson({'id': 7, 'label': 'غرفة فردية', 'price': 1000});
    final pool = DiscoveredUnit.fromJson({'id': 7, 'label': 'غرفة فردية · إطلالة على المسبح', 'price': 1150, 'option_ids': [854]});

    expect(plain.variantOptionIds, isEmpty);
    expect(pool.variantOptionIds, [854]);
    expect(plain.selectionKey, isNot(pool.selectionKey), reason: 'tapping one card must not select the other');
  });
}
