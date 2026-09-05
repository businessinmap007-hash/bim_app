/// A snapshot of one stop for one live run — mirrors `TripRunController`'s
/// `serialize()`. Exactly one of these is ever `heading` or `arrived` at a
/// time; that one is the "current" stop the driver's action button acts on.
class TripRunStop {
  final int id;
  final int sequence;
  final String label;
  final String? address;
  final double? lat;
  final double? lng;
  final String status; // pending | heading | arrived | done
  final DateTime? arrivedAt;
  final DateTime? completedAt;

  const TripRunStop({
    required this.id,
    required this.sequence,
    required this.label,
    this.address,
    this.lat,
    this.lng,
    required this.status,
    this.arrivedAt,
    this.completedAt,
  });

  bool get isHeading => status == 'heading';
  bool get isArrived => status == 'arrived';
  bool get isDone => status == 'done';

  /// What to hand MapsLauncher — a precise coordinate when this stop was a
  /// registered business's own GPS location, else the typed address, else
  /// just the label.
  String get navigationDestination {
    if (lat != null && lng != null) return '$lat,$lng';
    if (address != null && address!.isNotEmpty) return address!;
    return label;
  }

  factory TripRunStop.fromJson(Map<String, dynamic> json) => TripRunStop(
    id: json['id'] as int,
    sequence: json['sequence'] as int? ?? 0,
    label: json['label'] as String? ?? '',
    address: json['address'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    status: json['status'] as String? ?? 'pending',
    arrivedAt: json['arrived_at'] != null ? DateTime.tryParse(json['arrived_at'] as String) : null,
    completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
  );
}

/// One cargo line on a freight/distribution run — `remainingQty` is only
/// ever non-null once the run is completed (it's computed server-side).
class TripRunManifestItem {
  final int id;
  final String label;
  final String? unit;
  final int assignedQty;
  final int? deliveredQty;
  final int? returnedQty;
  final int? remainingQty;

  const TripRunManifestItem({
    required this.id,
    required this.label,
    this.unit,
    required this.assignedQty,
    this.deliveredQty,
    this.returnedQty,
    this.remainingQty,
  });

  factory TripRunManifestItem.fromJson(Map<String, dynamic> json) => TripRunManifestItem(
    id: json['id'] as int,
    label: json['label'] as String? ?? '',
    unit: json['unit'] as String?,
    assignedQty: json['assigned_qty'] as int? ?? 0,
    deliveredQty: json['delivered_qty'] as int?,
    returnedQty: json['returned_qty'] as int?,
    remainingQty: json['remaining_qty'] as int?,
  );
}

/// One live execution of a trip leg — mirrors `TripRunController`'s
/// `serialize()`. See TripRunService for the state machine this walks.
class TripRun {
  final int id;
  final int tripScheduleId;
  final String? mode;
  final String? vehicleLabel;
  final String status; // in_progress | awaiting_reconciliation | completed
  final int? passengerCount;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? currentStopId;
  final List<TripRunStop> stops;
  final List<TripRunManifestItem> manifestItems;

  const TripRun({
    required this.id,
    required this.tripScheduleId,
    this.mode,
    this.vehicleLabel,
    required this.status,
    this.passengerCount,
    this.startedAt,
    this.completedAt,
    this.currentStopId,
    this.stops = const [],
    this.manifestItems = const [],
  });

  bool get isInProgress => status == 'in_progress';
  bool get isAwaitingReconciliation => status == 'awaiting_reconciliation';
  bool get isCompleted => status == 'completed';

  TripRunStop? get currentStop {
    if (currentStopId == null) return null;
    final matches = stops.where((s) => s.id == currentStopId);
    return matches.isEmpty ? null : matches.first;
  }

  factory TripRun.fromJson(Map<String, dynamic> json) => TripRun(
    id: json['id'] as int,
    tripScheduleId: json['trip_schedule_id'] as int,
    mode: json['mode'] as String?,
    vehicleLabel: json['vehicle_label'] as String?,
    status: json['status'] as String? ?? 'in_progress',
    passengerCount: json['passenger_count'] as int?,
    startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
    completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
    currentStopId: json['current_stop_id'] as int?,
    stops: (json['stops'] as List<dynamic>? ?? []).map((e) => TripRunStop.fromJson(e as Map<String, dynamic>)).toList(),
    manifestItems: (json['manifest_items'] as List<dynamic>? ?? [])
        .map((e) => TripRunManifestItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
