/// Mirrors `TripReservationController::serialize()` — the customer's own
/// reservation on a trip leg. Note: the backend eager-loads `schedule` and
/// `business` for this list but never actually serializes them, so this
/// model (deliberately) only carries what the API response really has —
/// no route/carrier name to show, just the reservation's own numbers.
class TripReservation {
  final int id;
  final int tripScheduleId;
  final int units;
  final double? unitPrice;
  final double? totalPrice;
  final String currency;
  final String status;
  final String? notes;
  final DateTime? createdAt;

  const TripReservation({
    required this.id,
    required this.tripScheduleId,
    required this.units,
    this.unitPrice,
    this.totalPrice,
    required this.currency,
    required this.status,
    this.notes,
    this.createdAt,
  });

  bool get isCancellable => status == 'pending' || status == 'confirmed';

  factory TripReservation.fromJson(Map<String, dynamic> json) => TripReservation(
    id: json['id'] as int,
    tripScheduleId: json['trip_schedule_id'] as int,
    units: (json['units'] as num?)?.toInt() ?? 1,
    unitPrice: (json['unit_price'] as num?)?.toDouble(),
    totalPrice: (json['total_price'] as num?)?.toDouble(),
    currency: json['currency'] as String? ?? 'EGP',
    status: json['status'] as String? ?? 'pending',
    notes: json['notes'] as String?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
