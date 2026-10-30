import 'package:bim_app/desktop/lan/lan_link.dart';
import 'package:bim_app/features/inventory/data/inventory_api.dart';
import 'package:bim_app/features/inventory/data/inventory_models.dart';
import 'package:bim_app/features/inventory/presentation/inventory_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('numbers read the way the screens print them', () {
    expect(invNum(30), '30');
    expect(invNum(12.5), '12.5');
    expect(invNum(195.6521), '195.652');
    expect(InvLabels.money(349307), '349,307');
    expect(InvLabels.money(8.69), '8.69');
  });

  test('an item, its units and its coverage parse from the API shape', () {
    final item = InvItem.fromJson({
      'id': 7,
      'uuid': 'u',
      'name_ar': 'في كولا',
      'base_unit': 'علبة',
      'units': [
        {'id': 1, 'name': 'كرتونة', 'factor': '24.0000'},
        {'id': 2, 'name': 'بالتة', 'factor': 1920},
      ],
      'on_hand': '39130.0000',
      'on_hand_display': '20 بالتة و30 كرتونة و10 علبة',
      'reorder_level': null,
      'avg_cost': 8.687,
    });
    expect(item.units.last.factor, 1920);
    expect(item.onHand, 39130);
    expect(item.reorderLevel, isNull);

    final settings = InvSettings.fromJson({
      'available': true,
      'enabled': true,
      'features': [
        {'key': 'recipes', 'label': 'الوصفات', 'on': true, 'optional': false},
        {'key': 'lots_expiry', 'label': 'التشغيلات', 'on': false, 'optional': true},
      ],
      'subscription': {'status': 'grace', 'price': 300, 'writable': true},
      'is_owner': false,
      'capabilities': ['pos'],
    });
    expect(settings.has('recipes'), isTrue);
    expect(settings.has('lots_expiry'), isFalse);
    expect(settings.can('pos'), isTrue);
    expect(settings.can('purchases'), isFalse);
    expect(settings.subscription.writable, isTrue);
  });

  test('a uuid is a v4 uuid and never repeats', () {
    final a = InventoryApi.newUuid();
    final b = InventoryApi.newUuid();
    expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(a), isTrue);
    expect(a, isNot(b));
  });

  test('office-network messages open only with the key that sealed them', () async {
    final key = LanLink.randomKey();
    final sealed = await LanLink.seal(key, {'path': '/business/inventory/items', 'n': 3});
    expect(await LanLink.open(key, sealed), {'path': '/business/inventory/items', 'n': 3});
    await expectLater(LanLink.open(LanLink.randomKey(), sealed), throwsA(anything));
  });

  test('pairing: the proof and the key depend on the code shown on the main computer', () async {
    const device = '9b7f2f2e-0000-4000-8000-000000000001';
    expect(await LanLink.proof('482913', device), await LanLink.proof('482913', device));
    expect(await LanLink.proof('482913', device), isNot(await LanLink.proof('111111', device)));
    expect(await LanLink.pairingKey('482913', device), hasLength(32));
  });

  test('a cashier product carries its card photo and crop; a supplier candidate says if it is already mine', () {
    final p = InvPosProduct.fromJson({
      'owner_type': 'menu_item',
      'owner_id': 4,
      'name': 'عصير مانجو',
      'price': 25,
      'barcodes': [],
      'image': 'files/uploads/mango.png',
      'crop': {'x': 0.3, 'y': 0.6, 'zoom': 1.5},
    });
    expect(p.image, 'files/uploads/mango.png');
    expect(p.crop?.zoom, 1.5);
    expect(InvPosProduct.fromJson({'owner_type': 'retail_listing', 'owner_id': 1, 'image': '', 'crop': null}).image, isNull);

    final b = InvSupplierCandidate.fromJson({'id': 9, 'name': 'مورد الأمانة', 'trade': 'صيدلية', 'place': 'القاهرة — مدينة نصر', 'supplier_id': 3});
    expect(b.supplierId, 3);
    expect(b.place, contains('مدينة نصر'));
  });
}
