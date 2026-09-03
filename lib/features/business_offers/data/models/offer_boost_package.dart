/// A purchasable boost tier — see Api\V2\OfferBoostController::packages /
/// OfferBoostPackage.
class OfferBoostPackage {
  final int id;
  final String key;
  final String nameAr;
  final String? nameEn;
  final double price;
  final String currency;
  final int durationDays;
  final double boostScore;
  final bool isFeatured;

  const OfferBoostPackage({
    required this.id,
    required this.key,
    required this.nameAr,
    this.nameEn,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.boostScore,
    required this.isFeatured,
  });

  String displayName() => nameAr.isNotEmpty ? nameAr : (nameEn?.isNotEmpty ?? false) ? nameEn! : key;

  factory OfferBoostPackage.fromJson(Map<String, dynamic> json) => OfferBoostPackage(
    id: (json['id'] as num).toInt(),
    key: json['key'] as String? ?? '',
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
    price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
    boostScore: double.tryParse(json['boost_score']?.toString() ?? '') ?? 0,
    isFeatured: json['is_featured'] as bool? ?? false,
  );
}
