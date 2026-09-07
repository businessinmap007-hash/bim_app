import '../../../core/network/api_client.dart';
import 'models/shared_cart.dart';

/// /cart/{share,join,shared/...} — the group cart. See
/// Api\V2\SharedCartController. Cash-on-arrival only: each participant pays
/// their own share when the order is picked up/delivered, so there's no
/// per-participant payment step here — just attribution and a shared total.
class SharedCartApi {
  final ApiClient _client;
  const SharedCartApi(this._client);

  /// Turns the caller's own (solo) cart for [businessId] into a shared one
  /// and returns its order id + share token.
  Future<({int orderId, String shareToken})> share(int businessId) async {
    final data =
        await _client.post('/cart/$businessId/share') as Map<String, dynamic>;
    return (
      orderId: data['order_id'] as int,
      shareToken: data['share_token'] as String,
    );
  }

  Future<SharedCart> join(String token) async {
    final data =
        await _client.post('/cart/join/$token') as Map<String, dynamic>;
    return SharedCart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<SharedCart> show(int orderId) async {
    final data =
        await _client.get('/cart/shared/$orderId') as Map<String, dynamic>;
    return SharedCart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<SharedCart> addItem({
    required int orderId,
    required String kind,
    required int offeringId,
    int qty = 1,
    int? sizeId,
    List<int> extras = const [],
  }) async {
    final data =
        await _client.post(
              '/cart/shared/$orderId/items',
              data: {
                'kind': kind,
                'offering_id': offeringId,
                'qty': qty,
                'size_id': ?sizeId,
                if (extras.isNotEmpty) 'extras': extras,
              },
            )
            as Map<String, dynamic>;
    return SharedCart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<SharedCart> updateItemQty(int orderId, int itemId, int qty) async {
    final data =
        await _client.patch(
              '/cart/shared/$orderId/items/$itemId',
              data: {'qty': qty},
            )
            as Map<String, dynamic>;
    return SharedCart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<SharedCart> removeItem(int orderId, int itemId) async {
    final data =
        await _client.delete('/cart/shared/$orderId/items/$itemId')
            as Map<String, dynamic>;
    return SharedCart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  /// Host-only: places the shared cart as a pending order.
  Future<SharedCart> checkout(
    int orderId, {
    String? fulfillmentType,
    String? address,
    String? notes,
  }) async {
    final data =
        await _client.post(
              '/cart/shared/$orderId/checkout',
              data: {
                'fulfillment_type': ?fulfillmentType,
                if (address != null && address.isNotEmpty) 'address': address,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
              },
            )
            as Map<String, dynamic>;
    return SharedCart.fromJson(data['order'] as Map<String, dynamic>);
  }

  /// Host-only: invites a friend by phone or email — an already-registered
  /// account only. Sends them a notification with the join link; never adds
  /// them as a participant directly. Returns the invited friend's name.
  Future<String> invite(int orderId, String identifier) async {
    final data =
        await _client.post(
              '/cart/shared/$orderId/invite',
              data: {'identifier': identifier},
            )
            as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return user['name'] as String? ?? '';
  }

  /// Host-only: invites members of one of the host's own contact groups at
  /// once — every member, or only the ones in [memberIds] (user ids) when
  /// the caller picked a subset instead of the whole group. Returns the
  /// names of the friends genuinely newly notified — a member already in
  /// the cart is silently skipped, not re-notified, so this list can be
  /// shorter than the selection itself.
  Future<List<String>> inviteGroup(int orderId, int groupId, {List<int>? memberIds}) async {
    final data = await _client.post(
      '/cart/shared/$orderId/invite-group/$groupId',
      data: memberIds != null ? {'member_ids': memberIds} : null,
    ) as Map<String, dynamic>;
    return (data['invited'] as List<dynamic>? ?? [])
        .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
        .toList();
  }

  /// Member-only: leaves the shared cart, removing the caller's own lines.
  Future<void> leave(int orderId) =>
      _client.post('/cart/shared/$orderId/leave');

  /// Host-only: discards the shared cart entirely.
  Future<void> cancel(int orderId) => _client.delete('/cart/shared/$orderId');
}
