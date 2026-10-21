import '../../../core/network/api_client.dart';
import 'models/business_summary.dart';

/// GET /search/businesses — public, cross-category business search by name (see
/// Api\V2\BusinessSearchController::index). Unlike /discovery/businesses this
/// needs no child_id, which is what makes it fit for a standalone search tab
/// rather than a category-scoped list. The endpoint answers names only.
class SearchApi {
  final ApiClient _client;

  const SearchApi(this._client);

  Future<List<BusinessSummary>> businesses(String q) async {
    if (q.trim().isEmpty) return const [];
    final data = await _client.get('/search/businesses', query: {'q': q.trim()}) as Map<String, dynamic>;
    final businesses = data['businesses'] as List<dynamic>? ?? [];
    return businesses.map((e) => BusinessSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}
