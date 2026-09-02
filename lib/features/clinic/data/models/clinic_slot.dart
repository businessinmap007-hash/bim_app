/// One open appointment slot a clinic has published — mirrors
/// `ClinicAppointmentController::slots()`'s row shape.
class ClinicSlot {
  final int id;
  final DateTime? startsAt;
  final int durationMinutes;
  final String? visitKind;
  final double? price;

  const ClinicSlot({
    required this.id,
    this.startsAt,
    required this.durationMinutes,
    this.visitKind,
    this.price,
  });

  factory ClinicSlot.fromJson(Map<String, dynamic> json) => ClinicSlot(
    id: json['id'] as int,
    startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
    durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
    visitKind: json['visit_kind'] as String?,
    price: (json['price'] as num?)?.toDouble(),
  );
}
