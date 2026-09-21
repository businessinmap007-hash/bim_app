import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/commercial_offer.dart';
import 'models/offer_comparison_row.dart';
import 'models/offer_follow.dart';

/// One root category with live offers — the tab's own top-level navigation.
class OfferCategory {
  final int id;
  final String nameAr;
  final String? nameEn;
  final int offersCount;

  const OfferCategory({required this.id, required this.nameAr, this.nameEn, required this.offersCount});

  String localizedName(String languageCode) => languageCode == 'en' && (nameEn?.isNotEmpty ?? false) ? nameEn! : nameAr;

  factory OfferCategory.fromJson(Map<String, dynamic> json) => OfferCategory(
    id: (json['id'] as num).toInt(),
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
    offersCount: (json['offers_count'] as num?)?.toInt() ?? 0,
  );
}

/// /offers, /offer-follows, /offers/compare — public deal discovery, "follow
/// a business for future offers", and price comparison across sellers for
/// one specific item (see OfferDiscoveryController, OfferTrackingController,
/// OfferFollowController, OfferComparisonController). OfferBoostController's
/// paid promotion is out of scope — it's a business-side purchase.
class OffersApi {
  final ApiClient _client;
  const OffersApi(this._client);

  Future<Paginated<CommercialOffer>> browse({
    String? q,
    String? sort,
    int? categoryId,
    bool openNow = false,
    int page = 1,
  }) async {
    final body =
        await _client.get(
              '/offers',
              query: {
                if (q != null && q.isNotEmpty) 'q': q,
                'sort': ?sort,
                'category_id': ?categoryId,
                if (openNow) 'open_now': 1,
                'page': page,
              },
            )
            as Map<String, dynamic>;
    final offers = body['offers'] as Map<String, dynamic>;
    return Paginated.fromJson(offers, CommercialOffer.fromJson);
  }

  /// Root categories that currently have at least one live public offer.
  Future<List<OfferCategory>> categories() async {
    final data = await _client.get('/offers/categories') as Map<String, dynamic>;
    return (data['categories'] as List<dynamic>? ?? []).map((e) => OfferCategory.fromJson(e as Map<String, dynamic>)).toList();
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
    final data =
        await _client.get('/offer-follows', query: {'page': page})
            as Map<String, dynamic>;
    final follows = data['follows'] as Map<String, dynamic>;
    return Paginated.fromJson(follows, OfferFollow.fromJson);
  }

  Future<OfferFollow> followBusiness(int businessId) async {
    final data =
        await _client.post(
              '/offer-follows',
              data: {
                'followable_type': 'business',
                'followable_id': businessId,
              },
            )
            as Map<String, dynamic>;
    return OfferFollow.fromJson(data['follow'] as Map<String, dynamic>);
  }

  Future<void> unfollow(int followId) async {
    await _client.delete('/offer-follows/$followId');
  }

  Future<OfferComparisonResult> compare({
    required String offerableType,
    required int offerableId,
    int quantity = 1,
    String sort = 'lowest_price',
  }) async {
    final data =
        await _client.get(
              '/offers/compare',
              query: {
                'offerable_type': offerableType,
                'offerable_id': offerableId,
                'quantity': quantity,
                'sort': sort,
              },
            )
            as Map<String, dynamic>;
    return OfferComparisonResult.fromJson(data);
  }
}
