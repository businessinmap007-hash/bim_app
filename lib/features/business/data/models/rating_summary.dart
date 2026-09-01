/// Mirrors `RatingService::summaryFor()` — the subjective star review
/// aggregate is what the business page shows; the operational rates
/// (success/cancel/dispute) exist for future trust-score surfaces, not this
/// header.
class RatingSummary {
  final int reviewCount;
  final double starsAverage;
  final int totalOperations;
  final double successRate;

  const RatingSummary({
    required this.reviewCount,
    required this.starsAverage,
    required this.totalOperations,
    required this.successRate,
  });

  bool get hasReviews => reviewCount > 0;

  factory RatingSummary.fromJson(Map<String, dynamic> json) => RatingSummary(
    reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    starsAverage: (json['stars_average'] as num?)?.toDouble() ?? 0.0,
    totalOperations: (json['total_operations'] as num?)?.toInt() ?? 0,
    successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
  );
}
