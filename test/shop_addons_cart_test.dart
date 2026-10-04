import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/business_menu/data/models/shop_addons.dart';
import 'package:bim_app/features/business_menu/data/models/menu_item.dart';
import 'package:bim_app/features/cart/data/models/cart_models.dart';

/// «سمك 450 + صينية 150 = 600 فى الفاتورة» — a service is its own line, priced once by the shop per
/// unit bought. The shop's price list keeps a service it does not offer as `price: null`.
void main() {
  test('a cart line keeps the item and each service apart', () {
    final item = CartItem.fromJson({
      'id': 1,
      'kind': 'menu',
      'offering_id': 9,
      'name': 'جمبري',
      'qty': 2,
      'price': 400,
      'total_price': 800,
      'base_price': 300,
      'options': {'extras': ['سينية بالفرن']},
      'extras_detail': [
        {'name': 'سينية بالفرن', 'unit_price': 100, 'qty': 1, 'total': 200},
      ],
    });

    expect(item.baseTotal, 600, reason: '2 kg of fish');
    expect(item.extrasDetail.single.total, 200, reason: '2 kg of baked tray');
    expect(item.totalPrice, item.baseTotal + item.extrasDetail.single.total);
  });

  test('a line from an older server reads as the item alone', () {
    final item = CartItem.fromJson({'id': 1, 'name': 'جمبري', 'qty': 2, 'price': 300, 'total_price': 600});

    expect(item.extrasDetail, isEmpty);
    expect(item.baseTotal, 600);
  });

  test('the shop price list keeps a service it does not offer as null', () {
    final groups = ShopAddonGroup.listFrom([
      {
        'group_id': 5,
        'group_name': 'طريقة الطهي',
        'options': [
          {'id': 1, 'name': 'نيء (بدون طهي)', 'price': null},
          {'id': 2, 'name': 'مشوي', 'price': 50},
          {'id': 3, 'name': 'مقلي', 'price': 80.5},
        ],
      },
    ]);

    expect(groups.single.options.map((o) => o.price), [null, 50.0, 80.5]);
  });

  test('an item reads which of the shop services it offers (a restaurant grill yes, its salad no)', () {
    final grill = AddonChoice.fromJson({'group_id': 5, 'group_name': 'طريقة الطهي', 'enabled': true});
    final salad = AddonChoice.fromJson({'group_id': 5, 'group_name': 'طريقة الطهي'});

    expect(grill.enabled, isTrue);
    expect(salad.enabled, isFalse, reason: 'nothing said = not offered');
  });
}
