import '../../../core/network/api_client.dart';
import 'models/promotion.dart';

/// /business/promotions (a business writes them) and /businesses/{id}/promotions (a customer reads them).
class PromotionsApi {
  final ApiClient _client;
  const PromotionsApi(this._client);

  Future<MyPromotions> mine() async {
    final data = await _client.get('/business/promotions') as Map<String, dynamic>;
    return MyPromotions(
      promotions: [for (final p in (data['promotions'] as List<dynamic>? ?? const [])) Promotion.fromJson(p as Map<String, dynamic>)],
      rules: PromotionRules.fromJson(data['rules'] as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<PromotionCatalog> catalog() async {
    final data = await _client.get('/business/promotions/catalog') as Map<String, dynamic>;
    return PromotionCatalog.fromJson(data);
  }

  /// Returns the covered items that are not discounted yet (their price rose recently), each with the day it will be.
  Future<List<NotYetDiscounted>> save({
    int? id,
    String? title,
    required String kind,
    required Map<String, Object> params,
    required List<PromotionTarget> targets,
    required String audience,
    DateTime? startsAt,
    DateTime? endsAt,
    int? maxUses,
  }) async {
    final body = {
      if (title != null && title.isNotEmpty) 'title': title,
      'kind': kind,
      'params': params,
      'audience': audience,
      'targets': [for (final t in targets) t.toJson()],
      if (startsAt != null) 'starts_at': startsAt.toUtc().toIso8601String(),
      if (endsAt != null) 'ends_at': endsAt.toUtc().toIso8601String(),
      'max_uses': ?maxUses,
    };

    final data = (id == null ? await _client.post('/business/promotions', data: body) : await _client.put('/business/promotions/$id', data: body)) as Map<String, dynamic>;

    return [
      for (final r in (data['not_yet_discounted'] as List<dynamic>? ?? const []))
        NotYetDiscounted(name: (r as Map<String, dynamic>)['name'] as String? ?? '', eligibleFrom: r['eligible_from'] as String?),
    ];
  }

  Future<void> toggle(int id) => _client.post('/business/promotions/$id/toggle');

  Future<void> delete(int id) => _client.delete('/business/promotions/$id');

  /// What is running on a business now — its page's offers tab.
  Future<List<Promotion>> forBusiness(int businessId) async {
    final data = await _client.get('/businesses/$businessId/promotions') as Map<String, dynamic>;
    return [for (final p in (data['promotions'] as List<dynamic>? ?? const [])) Promotion.fromJson(p as Map<String, dynamic>)];
  }
}
