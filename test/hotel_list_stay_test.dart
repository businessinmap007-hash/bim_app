import 'package:bim_app/features/discovery/data/models/business_summary.dart';
import 'package:bim_app/features/discovery/application/discovery_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a hotel row carries its stars, a shop row carries none', () {
    final hotel = BusinessSummary.fromJson({
      'id': 1,
      'name': 'h',
      'stay_class': {'id': 3, 'name': 'خمس نجوم'},
    });
    final shop = BusinessSummary.fromJson({'id': 2, 'name': 's'});

    expect(hotel.stayClass, 'خمس نجوم');
    expect(shop.stayClass, isNull);
  });

  test('the list state knows its stay and clears it', () {
    final stay = const BusinessListState().copyWith(
      checkIn: DateTime(2026, 10, 20),
      checkOut: DateTime(2026, 10, 25),
    );

    expect(stay.hasStay, isTrue);
    expect(stay.copyWith(clearStay: true).hasStay, isFalse);
  });
}
