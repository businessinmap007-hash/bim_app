import '../../../core/network/api_client.dart';
import 'models/price_options.dart';
import 'models/price_row.dart';

class PriceRowsPage {
  final List<PriceRow> items;
  final bool hasMore;
  const PriceRowsPage({required this.items, required this.hasMore});
}

/// /business/prices — see Api\V2\BusinessServicePriceController. One row per
/// (service, item type, line) the owner's category_child actually offers;
/// gated server-side on the "prices" business capability.
class BusinessPricesApi {
  final ApiClient _client;
  const BusinessPricesApi(this._client);

  Future<PriceRowsPage> list({int? serviceId, int page = 1}) async {
    final body = await _client.getForBody(
      '/business/prices',
      query: {if (serviceId != null) 'service_id': serviceId, 'page': page},
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => PriceRow.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return PriceRowsPage(items: items, hasMore: currentPage < lastPage);
  }

  Future<PriceOptions> options() async {
    final data = await _client.get('/business/prices/options') as Map<String, dynamic>;
    return PriceOptions.fromJson(data);
  }

  Future<PriceRow> show(int id) async {
    final data = await _client.get('/business/prices/$id') as Map<String, dynamic>;
    return PriceRow.fromJson(data);
  }

  Future<PriceRow> create({
    required int serviceId,
    required String bookableItemType,
    required double price,
    String chargeMode = 'standard',
    double chargeAmount = 0,
    int? durationMinutes,
    String currency = 'EGP',
    bool isActive = true,
    bool discountEnabled = false,
    int discountPercent = 0,
    int? lineOptionId,
    List<int> modifierOptionIds = const [],
    Map<int, double> modifierAdjust = const {},
    Map<int, String> modifierAdjustType = const {},
  }) async {
    final data = await _client.post(
      '/business/prices',
      data: _payload(
        serviceId: serviceId,
        bookableItemType: bookableItemType,
        price: price,
        chargeMode: chargeMode,
        chargeAmount: chargeAmount,
        durationMinutes: durationMinutes,
        currency: currency,
        isActive: isActive,
        discountEnabled: discountEnabled,
        discountPercent: discountPercent,
        lineOptionId: lineOptionId,
        modifierOptionIds: modifierOptionIds,
        modifierAdjust: modifierAdjust,
        modifierAdjustType: modifierAdjustType,
      ),
    ) as Map<String, dynamic>;
    return PriceRow.fromJson(data);
  }

  Future<PriceRow> update(
    int id, {
    required int serviceId,
    required String bookableItemType,
    required double price,
    String chargeMode = 'standard',
    double chargeAmount = 0,
    int? durationMinutes,
    String currency = 'EGP',
    bool isActive = true,
    bool discountEnabled = false,
    int discountPercent = 0,
    int? lineOptionId,
    List<int> modifierOptionIds = const [],
    Map<int, double> modifierAdjust = const {},
    Map<int, String> modifierAdjustType = const {},
  }) async {
    final data = await _client.put(
      '/business/prices/$id',
      data: _payload(
        serviceId: serviceId,
        bookableItemType: bookableItemType,
        price: price,
        chargeMode: chargeMode,
        chargeAmount: chargeAmount,
        durationMinutes: durationMinutes,
        currency: currency,
        isActive: isActive,
        discountEnabled: discountEnabled,
        discountPercent: discountPercent,
        lineOptionId: lineOptionId,
        modifierOptionIds: modifierOptionIds,
        modifierAdjust: modifierAdjust,
        modifierAdjustType: modifierAdjustType,
      ),
    ) as Map<String, dynamic>;
    return PriceRow.fromJson(data);
  }

  Future<void> delete(int id) => _client.delete('/business/prices/$id');

  Map<String, dynamic> _payload({
    required int serviceId,
    required String bookableItemType,
    required double price,
    required String chargeMode,
    required double chargeAmount,
    int? durationMinutes,
    required String currency,
    required bool isActive,
    required bool discountEnabled,
    required int discountPercent,
    int? lineOptionId,
    required List<int> modifierOptionIds,
    required Map<int, double> modifierAdjust,
    required Map<int, String> modifierAdjustType,
  }) {
    return {
      'service_id': serviceId,
      'bookable_item_type': bookableItemType,
      'price': price,
      'charge_mode': chargeMode,
      'charge_amount': chargeAmount,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      'currency': currency,
      'is_active': isActive,
      'discount_enabled': discountEnabled,
      'discount_percent': discountPercent,
      if (lineOptionId != null) 'line_option_id': lineOptionId,
      'modifier_option_ids': modifierOptionIds,
      'modifier_adjust': modifierAdjust.map((id, v) => MapEntry(id.toString(), v)),
      'modifier_adjust_type': modifierAdjustType.map((id, v) => MapEntry(id.toString(), v)),
    };
  }
}
