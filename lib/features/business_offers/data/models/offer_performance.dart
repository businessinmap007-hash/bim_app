/// One event type's aggregate — Api\V2\OfferTrackingController::myPerformance
/// `totals` map (keyed by event_type: view/click/lead/conversion/share/save).
class EventTypeTotal {
  final String eventType;
  final int total;
  final double valueTotal;

  const EventTypeTotal({required this.eventType, required this.total, required this.valueTotal});

  factory EventTypeTotal.fromJson(String eventType, Map<String, dynamic> json) => EventTypeTotal(
    eventType: eventType,
    total: (json['total'] as num?)?.toInt() ?? 0,
    valueTotal: double.tryParse(json['value_total']?.toString() ?? '') ?? 0,
  );
}

/// One (offer, event_type) row from the `offer_stats` breakdown.
class OfferEventStat {
  final int offerId;
  final String eventType;
  final int total;
  final double valueTotal;

  const OfferEventStat({
    required this.offerId,
    required this.eventType,
    required this.total,
    required this.valueTotal,
  });

  factory OfferEventStat.fromJson(Map<String, dynamic> json) => OfferEventStat(
    offerId: (json['offer_id'] as num).toInt(),
    eventType: json['event_type'] as String? ?? '',
    total: (json['total'] as num?)?.toInt() ?? 0,
    // Unlike `totals`, this comes off a raw SQL decimal SUM() and is
    // serialized as a string ("70.00"), not a number.
    valueTotal: double.tryParse(json['value_total']?.toString() ?? '') ?? 0,
  );
}

class OfferPerformance {
  final List<EventTypeTotal> totals;
  final List<OfferEventStat> offerStats;

  const OfferPerformance({this.totals = const [], this.offerStats = const []});

  /// [offerStats] grouped by offer id, each with its per-event-type counts.
  Map<int, List<OfferEventStat>> statsByOffer() {
    final map = <int, List<OfferEventStat>>{};
    for (final stat in offerStats) {
      (map[stat.offerId] ??= []).add(stat);
    }
    return map;
  }

  factory OfferPerformance.fromJson(Map<String, dynamic> json) {
    final totalsJson = json['totals'] as Map<String, dynamic>? ?? const {};
    return OfferPerformance(
      totals: totalsJson.entries
          .map((e) => EventTypeTotal.fromJson(e.key, e.value as Map<String, dynamic>))
          .toList(),
      offerStats: (json['offer_stats'] as List<dynamic>? ?? [])
          .map((e) => OfferEventStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
