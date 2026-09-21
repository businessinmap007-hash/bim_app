import '../../../core/network/api_client.dart';
import '../../orders/data/models/placed_order.dart';

typedef ShippingRateRow = ({int governorateId, String nameAr, String nameEn, double? price});
typedef ShippingCompany = ({int id, String name, double price});

/// Governorate shipping - Api\V2\ShippingController. A Shipping & Delivery
/// company keeps its price list and runs the orders; a merchant picks a company.
class ShippingApi {
  final ApiClient _client;
  const ShippingApi(this._client);

  static String _biz(String path, int? businessId) =>
      businessId == null ? path : '$path${path.contains('?') ? '&' : '?'}business_id=$businessId';

  // ── the company's price list ──

  Future<List<ShippingRateRow>> rates() async {
    final data = await _client.get('/business/shipping/rates') as Map<String, dynamic>;
    return (data['rates'] as List<dynamic>? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return (
        governorateId: (m['governorate_id'] as num).toInt(),
        nameAr: m['name_ar'] as String? ?? '',
        nameEn: m['name_en'] as String? ?? '',
        price: (m['price'] as num?)?.toDouble(),
      );
    }).toList();
  }

  Future<void> saveRates(Map<int, double?> prices) => _client.put(
    '/business/shipping/rates',
    data: {
      'rates': [for (final e in prices.entries) {'governorate_id': e.key, 'price': e.value}],
    },
  );

  // ── the merchant ──

  Future<List<ShippingCompany>> companiesFor(int orderId, {int? businessId}) async {
    final data = await _client.get('/business/orders/$orderId/shipping-companies', query: {'business_id': ?businessId}) as Map<String, dynamic>;
    return (data['companies'] as List<dynamic>? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return (id: (m['id'] as num).toInt(), name: m['name'] as String? ?? '', price: (m['price'] as num?)?.toDouble() ?? 0.0);
    }).toList();
  }

  Future<void> assignCompany(int orderId, int companyId, {int? businessId}) =>
      _client.post(_biz('/business/orders/$orderId/shipping-company', businessId), data: {'company_id': companyId});

  // ── the company ──

  Future<List<PlacedOrder>> orders() async {
    final body = await _client.getForBody('/business/shipping/orders');
    return (body['data'] as List<dynamic>? ?? []).map((e) => PlacedOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> setAppointment(int orderId, DateTime at, {String? note}) => _client.post(
    '/business/shipping/orders/$orderId/appointment',
    data: {'appointment_at': at.toUtc().toIso8601String(), if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
  );

  Future<void> markShipped(int orderId) => _client.post('/business/shipping/orders/$orderId/shipped');

  Future<void> markDelivered(int orderId) => _client.post('/business/shipping/orders/$orderId/delivered');
}
