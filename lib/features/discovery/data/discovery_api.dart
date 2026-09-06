import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/attribute_group.dart';
import 'models/business_summary.dart';

/// GET /discovery/businesses — public, no auth required. See
/// Api\V2\DiscoveryController::businesses for the exact response shape
/// (data.businesses is a Laravel paginator; data.query echoes the filters).
class DiscoveryApi {
  final ApiClient _client;

  const DiscoveryApi(this._client);

  Future<Paginated<BusinessSummary>> businesses({
    required int childId,
    String? q,
    bool openNow = false,
    int? governorateId,
    int? cityId,
    List<int> optionIds = const [],
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _client.get(
      '/discovery/businesses',
      query: {
        'child_id': childId,
        if (q != null && q.isNotEmpty) 'q': q,
        if (openNow) 'open_now': true,
        'governorate_id': ?governorateId,
        'city_id': ?cityId,
        if (optionIds.isNotEmpty) 'option_ids': optionIds,
        'page': page,
        'per_page': perPage,
      },
    );
    final businesses =
        (data as Map<String, dynamic>)['businesses'] as Map<String, dynamic>;
    return Paginated.fromJson(businesses, BusinessSummary.fromJson);
  }

  /// GET /discovery/recommended — businesses ranked by aggregate review
  /// rating, optionally narrowed to one root category. Unlike [businesses],
  /// no `child_id` is required — this is a "what's good" browsing surface
  /// reached before a specialty is chosen.
  Future<Paginated<BusinessSummary>> recommended({
    int? categoryId,
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _client.get(
      '/discovery/recommended',
      query: {
        'category_id': ?categoryId,
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'per_page': perPage,
      },
    );
    final businesses =
        (data as Map<String, dynamic>)['businesses'] as Map<String, dynamic>;
    return Paginated.fromJson(businesses, BusinessSummary.fromJson);
  }

  /// The filterable options for this child — only ones at least one real,
  /// live business actually carries (the backend drops the rest so the
  /// filter never offers a choice that always returns nothing).
  Future<List<AttributeGroup>> attributes({
    required int childId,
    int? categoryId,
  }) async {
    final data =
        await _client.get(
              '/discovery/attributes',
              query: {'child_id': childId, 'category_id': ?categoryId},
            )
            as Map<String, dynamic>;
    return (data['groups'] as List<dynamic>? ?? [])
        .map((e) => AttributeGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
