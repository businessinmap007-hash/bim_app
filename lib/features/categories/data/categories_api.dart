import '../../../core/network/api_client.dart';
import 'models/category_root.dart';
import 'models/specialty.dart';

/// GET /categories and GET /categories/{category}/specialties — both public,
/// no auth required. See docs/api/openapi-v2.yaml under the Categories tag.
class CategoriesApi {
  final ApiClient _client;

  const CategoriesApi(this._client);

  Future<List<CategoryRoot>> roots() async {
    final data = await _client.get('/categories');
    final list =
        (data as Map<String, dynamic>)['categories'] as List<dynamic>? ?? [];
    return list
        .map((e) => CategoryRoot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Specialty>> specialties(
    int categoryId, {
    bool sellableOnly = false,
  }) async {
    final data = await _client.get(
      '/categories/$categoryId/specialties',
      query: sellableOnly ? {'sellable': true} : null,
    );
    final list =
        (data as Map<String, dynamic>)['specialties'] as List<dynamic>? ?? [];
    return list
        .map((e) => Specialty.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
