import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/attribute_group.dart';
import 'models/business_summary.dart';
import 'models/platform_service_type.dart';

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
        // Dio's default list encoding repeats the bare key with no `[]`
        // (`option_ids=1&option_ids=2`), which PHP's query parser reads as
        // a scalar (last value wins), not an array — Laravel's `array`
        // validation rule then rejects the request outright. multiCompatible
        // is the one format that actually emits `option_ids[]=1&...=2`.
        if (optionIds.isNotEmpty)
          'option_ids': ListParam(optionIds, ListFormat.multiCompatible),
        'page': page,
        'per_page': perPage,
      },
    );
    final businesses =
        (data as Map<String, dynamic>)['businesses'] as Map<String, dynamic>;
    return Paginated.fromJson(businesses, BusinessSummary.fromJson);
  }

  /// GET /discovery/recommended — businesses ranked by aggregate review
  /// rating, optionally narrowed to one root category and/or one platform
  /// service (see [serviceTypes]). Unlike [businesses], no `child_id` is
  /// required — this is a "what's good" browsing surface reached before a
  /// specialty is chosen.
  Future<Paginated<BusinessSummary>> recommended({
    int? categoryId,
    int? serviceId,
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _client.get(
      '/discovery/recommended',
      query: {
        'category_id': ?categoryId,
        'service_id': ?serviceId,
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'per_page': perPage,
      },
    );
    final businesses =
        (data as Map<String, dynamic>)['businesses'] as Map<String, dynamic>;
    return Paginated.fromJson(businesses, BusinessSummary.fromJson);
  }

  /// GET /discovery/service-types — the full platform-service vocabulary
  /// (booking/menu/delivery/retail/schedules/training), unscoped by
  /// specialty. Powers a "what kind of service?" chip row shown before any
  /// category child is chosen — see [recommended]'s `serviceId`.
  Future<List<PlatformServiceType>> serviceTypes() async {
    final data = await _client.get('/discovery/service-types') as Map<String, dynamic>;
    return (data['services'] as List<dynamic>? ?? [])
        .map((e) => PlatformServiceType.fromJson(e as Map<String, dynamic>))
        .toList();
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
