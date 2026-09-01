import '../../../core/network/api_client.dart';
import 'models/cart_models.dart';

/// /cart — the customer's own draft orders, one per business (Phase 3d).
/// See Api\V2\CartController.
class CartApi {
  final ApiClient _client;
  const CartApi(this._client);

  /// All open carts, grouped by business, plus the cross-cart totals.
  Future<List<Cart>> index() async {
    final data = await _client.get('/cart') as Map<String, dynamic>;
    final carts = data['carts'] as List<dynamic>? ?? [];
    return carts.map((e) => Cart.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Cart> addItem({
    required String kind,
    required int offeringId,
    int qty = 1,
    int? sizeId,
    List<int> extras = const [],
  }) async {
    final data = await _client.post(
      '/cart/items',
      data: {
        'kind': kind,
        'offering_id': offeringId,
        'qty': qty,
        if (sizeId != null) 'size_id': sizeId,
        if (extras.isNotEmpty) 'extras': extras,
      },
    ) as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<Cart> updateItemQty(int itemId, int qty) async {
    final data = await _client.patch('/cart/items/$itemId', data: {'qty': qty}) as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<Cart> removeItem(int itemId) async {
    final data = await _client.delete('/cart/items/$itemId') as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  /// Places one business's cart as a pending order.
  Future<Cart> checkout(
    int businessId, {
    String? fulfillmentType,
    int? addressId,
    String? address,
    double? lat,
    double? lng,
    String? notes,
    String? paymentMethod,
  }) async {
    final data = await _client.post(
      '/cart/$businessId/checkout',
      data: {
        if (fulfillmentType != null) 'fulfillment_type': fulfillmentType,
        if (addressId != null) 'address_id': addressId,
        if (address != null && address.isNotEmpty) 'address': address,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (paymentMethod != null) 'payment_method': paymentMethod,
      },
    ) as Map<String, dynamic>;
    return Cart.fromJson(data['order'] as Map<String, dynamic>);
  }
}
