/// The objective operation-outcome summary — same shape RatingController
/// returns for both `me` and the public `show`. See RatingService::summaryFor.
class RatingSummary {
  final String role;
  final int totalOperations;
  final int successCount;
  final int cancelledCount;
  final int disputedCount;
  final int faultCount;
  final int vindicatedCount;
  final double successRate;
  final double cancelRate;
  final double disputeRate;
  final double faultRate;
  final double vindicationRate;
  final int reviewCount;
  final double starsAverage;

  const RatingSummary({
    required this.role,
    required this.totalOperations,
    required this.successCount,
    required this.cancelledCount,
    required this.disputedCount,
    required this.faultCount,
    required this.vindicatedCount,
    required this.successRate,
    required this.cancelRate,
    required this.disputeRate,
    required this.faultRate,
    required this.vindicationRate,
    required this.reviewCount,
    required this.starsAverage,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) => RatingSummary(
    role: json['role'] as String,
    totalOperations: json['total_operations'] as int,
    successCount: json['success_count'] as int,
    cancelledCount: json['cancelled_count'] as int,
    disputedCount: json['disputed_count'] as int,
    faultCount: json['fault_count'] as int,
    vindicatedCount: json['vindicated_count'] as int,
    successRate: (json['success_rate'] as num).toDouble(),
    cancelRate: (json['cancel_rate'] as num).toDouble(),
    disputeRate: (json['dispute_rate'] as num).toDouble(),
    faultRate: (json['fault_rate'] as num).toDouble(),
    vindicationRate: (json['vindication_rate'] as num).toDouble(),
    reviewCount: json['review_count'] as int,
    starsAverage: (json['stars_average'] as num).toDouble(),
  );
}

/// GET/POST /ratings/me, /ratings/enable — see Api\V2\RatingController.
/// `ratingEnabled`/`feeAutoChargeEnabled` are the same per-user consent
/// flags a guarantee purchase or an escrow deposit auto-forces on; this is
/// the only place a user can see that status or open it themselves without
/// going through either of those.
class MyRating {
  final int userId;
  final RatingSummary rating;
  final bool ratingEnabled;
  final bool feeAutoChargeEnabled;

  const MyRating({
    required this.userId,
    required this.rating,
    required this.ratingEnabled,
    required this.feeAutoChargeEnabled,
  });

  factory MyRating.fromJson(Map<String, dynamic> json) => MyRating(
    userId: json['user_id'] as int,
    rating: RatingSummary.fromJson(json['rating'] as Map<String, dynamic>),
    ratingEnabled: json['rating_enabled'] as bool,
    feeAutoChargeEnabled: json['fee_auto_charge_enabled'] as bool,
  );
}
