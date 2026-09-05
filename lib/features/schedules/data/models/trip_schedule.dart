import '../../../../core/env/env.dart';

/// The reliability signal shown next to a search result — mirrors
/// `TripScheduleService::emptyTrust()`'s shape. Only the pieces worth
/// showing a customer picking between carriers.
class TripTrust {
  final double starsAverage;
  final int reviewCount;
  final double successRate;

  const TripTrust({required this.starsAverage, required this.reviewCount, required this.successRate});

  factory TripTrust.fromJson(Map<String, dynamic> json) => TripTrust(
    starsAverage: (json['stars_average'] as num?)?.toDouble() ?? 0,
    reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    successRate: (json['success_rate'] as num?)?.toDouble() ?? 0,
  );
}

/// One published waypoint on a leg — mirrors `TripScheduleController`'s
/// `stops` entries. No lat/lng: `address` is a free-text destination for the
/// Google Maps deep link (see MapsLauncher), never a map picker.
class TripStop {
  final int id;
  final int sequence;
  final String label;
  final String? address;
  final int? businessId;
  final double? lat;
  final double? lng;

  const TripStop({
    required this.id,
    required this.sequence,
    required this.label,
    this.address,
    this.businessId,
    this.lat,
    this.lng,
  });

  factory TripStop.fromJson(Map<String, dynamic> json) => TripStop(
    id: json['id'] as int,
    sequence: json['sequence'] as int? ?? 0,
    label: json['label'] as String? ?? '',
    address: json['address'] as String?,
    businessId: json['business_id'] as int?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );

  /// What to hand MapsLauncher — a precise coordinate when this stop is a
  /// registered business's own GPS location, else the typed address, else
  /// just the label.
  String get navigationDestination {
    if (lat != null && lng != null) return '$lat,$lng';
    if (address != null && address!.isNotEmpty) return address!;
    return label;
  }
}

/// One trip leg a carrier publishes — mirrors `TripScheduleController`'s
/// `serialize()`. Domestic (governorate pair) search only; international
/// (country pair) isn't wired up in this app yet.
class TripSchedule {
  final int id;
  final String? businessName;
  final String? businessLogoUrl;
  final String mode;
  final String? vehicleLabel;
  final String? originGovernorate;
  final String? destinationGovernorate;
  final String schedulePattern;
  final int? dayOfWeek;
  final DateTime? tripDate;
  final String? departureTime;
  final int? capacity;
  final double? price;
  final String currency;
  final List<TripStop> stops;

  const TripSchedule({
    required this.id,
    this.businessName,
    this.businessLogoUrl,
    required this.mode,
    this.vehicleLabel,
    this.originGovernorate,
    this.destinationGovernorate,
    required this.schedulePattern,
    this.dayOfWeek,
    this.tripDate,
    this.departureTime,
    this.capacity,
    this.price,
    required this.currency,
    this.stops = const [],
  });

  factory TripSchedule.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final origin = json['origin'] as Map<String, dynamic>? ?? const {};
    final destination = json['destination'] as Map<String, dynamic>? ?? const {};
    return TripSchedule(
      id: json['id'] as int,
      businessName: business?['name'] as String?,
      businessLogoUrl: Env.assetUrl(business?['logo'] as String?),
      mode: json['mode'] as String? ?? '',
      vehicleLabel: json['vehicle_label'] as String? ?? (json['vehicle_type'] as Map<String, dynamic>?)?['name'] as String?,
      originGovernorate: origin['governorate'] as String?,
      destinationGovernorate: destination['governorate'] as String?,
      schedulePattern: json['schedule_pattern'] as String? ?? 'weekly',
      dayOfWeek: json['day_of_week'] as int?,
      tripDate: json['trip_date'] != null ? DateTime.tryParse(json['trip_date'] as String) : null,
      departureTime: json['departure_time'] as String?,
      capacity: json['capacity'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      stops: (json['stops'] as List<dynamic>? ?? []).map((e) => TripStop.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  bool get isPassengerMode => mode == 'passenger' || mode == 'limousine';
  bool get isFreightMode => mode == 'freight' || mode == 'distribution';
}

/// One `/schedules` search result — the leg plus the carrier's trust
/// snapshot and how many units are still free.
class TripScheduleResult {
  final TripSchedule schedule;
  final TripTrust trust;
  final int? remainingCapacity;

  const TripScheduleResult({required this.schedule, required this.trust, this.remainingCapacity});

  factory TripScheduleResult.fromJson(Map<String, dynamic> json) => TripScheduleResult(
    schedule: TripSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
    trust: TripTrust.fromJson(json['trust'] as Map<String, dynamic>? ?? const {}),
    remainingCapacity: json['remaining_capacity'] as int?,
  );
}
