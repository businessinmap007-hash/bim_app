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
