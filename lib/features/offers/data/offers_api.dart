import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/commercial_offer.dart';
import 'models/offer_follow.dart';

/// /offers, /offer-follows — public deal discovery + "follow a business for
/// future offers" (see OfferDiscoveryController, OfferTrackingController,
/// OfferFollowController). OfferComparisonController's price-compare and
/// OfferBoostController's paid promotion are out of scope: compare needs a
/// specific offerable_type+id most naturally reached FROM a menu/booking
/// item screen (not built here), and boosting is a business-side purchase.
class OffersApi {
  final ApiClient _client;
  const OffersApi(this._client);

  Future<Paginated<CommercialOffer>> browse({String? q, String? sort, int page = 1}) async {
    final body = await _client.get(
      '/offers',
      query: {if (q != null && q.isNotEmpty) 'q': q, if (sort != null) 'sort': sort, 'page': page},
    ) as Map<String, dynamic>;
    final offers = body['offers'] as Map<String, dynamic>;
    return Paginated.fromJson(offers, CommercialOffer.fromJson);
  }

  Future<CommercialOffer> show(int id) async {
    final data = await _client.get('/offers/$id') as Map<String, dynamic>;
    return CommercialOffer.fromJson(data['offer'] as Map<String, dynamic>);
  }

  /// Fire-and-forget view tracking — errors are swallowed by the caller,
  /// never surfaced to the user.
  Future<void> track(int id, {String eventType = 'view'}) async {
    await _client.post('/offers/$id/track', data: {'event_type': eventType});
  }

  Future<Paginated<OfferFollow>> myFollows({int page = 1}) async {
    final data = await _client.get('/offer-follows', query: {'page': page}) as Map<String, dynamic>;
    final follows = data['follows'] as Map<String, dynamic>;
    return Paginated.fromJson(follows, OfferFollow.fromJson);
  }

  Future<OfferFollow> followBusiness(int businessId) async {
    final data = await _client.post(
      '/offer-follows',
      data: {'followable_type': 'business', 'followable_id': businessId},
    ) as Map<String, dynamic>;
    return OfferFollow.fromJson(data['follow'] as Map<String, dynamic>);
  }

  Future<void> unfollow(int followId) async {
    await _client.delete('/offer-follows/$followId');
  }
}
