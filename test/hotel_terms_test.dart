import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/booking/data/models/booking_form.dart';
import 'package:bim_app/features/booking/data/models/child_policy.dart';
import 'package:bim_app/features/booking/data/models/hotel_season.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a season goes to the server with its room and meal prices by id, and comes back the same', () {
    final s = HotelSeason(
      name: 'الصيف',
      start: DateTime(2026, 7, 1),
      end: DateTime(2026, 8, 31),
      roomChangeType: 'percent',
      roomChangeValue: 20,
      roomPrices: const {12: 1500},
      mealPrices: const {855: 150},
      minNights: 3,
    );
    final json = s.toJson();
    expect(json['start_date'], '2026-07-01');
    expect(json['room_prices'], {'12': 1500.0});

    final back = HotelSeason.fromJson({...json, 'id': 4});
    expect(back.roomPrices[12], 1500);
    expect(back.mealPrices[855], 150);
    expect(back.minNights, 3);
  });

  test('the preview reads the single rate, the cots and the non-refundable discount', () {
    final p = BookingPreview.fromJson({
      'price': 1980,
      'price_breakdown': {
        'unit_price': 1000,
        'single_occupancy': {'rooms': 1, 'percent': 80, 'per_night': 200, 'total': 400},
        'cots': {'count': 1, 'per_night': 50, 'total': 100},
        'non_refundable': {'percent': 10, 'amount': 170},
      },
    });
    expect(p.singleOccupancy!.perNight, 200);
    expect(p.cots!.count, 1);
    expect(p.nonRefundable!.amount, 170);
  });

  test('the booking reads its stay details and a non-refundable prepayment', () {
    final b = Booking.fromJson({
      'id': 9,
      'status': 'accepted',
      'stay_terms': {'rate_plan': 'non_refundable', 'cots': 1},
      'stay_details': {
        'adults': 1,
        'children': [
          {'age': 8, 'percent': 0, 'single_parent': true},
        ],
        'cots': 1,
        'meal_plans': ['نصف إقامة'],
        'gala_dinners': [
          {'date': '2026-12-31', 'name': 'عشاء رأس السنة'},
        ],
        'rate_plan': 'non_refundable',
      },
      'external_deposit': {'required': true, 'status': 'pending', 'amount': 4713, 'kind': 'prepayment'},
    });
    expect(b.ratePlan, 'non_refundable');
    expect(b.stayDetails!.children.single.singleParent, isTrue);
    expect(b.stayDetails!.galaDinners.single.name, 'عشاء رأس السنة');
    expect(b.externalDeposit.isPrepayment, isTrue);
    expect(b.externalDeposit.isPending, isTrue);
  });

  test('an extra bed is sold at a fixed price or at the third adult reduction', () {
    expect(const ChildPolicy(extraBedsMax: 1).extraBedsAllowed(2), 0);
    expect(const ChildPolicy(extraBedsMax: 1, thirdAdultReduction: 30).extraBedsAllowed(2), 2);
    expect(ChildPolicy.fromJsonOrNull({'cots_max': 1, 'cot_price': 50})!.cotPrice, 50);
  });
}
