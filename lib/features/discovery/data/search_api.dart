import '../../../core/network/api_client.dart';
import 'models/business_summary.dart';

/// GET /search/offers — public, cross-category business search by name (see
/// Api\V2\SearchOffersController::index). Unlike /discovery/businesses this
/// needs no child_id, which is what makes it fit for a standalone search tab
/// rather than a category-scoped list. Only `data.businesses` is read here;
/// the matching offers/best_offer this endpoint also returns are a later
/// module (a "search by offer" surface, not this one).
class SearchApi {
  final ApiClient _client;

  const SearchApi(this._client);

  Future<List<BusinessSummary>> businesses(String q) async {
    if (q.trim().isEmpty) return const [];
    final data = await _client.get('/search/offers', query: {'q': q.trim()}) as Map<String, dynamic>;
    final businesses = data['businesses'] as List<dynamic>? ?? [];
    return businesses.map((e) => BusinessSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}
