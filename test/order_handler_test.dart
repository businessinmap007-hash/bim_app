import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/orders/data/models/placed_order.dart';

void main() {
  test('an order carries who accepted it and who is preparing it', () {
    final order = PlacedOrder.fromJson({
      'id': 7,
      'prep_status': 'preparing',
      'handled_by': {
        'accepted_by': {'id': 1, 'name': 'حسن'},
        'preparing_by': {'id': 2, 'name': 'منى'},
      },
    });

    expect(order.acceptedByName, 'حسن');
    expect(order.preparingByName, 'منى');
  });

  test('a customer view has no handler names', () {
    final order = PlacedOrder.fromJson({'id': 8, 'prep_status': 'accepted'});

    expect(order.acceptedByName, isNull);
    expect(order.preparingByName, isNull);
  });
}
