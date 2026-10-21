import '../../../core/network/api_client.dart';
import 'models/partnership.dart';

/// /business/partnerships — a contract between two businesses that only the two can read.
class PartnershipsApi {
  final ApiClient _client;
  const PartnershipsApi(this._client);

  Future<List<Partnership>> mine() async {
    final data = await _client.get('/business/partnerships') as Map<String, dynamic>;
    return [for (final p in (data['partnerships'] as List<dynamic>? ?? const [])) Partnership.fromJson(p as Map<String, dynamic>)];
  }

  Future<List<BusinessHit>> lookup(String q) async {
    final data = await _client.get('/business/partnerships/lookup', query: {'q': q}) as Map<String, dynamic>;
    return [for (final b in (data['businesses'] as List<dynamic>? ?? const [])) BusinessHit.fromJson(b as Map<String, dynamic>)];
  }

  Future<void> invite({required int partnerId, required String type, String? note}) => _client.post(
    '/business/partnerships',
    data: {'partner_business_id': partnerId, 'type': type, if (note != null && note.isNotEmpty) 'terms': {'note': note}},
  );

  Future<PartnershipDetail> show(int id) async => PartnershipDetail.fromJson(await _client.get('/business/partnerships/$id') as Map<String, dynamic>);

  Future<void> respond(int id, {required bool accept}) => _client.post('/business/partnerships/$id/${accept ? 'accept' : 'decline'}');

  /// `pause`, `resume` or `end`.
  Future<void> change(int id, String action) => _client.post('/business/partnerships/$id/$action');

  Future<List<GrantableRoom>> grantable(int id) async {
    final data = await _client.get('/business/partnerships/$id/available-rooms') as Map<String, dynamic>;
    return [for (final r in (data['rooms'] as List<dynamic>? ?? const [])) GrantableRoom.fromJson(r as Map<String, dynamic>)];
  }

  Map<String, Object> _terms({required int quantity, required double contractPrice, int? minNights, int? maxNights, int releaseDays = 0}) => {
    'quantity_total': quantity,
    'contract_price': contractPrice,
    'min_nights': ?minNights,
    'max_nights': ?maxNights,
    'release_days_before': releaseDays,
  };

  Future<void> grant(int id, {required int unitId, required int quantity, required double contractPrice, int? minNights, int? maxNights, int releaseDays = 0}) => _client.post(
    '/business/partnerships/$id/allocations',
    data: {'bookable_item_id': unitId, ..._terms(quantity: quantity, contractPrice: contractPrice, minNights: minNights, maxNights: maxNights, releaseDays: releaseDays)},
  );

  Future<void> updateAllocation(int id, int allocationId, {required int quantity, required double contractPrice, int? minNights, int? maxNights, int releaseDays = 0}) => _client.put(
    '/business/partnerships/$id/allocations/$allocationId',
    data: _terms(quantity: quantity, contractPrice: contractPrice, minNights: minNights, maxNights: maxNights, releaseDays: releaseDays),
  );

  /// `stop` or `activate`.
  Future<void> allocationStatus(int id, int allocationId, String action) => _client.post('/business/partnerships/$id/allocations/$allocationId/$action');

  Future<void> price(int id, int allocationId, {required String type, double value = 0}) =>
      _client.put('/business/partnerships/$id/allocations/$allocationId/pricing', data: {'markup_type': type, 'markup_value': value});
}
