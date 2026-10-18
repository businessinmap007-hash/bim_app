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

  /// Only the carrier is told the passenger's name; null for everyone else.
  final String? clientName;

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

  /// Where and when it is, and the carrier the customer booked (null on an old payload).
  final TripReservationLeg? leg;
  final String? businessName;

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
    this.clientName,
    this.source = 'app',
    this.passengerName,
    this.passengerPhone,
    this.ratingVisible = false,
    this.clientConfirmedAt,
    this.carrierConfirmedAt,
    this.deposit,
    this.leg,
    this.businessName,
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
    clientName: json['client_name'] as String?,
    source: json['source'] as String? ?? 'app',
    passengerName: json['passenger_name'] as String?,
    passengerPhone: json['passenger_phone'] as String?,
    ratingVisible: json['rating_visible'] == true,
    clientConfirmedAt: json['client_confirmed_at'] != null ? EgyptTime.tryParse(json['client_confirmed_at'] as String) : null,
    carrierConfirmedAt: json['carrier_confirmed_at'] != null ? EgyptTime.tryParse(json['carrier_confirmed_at'] as String) : null,
    deposit: VisitDeposit.fromJsonOrNull(json['deposit']),
    leg: json['leg'] is Map<String, dynamic> ? TripReservationLeg.fromJson(json['leg'] as Map<String, dynamic>) : null,
    businessName: (json['business'] as Map<String, dynamic>?)?['name'] as String?,
  );
}

/// The leg a reservation is on, named for the screen: where, when and what kind (mirrors
/// `TripReservationController::leg()`).
class TripReservationLeg {
  final int id;
  final String mode;
  final bool isReturnLeg;
  final String originCity;
  final String originGovernorate;
  final String destinationCity;
  final String destinationGovernorate;
  final String pattern;
  final int? dayOfWeek;

  /// The day of a one-off leg and the time of day (Cairo wall clock), combined; null when the leg has none.
  final DateTime? departsAt;

  /// Only the time of day, for a weekly leg that has no single date.
  final String? departureTime;
  final String? vehicleLabel;

  const TripReservationLeg({
    required this.id,
    required this.mode,
    required this.isReturnLeg,
    required this.originCity,
    required this.originGovernorate,
    required this.destinationCity,
    required this.destinationGovernorate,
    required this.pattern,
    this.dayOfWeek,
    this.departsAt,
    this.departureTime,
    this.vehicleLabel,
  });

  /// «Abu Dirda ← Cairo airport»; the governorate stands in for a leg with no city.
  String get originLabel => originCity.isNotEmpty ? originCity : originGovernorate;
  String get destinationLabel => destinationCity.isNotEmpty ? destinationCity : destinationGovernorate;

  factory TripReservationLeg.fromJson(Map<String, dynamic> json) {
    final origin = json['origin'] as Map<String, dynamic>? ?? const {};
    final destination = json['destination'] as Map<String, dynamic>? ?? const {};
    final date = json['trip_date'] as String?;
    final time = json['departure_time'] as String?;

    DateTime? departs;
    if (date != null) {
      // «2026-10-20» + «14:30:00»: wall-clock digits that are already Cairo's
      departs = DateTime.tryParse('$date ${time ?? '00:00:00'}');
    }

    return TripReservationLeg(
      id: (json['id'] as num).toInt(),
      mode: json['mode'] as String? ?? '',
      isReturnLeg: json['is_return_leg'] as bool? ?? false,
      originCity: origin['city'] as String? ?? '',
      originGovernorate: origin['governorate'] as String? ?? '',
      destinationCity: destination['city'] as String? ?? '',
      destinationGovernorate: destination['governorate'] as String? ?? '',
      pattern: json['pattern'] as String? ?? '',
      dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
      departsAt: departs,
      departureTime: time,
      vehicleLabel: json['vehicle_label'] as String?,
    );
  }
}
