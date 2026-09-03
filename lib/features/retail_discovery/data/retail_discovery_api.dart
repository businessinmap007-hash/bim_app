import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/catalog_product_listing.dart';

/// /discovery/retail — cross-business product marketplace: browse a catalog
/// product and see every business that sells it and at what price. See
/// Api\V2\RetailDiscoveryController. Public, no auth required.
class RetailDiscoveryApi {
  final ApiClient _client;
  const RetailDiscoveryApi(this._client);

  Future<RetailFilters> filters({bool openNow = false}) async {
    final data =
        await _client.get(
              '/discovery/retail/filters',
              query: {if (openNow) 'open_now': true},
            )
            as Map<String, dynamic>;
    return RetailFilters.fromJson(data);
  }

  Future<Paginated<CatalogProductSummary>> products({
    int? categoryId,
    int? childId,
    int? brandId,
    String? q,
    bool openNow = false,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/discovery/retail/products',
              query: {
                'category_id': ?categoryId,
                'child_id': ?childId,
                'brand_id': ?brandId,
                if (q != null && q.isNotEmpty) 'q': q,
                if (openNow) 'open_now': true,
                'page': page,
              },
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(
      data['products'] as Map<String, dynamic>,
      CatalogProductSummary.fromJson,
    );
  }

  Future<ProductDetail> show(int productId) async {
    final data =
        await _client.get('/discovery/retail/products/$productId')
            as Map<String, dynamic>;
    return ProductDetail.fromJson(data);
  }
}
