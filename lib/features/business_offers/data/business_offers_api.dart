import '../../../core/network/api_client.dart';
import '../../offers/data/models/commercial_offer.dart';
import 'models/offer_boost_package.dart';
import 'models/offer_boost_purchase.dart';
import 'models/offers_usage.dart';

class BusinessOffersPage {
  final List<CommercialOffer> items;
  final bool hasMore;
  final OffersUsage usage;
  const BusinessOffersPage({required this.items, required this.hasMore, required this.usage});
}

class BoostPurchasesPage {
  final List<OfferBoostPurchase> items;
  final bool hasMore;
  const BoostPurchasesPage({required this.items, required this.hasMore});
}

/// /business/offers, /business/offers/boost/* — see BusinessOfferController
/// and OfferBoostController. Gated server-side on the "offers" business
/// capability, and further gated by a business_offers platform-service
/// subscription (surfaced as `usage` on every list call, and as a plain
/// ApiException message if a create is attempted without one).
class BusinessOffersApi {
  final ApiClient _client;
  const BusinessOffersApi(this._client);

  Future<BusinessOffersPage> list({String? status, int page = 1}) async {
    final body = await _client.getForBody(
      '/business/offers',
      query: {if (status != null) 'status': status, 'page': page},
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final offers = data['offers'] as Map<String, dynamic>? ?? const {};
    final items = (offers['data'] as List<dynamic>? ?? [])
        .map((e) => CommercialOffer.fromJson(e as Map<String, dynamic>))
        .toList();
    final currentPage = (offers['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (offers['last_page'] as num?)?.toInt() ?? 1;
    return BusinessOffersPage(
      items: items,
      hasMore: currentPage < lastPage,
      usage: OffersUsage.fromJson(data['usage'] as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<CommercialOffer> create({
    required String offerableType,
    required int offerableId,
    required double finalPrice,
    required String availabilityMode,
    int? availableQuantity,
    DateTime? endsAt,
    bool isRefundable = false,
    String? titleAr,
  }) async {
    final data = await _client.post(
      '/business/offers',
      data: _payload(
        offerableType: offerableType,
        offerableId: offerableId,
        finalPrice: finalPrice,
        availabilityMode: availabilityMode,
        availableQuantity: availableQuantity,
        endsAt: endsAt,
        isRefundable: isRefundable,
        titleAr: titleAr,
      ),
    ) as Map<String, dynamic>;
    return CommercialOffer.fromJson(data['offer'] as Map<String, dynamic>);
  }

  Future<CommercialOffer> update(
    int id, {
    required String offerableType,
    required int offerableId,
    required double finalPrice,
    required String availabilityMode,
    int? availableQuantity,
    DateTime? endsAt,
    bool isRefundable = false,
    String? titleAr,
  }) async {
    final data = await _client.put(
      '/business/offers/$id',
      data: _payload(
        offerableType: offerableType,
        offerableId: offerableId,
        finalPrice: finalPrice,
        availabilityMode: availabilityMode,
        availableQuantity: availableQuantity,
        endsAt: endsAt,
        isRefundable: isRefundable,
        titleAr: titleAr,
      ),
    ) as Map<String, dynamic>;
    return CommercialOffer.fromJson(data['offer'] as Map<String, dynamic>);
  }

  Future<CommercialOffer> toggle(int id) async {
    final data = await _client.post('/business/offers/$id/toggle') as Map<String, dynamic>;
    return CommercialOffer.fromJson(data['offer'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/business/offers/$id');

  Future<List<OfferBoostPackage>> boostPackages() async {
    final data = await _client.get('/business/offers/boost/packages') as Map<String, dynamic>;
    return (data['packages'] as List<dynamic>? ?? [])
        .map((e) => OfferBoostPackage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> activateBoost(int offerId, int packageId) => _client.post(
    '/business/offers/$offerId/boost',
    data: {'package_id': packageId},
  );

  Future<BoostPurchasesPage> boostPurchases({int page = 1}) async {
    final body = await _client.getForBody('/business/offers/boost/purchases', query: {'page': page});
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final purchases = data['purchases'] as Map<String, dynamic>? ?? const {};
    final items = (purchases['data'] as List<dynamic>? ?? [])
        .map((e) => OfferBoostPurchase.fromJson(e as Map<String, dynamic>))
        .toList();
    final currentPage = (purchases['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (purchases['last_page'] as num?)?.toInt() ?? 1;
    return BoostPurchasesPage(items: items, hasMore: currentPage < lastPage);
  }

  Map<String, dynamic> _payload({
    required String offerableType,
    required int offerableId,
    required double finalPrice,
    required String availabilityMode,
    int? availableQuantity,
    DateTime? endsAt,
    required bool isRefundable,
    String? titleAr,
  }) => {
    'offerable_type': offerableType,
    'offerable_id': offerableId,
    'final_price': finalPrice,
    'availability_mode': availabilityMode,
    if (availableQuantity != null) 'available_quantity': availableQuantity,
    if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
    'is_refundable': isRefundable,
    if (titleAr != null && titleAr.isNotEmpty) 'title_ar': titleAr,
  };
}
