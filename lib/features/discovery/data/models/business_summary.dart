import '../../../../core/env/env.dart';

/// One row from GET /discovery/businesses.
class BusinessSummary {
  final int id;
  final String name;
  final String? logoUrl;
  final int categoryId;
  final int categoryChildId;
  final bool hasPrices;
  final bool isOpenNow;

  /// Only present on GET /discovery/recommended — null on /discovery/
  /// businesses, which never selects them. `reviewCount == 0` reads as
  /// "not yet rated", not "rated zero".
  final double? starsAverage;
  final int reviewCount;

  const BusinessSummary({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.categoryId,
    required this.categoryChildId,
    required this.hasPrices,
    required this.isOpenNow,
    this.starsAverage,
    this.reviewCount = 0,
  });

  factory BusinessSummary.fromJson(Map<String, dynamic> json) =>
      BusinessSummary(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        logoUrl: Env.assetUrl(json['logo'] as String?),
        categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
        categoryChildId: (json['category_child_id'] as num?)?.toInt() ?? 0,
        hasPrices: json['has_prices'] as bool? ?? false,
        isOpenNow: json['is_open_now'] as bool? ?? true,
        starsAverage: (json['stars_average'] as num?)?.toDouble(),
        reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      );
}
