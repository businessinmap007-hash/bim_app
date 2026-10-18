import 'package:bim_app/features/booking_settings/data/models/booking_settings_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> json(Map<String, dynamic> extra) => {
    'id': 1,
    'service': {'id': 2},
    'item_type': 'booking_stay',
    'code': 'X',
    'label': 'X',
    'quantity': 1,
    ...extra,
  };

  test('a car owner\'s unit is a car, not a hotel room, and carries its discounts', () {
    final row = BookableItemRow.fromJson(json({
      'unit_noun': 'car',
      'stay_discounts': {'weekly_percent': 10, 'monthly_percent': 22.5},
    }));

    expect(row.unitNoun, 'car');
    expect(row.isHotelRoom, isFalse);
    expect(row.weeklyDiscount, 10);
    expect(row.monthlyDiscount, 22.5);
  });

  test('a hotel room keeps Day use and a unit with no data reads as a plain unit', () {
    expect(BookableItemRow.fromJson(json({'unit_noun': 'room'})).isHotelRoom, isTrue);

    final plain = BookableItemRow.fromJson(json({}));
    expect(plain.unitNoun, 'unit');
    expect(plain.weeklyDiscount, 0);
  });
}
