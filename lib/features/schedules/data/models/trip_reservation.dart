import '../../../../core/deposit/visit_deposit.dart';
import '../../../../core/time/egypt_time.dart';
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
  // Only present on the carrier's own incoming() list — the backend never
  // serializes a client name, just the id, so that's all there is to show.
  final int? clientId;

  /// `app` or `offline` — an off-app seat is held by the carrier for a named passenger with no account.
  final String source;
  final String? passengerName;
  final String? passengerPhone;

  /// An off-app passenger counts in ratings and in the completed/pending numbers only once the fee is paid.
  final bool ratingVisible;

  /// Attendance needs both sides: the customer first, then the carrier.
  final DateTime? clientConfirmedAt;
  final DateTime? carrierConfirmedAt;

  /// «عربون الجدية» of this reservation: quoted until the carrier confirms, then held / returned / disputed.
  final VisitDeposit? deposit;

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
    this.clientId,
    this.source = 'app',
    this.passengerName,
    this.passengerPhone,
    this.ratingVisible = false,
    this.clientConfirmedAt,
    this.carrierConfirmedAt,
    this.deposit,
  });

  bool get isOffline => source == 'offline';
  bool get clientConfirmed => clientConfirmedAt != null;
  bool get carrierConfirmed => carrierConfirmedAt != null;

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
    createdAt: json['created_at'] != null ? EgyptTime.tryParse(json['created_at'] as String) : null,
    clientId: (json['client_id'] as num?)?.toInt(),
    source: json['source'] as String? ?? 'app',
    passengerName: json['passenger_name'] as String?,
    passengerPhone: json['passenger_phone'] as String?,
    ratingVisible: json['rating_visible'] == true,
    clientConfirmedAt: json['client_confirmed_at'] != null ? EgyptTime.tryParse(json['client_confirmed_at'] as String) : null,
    carrierConfirmedAt: json['carrier_confirmed_at'] != null ? EgyptTime.tryParse(json['carrier_confirmed_at'] as String) : null,
    deposit: VisitDeposit.fromJsonOrNull(json['deposit']),
  );
}
