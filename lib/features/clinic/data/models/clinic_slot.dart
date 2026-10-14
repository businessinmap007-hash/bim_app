import '../../../../core/time/egypt_time.dart';
/// One open appointment slot a clinic has published — mirrors
/// `ClinicAppointmentController::slots()`'s row shape.
class ClinicSlot {
  final int id;
  final DateTime? startsAt;
  final int durationMinutes;
  final String? visitKind;

  /// The kind's key (`booking_examination`…): what the board's radio list filters by.
  final String? visitKindKey;
  final double? price;

  const ClinicSlot({
    required this.id,
    this.startsAt,
    required this.durationMinutes,
    this.visitKind,
    this.visitKindKey,
    this.price,
  });

  factory ClinicSlot.fromJson(Map<String, dynamic> json) => ClinicSlot(
    id: json['id'] as int,
    startsAt: json['starts_at'] != null ? EgyptTime.tryParse(json['starts_at'] as String) : null,
    durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
    visitKind: json['visit_kind'] as String?,
    visitKindKey: json['visit_kind_key'] as String?,
    // a number, but a decimal column may still arrive as «400.00» — never let a price take the board down
    price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse('${json['price'] ?? ''}'),
  );
}

/// One day of the booking window: whether the clinic sits that day (its weekly hours) and how many open times are left.
class ClinicDay {
  final DateTime date;
  final bool open;
  final String? opensAt;
  final String? closesAt;
  final int slots;

  const ClinicDay({required this.date, this.open = true, this.opensAt, this.closesAt, this.slots = 0});

  factory ClinicDay.fromJson(Map<String, dynamic> json) {
    final hours = json['hours'] is Map<String, dynamic> ? json['hours'] as Map<String, dynamic> : null;
    final parsed = DateTime.tryParse('${json['date'] ?? ''}');

    return ClinicDay(
      date: DateTime((parsed ?? DateTime.now()).year, (parsed ?? DateTime.now()).month, (parsed ?? DateTime.now()).day),
      open: json['open'] as bool? ?? true,
      opensAt: hours?['open'] as String?,
      closesAt: hours?['close'] as String?,
      slots: (json['slots'] as num?)?.toInt() ?? 0,
    );
  }
}

/// What `GET /clinics/{id}/slots` says: the open times of the next two weeks, and the strip of those days.
class ClinicSlotsResult {
  final List<ClinicSlot> slots;
  final List<ClinicDay> days;

  const ClinicSlotsResult({this.slots = const [], this.days = const []});
}
