import 'offer_boost_package.dart';

/// A business's own boost purchase — see Api\V2\OfferBoostController::myPurchases
/// / OfferBoostPurchase.
class OfferBoostPurchase {
  final int id;
  final int offerId;
  final String? offerTitle;
  final double price;
  final String currency;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String status;
  final OfferBoostPackage? package;

  const OfferBoostPurchase({
    required this.id,
    required this.offerId,
    this.offerTitle,
    required this.price,
    required this.currency,
    this.startsAt,
    this.endsAt,
    required this.status,
    this.package,
  });

  factory OfferBoostPurchase.fromJson(Map<String, dynamic> json) {
    final offer = json['offer'] as Map<String, dynamic>?;
    return OfferBoostPurchase(
      id: (json['id'] as num).toInt(),
      offerId: (json['offer_id'] as num?)?.toInt() ?? 0,
      offerTitle: offer?['title_ar'] as String?,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
      status: json['status'] as String? ?? 'active',
      package: json['package'] != null
          ? OfferBoostPackage.fromJson(json['package'] as Map<String, dynamic>)
          : null,
    );
  }
}
