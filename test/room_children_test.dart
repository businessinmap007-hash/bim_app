import 'package:bim_app/features/booking/data/models/unit_discovery.dart';
import 'package:bim_app/features/booking/presentation/widgets/capacity_text.dart';
import 'package:bim_app/features/booking_settings/data/models/booking_settings_models.dart';
import 'package:bim_app/l10n/app_localizations_ar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a room type carries the children it takes besides its adults', () {
    expect(DiscoveredUnit.fromJson({'id': 1, 'capacity': 2, 'max_children': 2}).maxChildren, 2);
    expect(BookableItemRow.fromJson({'id': 1, 'service_id': 1, 'item_type': 'booking_stay', 'code': 'A', 'max_children': 1}).maxChildren, 1);
  });

  test('the capacity reads «2 بالغ + 2 طفل» only when the hotel named the children', () {
    final l10n = AppLocalizationsAr();
    expect(capacityText(l10n, 2, 2), 'السعة: 2 بالغ + 2 طفل');
    expect(capacityText(l10n, 2, null), 'السعة: 2');
  });
}
