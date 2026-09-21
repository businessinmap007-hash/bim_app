import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../orders/data/models/placed_order.dart';
import '../data/shipping_api.dart';

final shippingApiProvider = Provider<ShippingApi>((ref) => ShippingApi(ref.watch(apiClientProvider)));

final shippingRatesProvider = FutureProvider.autoDispose<List<ShippingRateRow>>((ref) {
  return ref.watch(shippingApiProvider).rates();
});

final shippingOrdersProvider = FutureProvider.autoDispose<List<PlacedOrder>>((ref) {
  return ref.watch(shippingApiProvider).orders();
});
