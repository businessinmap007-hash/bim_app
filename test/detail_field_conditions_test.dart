import 'package:bim_app/features/business_menu/data/models/menu_vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

DetailField field(Map<String, dynamic> extra) => DetailField.fromJson({'id': 1, 'code': 'x', 'name': 'x', 'per_item': true, ...extra});

void main() {
  const rent = 302;

  test('a field with no condition is always asked', () {
    expect(field({}).appliesTo({}), isTrue);
    expect(field({}).appliesTo({rent}), isTrue);
  });

  test('a rental term is asked only once «إيجار» is ticked', () {
    final driver = field({'only_with_option_id': rent});

    expect(driver.appliesTo({}), isFalse);
    expect(driver.appliesTo({rent}), isTrue);
  });

  test('the mileage is a sale figure: hidden once «إيجار» is ticked', () {
    final mileage = field({'not_with_option_id': rent});

    expect(mileage.appliesTo({}), isTrue);
    expect(mileage.appliesTo({rent}), isFalse);
    expect(mileage.appliesTo({999}), isTrue);
  });
}
