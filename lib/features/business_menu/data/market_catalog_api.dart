import '../../../core/network/api_client.dart';
import 'models/market_catalog_group.dart';

/// /business/menu/market-catalog — see Api\V2\MenuMarketCatalogController.
/// Same MenuMarketCatalogService the web business panel's «تعبئة الرفوف»
/// screen uses, so the bulk-pricing rules never drift between the two.
class MarketCatalogApi {
  final ApiClient _client;
  const MarketCatalogApi(this._client);

  Future<MarketCatalog> fetch() async {
    final data = await _client.get('/business/menu/market-catalog') as Map<String, dynamic>;
    return MarketCatalog.fromJson(data);
  }

  /// Saves one batch of rows (typically one group's worth). Each entry is
  /// keyed by option id; an empty [basePrice] clears/deactivates that row
  /// instead of deleting it.
  Future<({int saved, int cleared})> save(
    Map<int, ({int? quantity, double? supplyPrice, double? basePrice, String? saleUnit, String? brandName})> rows,
  ) async {
    final payload = <String, dynamic>{};
    rows.forEach((optionId, row) {
      payload[optionId.toString()] = {
        'quantity': row.quantity?.toString() ?? '',
        'supply_price': row.supplyPrice?.toString() ?? '',
        'base_price': row.basePrice?.toString() ?? '',
        'sale_unit': row.saleUnit ?? '',
        'brand_name': row.brandName ?? '',
      };
    });

    final data = await _client.post('/business/menu/market-catalog', data: {'rows': payload}) as Map<String, dynamic>;
    return (saved: (data['saved'] as num?)?.toInt() ?? 0, cleared: (data['cleared'] as num?)?.toInt() ?? 0);
  }

  /// Null clears the threshold — alerts then fire only once an item is
  /// fully at zero, the original behaviour.
  Future<int?> updateLowStockThreshold(int? threshold) async {
    final data = await _client.put(
          '/business/menu/market-catalog/low-stock-threshold',
          data: {'low_stock_threshold': threshold},
        )
        as Map<String, dynamic>;
    return (data['low_stock_threshold'] as num?)?.toInt();
  }
}
