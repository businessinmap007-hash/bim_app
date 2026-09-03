/// The business's "business_offers" subscription quota — see
/// BusinessOffersSubscriptionService::usage.
class OffersUsage {
  final int maxActiveOffers;
  final int activeOffers;
  final int remainingOffers;
  final bool requiresSubscription;

  const OffersUsage({
    required this.maxActiveOffers,
    required this.activeOffers,
    required this.remainingOffers,
    required this.requiresSubscription,
  });

  factory OffersUsage.fromJson(Map<String, dynamic> json) => OffersUsage(
    maxActiveOffers: (json['max_active_offers'] as num?)?.toInt() ?? 0,
    activeOffers: (json['active_offers'] as num?)?.toInt() ?? 0,
    remainingOffers: (json['remaining_offers'] as num?)?.toInt() ?? 0,
    requiresSubscription: json['requires_subscription'] as bool? ?? true,
  );
}
