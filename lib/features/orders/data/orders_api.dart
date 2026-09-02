import '../../../core/network/api_client.dart';
import 'models/placed_order.dart';

class OrdersPage {
  final List<PlacedOrder> items;
  final bool hasMore;
  const OrdersPage({required this.items, required this.hasMore});
}

typedef ReorderResult = ({int added, List<int> skipped, int? cartOrderId});

/// /orders — the customer's placed-order history. See Api\V2\OrderController.
/// `index` is a bare Laravel resource collection (no {success,data} envelope,
/// pagination under `meta`), same shape PostsApi reads; `show`/`cancel` are a
/// single JsonResource, which Laravel wraps as `{data:{...}}` — ApiClient.get/
/// post already strip that one `data` layer, so those return the order fields
/// directly (no extra nesting), unlike bookings' `{data:{booking:{...}}}`.
class OrdersApi {
  final ApiClient _client;
  const OrdersApi(this._client);

  Future<OrdersPage> list({String? status, int page = 1, int perPage = 20}) async {
    final body = await _client.getForBody(
      '/orders',
      query: {
        if (status != null) 'status': status,
        'page': page,
        'per_page': perPage,
      },
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => PlacedOrder.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return OrdersPage(items: items, hasMore: currentPage < lastPage);
  }

  Future<PlacedOrder> show(int id) async {
    final data = await _client.get('/orders/$id') as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  Future<PlacedOrder> cancel(int id, {String? reason}) async {
    final data = await _client.post(
      '/orders/$id/cancel',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    ) as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  Future<ReorderResult> reorder(int id) async {
    final data = await _client.post('/orders/$id/reorder') as Map<String, dynamic>;
    return (
      added: (data['added'] as num?)?.toInt() ?? 0,
      skipped: (data['skipped'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
      cartOrderId: data['cart_order_id'] as int?,
    );
  }
}
