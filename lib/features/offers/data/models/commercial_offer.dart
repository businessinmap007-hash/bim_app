import '../../../../core/env/env.dart';

/// The selling or owning business on an offer — Eloquent's default
/// `sellerBusiness`/`ownerBusiness` relations serialize to snake_case keys.
class OfferParty {
  final int id;
  final String name;
  final String? logoUrl;

  const OfferParty({required this.id, required this.name, this.logoUrl});

  factory OfferParty.fromJson(Map<String, dynamic> json) => OfferParty(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    logoUrl: Env.assetUrl(json['logo'] as String?),
  );
}

/// A row from `commercial_offers`, straight off the Eloquent model (see
/// OfferDiscoveryController — it returns the model directly, not a hand
/// -picked serializer, so this mirrors the table/casts as-is).
class CommercialOffer {
  final int id;
  final String offerableType;
  final int offerableId;
  final int? ownerBusinessId;
  final int? sellerBusinessId;
  final String sourceType;
  final String? audienceType;
  final String titleAr;
  final String? titleEn;
  final double? basePrice;
  final double finalPrice;
  final String currency;
  final String? discountType;
  final double? discountValue;
  final String? availabilityMode;
  final int? availableQuantity;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isFeatured;
  final String status;
  final OfferParty? sellerBusiness;
  final OfferParty? ownerBusiness;

  const CommercialOffer({
    required this.id,
    required this.offerableType,
    required this.offerableId,
    this.ownerBusinessId,
    this.sellerBusinessId,
    required this.sourceType,
    this.audienceType,
    required this.titleAr,
    this.titleEn,
    this.basePrice,
    required this.finalPrice,
    required this.currency,
    this.discountType,
    this.discountValue,
    this.availabilityMode,
    this.availableQuantity,
    this.startsAt,
    this.endsAt,
    this.isFeatured = false,
    required this.status,
    this.sellerBusiness,
    this.ownerBusiness,
  });

  /// The selling business — falls back to the owner when there's no
  /// separate reseller, same resolution the backend's own filters use.
  OfferParty? get sellingBusiness => sellerBusiness ?? ownerBusiness;

  String title(String languageCode) {
    if (languageCode == 'en' && (titleEn?.isNotEmpty ?? false)) return titleEn!;
    return titleAr;
  }

  factory CommercialOffer.fromJson(Map<String, dynamic> json) => CommercialOffer(
    id: json['id'] as int,
    offerableType: json['offerable_type'] as String? ?? '',
    offerableId: (json['offerable_id'] as num?)?.toInt() ?? 0,
    ownerBusinessId: (json['owner_business_id'] as num?)?.toInt(),
    sellerBusinessId: (json['seller_business_id'] as num?)?.toInt(),
    sourceType: json['source_type'] as String? ?? '',
    audienceType: json['audience_type'] as String?,
    titleAr: json['title_ar'] as String? ?? '',
    titleEn: json['title_en'] as String?,
    basePrice: json['base_price'] != null ? double.tryParse(json['base_price'].toString()) : null,
    finalPrice: double.tryParse(json['final_price']?.toString() ?? '') ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    discountType: json['discount_type'] as String?,
    discountValue: json['discount_value'] != null
        ? double.tryParse(json['discount_value'].toString())
        : null,
    availabilityMode: json['availability_mode'] as String?,
    availableQuantity: (json['available_quantity'] as num?)?.toInt(),
    startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
    endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
    isFeatured: json['is_featured'] as bool? ?? false,
    status: json['status'] as String? ?? 'active',
    sellerBusiness: json['seller_business'] != null
        ? OfferParty.fromJson(json['seller_business'] as Map<String, dynamic>)
        : null,
    ownerBusiness: json['owner_business'] != null
        ? OfferParty.fromJson(json['owner_business'] as Map<String, dynamic>)
        : null,
  );
}
