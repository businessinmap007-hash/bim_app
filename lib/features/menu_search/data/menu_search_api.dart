import '../../../core/network/api_client.dart';
import 'models/menu_search.dart';

/// Public search across shops by a detail kind's fields, and the price
/// comparison of one product — see Api\V2\MenuItemSearchController.
class MenuSearchApi {
  final ApiClient _client;
  const MenuSearchApi(this._client);

  Future<List<SearchKind>> kinds() async {
    final data = await _client.get('/discovery/menu-items/kinds') as Map<String, dynamic>;
    return (data['kinds'] as List<dynamic>? ?? [])
        .map((e) => SearchKind.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SearchPage> search({
    String? kind,
    String? q,
    SearchFilters filters = const SearchFilters(),
    String sort = 'price_asc',
    int? catalogProductId,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/discovery/menu-items/search',
              query: {
                'profile': ?kind,
                if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
                if (!filters.isEmpty) 'attr': filters.toQuery(),
                'sort': sort,
                'catalog_product_id': ?catalogProductId,
                'page': page,
              },
            )
            as Map<String, dynamic>;
    return SearchPage.fromJson(data);
  }
}
