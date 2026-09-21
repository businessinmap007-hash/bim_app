import '../../../core/network/api_client.dart';
import 'models/order_reports.dart';
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

  /// A delegated staff member names the business they act for via
  /// `business_id` (BusinessMember middleware); the owner passes null.
  static String _biz(String path, int? businessId) =>
      businessId == null ? path : '$path${path.contains('?') ? '&' : '?'}business_id=$businessId';

  Future<OrdersPage> list({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final body = await _client.getForBody(
      '/orders',
      query: {'status': ?status, 'page': page, 'per_page': perPage},
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
    final data =
        await _client.post(
              '/orders/$id/cancel',
              data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
            )
            as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  /// The customer attests they paid the order in cash — protective evidence
  /// only, independent of the business's/driver's own confirm-payment calls.
  Future<PlacedOrder> confirmPayment(int id) async {
    final data = await _client.post('/orders/$id/confirm-payment') as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  /// Ticks/unticks "I trust" toward another party of the order. The
  /// merchant's calls go through the business-scoped route so a delegated
  /// staff member acts as the business.
  Future<bool> setTrust(int orderId, String party, bool trusted, {bool asBusiness = false, int? businessId}) async {
    final path = asBusiness ? _biz('/business/orders/$orderId/trust', businessId) : '/orders/$orderId/trust';
    final data = await _client.post(path, data: {'party': party, 'trusted': trusted}) as Map<String, dynamic>;
    return data['trusted'] as bool? ?? trusted;
  }

  /// The customer answers the courier's proposed delivery fee.
  Future<void> answerDeliveryFee(int id, {required bool accept}) =>
      _client.post('/orders/$id/delivery-fee/${accept ? 'accept' : 'decline'}');

  Future<ReorderResult> reorder(int id) async {
    final data =
        await _client.post('/orders/$id/reorder') as Map<String, dynamic>;
    return (
      added: (data['added'] as num?)?.toInt() ?? 0,
      skipped: (data['skipped'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      cartOrderId: data['cart_order_id'] as int?,
    );
  }

  // ─────────────────────────── Business ───────────────────────────
  // The business's own incoming-order queue — Api\V2\OrderController's
  // business* methods. Dine-in (has a business_table_id) shows the table;
  // delivery/pickup don't.

  Future<OrdersPage> businessList({String? status, int page = 1, int perPage = 20, int? businessId}) async {
    final body = await _client.getForBody(
      '/business/orders',
      query: {'status': ?status, 'page': page, 'per_page': perPage, 'business_id': ?businessId},
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => PlacedOrder.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return OrdersPage(items: items, hasMore: currentPage < lastPage);
  }

  Future<PlacedOrder> businessShow(int id, {int? businessId}) async {
    final data = await _client.get('/business/orders/$id', query: {'business_id': ?businessId}) as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  /// Date-range order analytics -- not the `{success, data}` envelope
  /// (`getForBody` returns the raw body), since it's a plain aggregate
  /// object with no single "the resource" to unwrap.
  Future<OrderReports> businessReports({DateTime? from, DateTime? to}) async {
    final query = <String, dynamic>{
      if (from != null) 'from': from.toIso8601String().split('T').first,
      if (to != null) 'to': to.toIso8601String().split('T').first,
    };
    final data = await _client.getForBody('/business/orders/reports', query: query);
    return OrderReports.fromJson(data);
  }

  Future<PlacedOrder> businessReject(int id, {String? reason, int? businessId}) async {
    final data =
        await _client.post(
              _biz('/business/orders/$id/reject', businessId),
              data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
            )
            as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  Future<PlacedOrder> businessAccept(int id, {bool acceptWithoutDeposit = false, int? businessId}) async {
    final data =
        await _client.post(
              _biz('/business/orders/$id/accept', businessId),
              data: {if (acceptWithoutDeposit) 'accept_without_deposit': true},
            )
            as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  Future<PlacedOrder> businessPreparing(int id, {int? businessId}) async {
    final data = await _client.post(_biz('/business/orders/$id/preparing', businessId)) as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  Future<PlacedOrder> businessReady(int id, {int? businessId}) async {
    final data = await _client.post(_biz('/business/orders/$id/ready', businessId)) as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  /// Pickup/dine-in only -- a delivery order completes through the QR
  /// handover (DeliveryApi.confirmDelivery) instead.
  Future<PlacedOrder> businessComplete(int id, {int? businessId}) async {
    final data = await _client.post(_biz('/business/orders/$id/complete', businessId)) as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  /// The merchant confirms they received the order amount in cash (excludes
  /// delivery_fee — see DeliveryApi.confirmPaymentReceived for that leg).
  Future<PlacedOrder> businessConfirmPayment(int id, {int? businessId}) async {
    final data = await _client.post(_biz('/business/orders/$id/confirm-payment', businessId)) as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }

  /// The merchant tells the customer whether the courier's fee is fair.
  Future<void> recommendDeliveryFee(int id, String recommendation, {String? note, int? businessId}) => _client.post(
    _biz('/business/orders/$id/delivery-fee/recommendation', businessId),
    data: {'recommendation': recommendation, if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
  );

  /// A specific line turned out unavailable while preparing — applies
  /// whatever the customer chose at checkout (Order.out_of_stock_policy).
  /// `note` is required only when that policy is "substitute".
  Future<PlacedOrder> businessMarkItemUnavailable(int orderId, int itemId, {String? note, int? businessId}) async {
    final data =
        await _client.post(
              _biz('/business/orders/$orderId/items/$itemId/unavailable', businessId),
              data: {if (note != null && note.isNotEmpty) 'note': note},
            )
            as Map<String, dynamic>;
    return PlacedOrder.fromJson(data);
  }
}
