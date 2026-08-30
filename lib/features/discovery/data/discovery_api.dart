import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
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
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _client.get(
      '/discovery/businesses',
      query: {
        'child_id': childId,
        if (q != null && q.isNotEmpty) 'q': q,
        if (openNow) 'open_now': true,
        'page': page,
        'per_page': perPage,
      },
    );
    final businesses =
        (data as Map<String, dynamic>)['businesses'] as Map<String, dynamic>;
    return Paginated.fromJson(businesses, BusinessSummary.fromJson);
  }
}
