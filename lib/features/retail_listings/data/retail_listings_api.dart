import '../../../core/network/api_client.dart';
import 'models/catalog_product_summary.dart';
import 'models/retail_listing.dart';

class RetailListingsPage {
  final List<RetailListing> items;
  final bool hasMore;
  const RetailListingsPage({required this.items, required this.hasMore});
}

/// /business/retail-listings — see Api\V2\BusinessRetailListingController.
/// Gated server-side on the "retail" business capability (owner, or a
/// delegate granted it).
class RetailListingsApi {
  final ApiClient _client;
  const RetailListingsApi(this._client);

  Future<RetailListingsPage> list({String? q, int page = 1}) async {
    final body = await _client.getForBody(
      '/business/retail-listings',
      query: {if (q != null && q.isNotEmpty) 'q': q, 'page': page},
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => RetailListing.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return RetailListingsPage(items: items, hasMore: currentPage < lastPage);
  }

  Future<List<CatalogProductSummary>> lookup(String q) async {
    final data =
        await _client.get('/business/retail-listings/lookup', query: {'q': q})
            as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CatalogProductSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RetailListing> create({
    required int catalogProductId,
    required double price,
    int? stock,
    String? sku,
    bool isActive = true,
  }) async {
    final data =
        await _client.post(
              '/business/retail-listings',
              data: {
                'catalog_product_id': catalogProductId,
                'price': price,
                'stock': ?stock,
                if (sku != null && sku.isNotEmpty) 'sku': sku,
                'is_active': isActive,
              },
            )
            as Map<String, dynamic>;
    return RetailListing.fromJson(data);
  }

  Future<RetailListing> update(
    int id, {
    required double price,
    int? stock,
    String? sku,
    required bool isActive,
  }) async {
    final data =
        await _client.put(
              '/business/retail-listings/$id',
              data: {
                'price': price,
                'stock': ?stock,
                if (sku != null && sku.isNotEmpty) 'sku': sku,
                'is_active': isActive,
              },
            )
            as Map<String, dynamic>;
    return RetailListing.fromJson(data);
  }

  Future<void> delete(int id) =>
      _client.delete('/business/retail-listings/$id');
}
