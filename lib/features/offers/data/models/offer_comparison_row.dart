class OfferBusinessRef {
  final int id;
  final String name;
  final String? logo;

  const OfferBusinessRef({required this.id, required this.name, this.logo});

  factory OfferBusinessRef.fromJson(Map<String, dynamic> json) {
    return OfferBusinessRef(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
    );
  }
}

/// One seller's offer for the compared item — mirrors
/// OfferComparisonService::payload().
class OfferComparisonRow {
  final int id;
  final OfferBusinessRef? sellerBusiness;
  final OfferBusinessRef? ownerBusiness;
  final String displayTitle;
  final double basePrice;
  final double finalPrice;
  final double totalPrice;
  final String currency;
  final String? discountType;
  final double? discountValue;
  final bool isRefundable;
  final String? paymentModel;
  final bool isFeatured;
  final bool isBoosted;
  final String availabilityMode;
  final int? availableQuantity;

  const OfferComparisonRow({
    required this.id,
    this.sellerBusiness,
    this.ownerBusiness,
    required this.displayTitle,
    required this.basePrice,
    required this.finalPrice,
    required this.totalPrice,
    required this.currency,
    this.discountType,
    this.discountValue,
    required this.isRefundable,
    this.paymentModel,
    required this.isFeatured,
    required this.isBoosted,
    required this.availabilityMode,
    this.availableQuantity,
  });

  bool get hasDiscount => discountType != null && (discountValue ?? 0) > 0 && finalPrice < basePrice;

  factory OfferComparisonRow.fromJson(Map<String, dynamic> json) {
    return OfferComparisonRow(
      id: (json['id'] as num).toInt(),
      sellerBusiness: json['seller_business'] != null
          ? OfferBusinessRef.fromJson(json['seller_business'] as Map<String, dynamic>)
          : null,
      ownerBusiness: json['owner_business'] != null
          ? OfferBusinessRef.fromJson(json['owner_business'] as Map<String, dynamic>)
          : null,
      displayTitle: json['display_title'] as String? ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      discountType: json['discount_type'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      isRefundable: json['is_refundable'] as bool? ?? false,
      paymentModel: json['payment_model'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      isBoosted: json['is_boosted'] as bool? ?? false,
      availabilityMode: json['availability_mode'] as String? ?? '',
      availableQuantity: (json['available_quantity'] as num?)?.toInt(),
    );
  }
}

class OfferComparisonResult {
  final List<OfferComparisonRow> offers;
  final OfferComparisonRow? lowestPrice;

  const OfferComparisonResult({this.offers = const [], this.lowestPrice});

  factory OfferComparisonResult.fromJson(Map<String, dynamic> json) {
    return OfferComparisonResult(
      offers: (json['offers'] as List<dynamic>? ?? [])
          .map((e) => OfferComparisonRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      lowestPrice: json['lowest_price'] != null
          ? OfferComparisonRow.fromJson(json['lowest_price'] as Map<String, dynamic>)
          : null,
    );
  }
}
