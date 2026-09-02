/// One of the clinic's own published slots — see
/// Api\V2\BusinessClinicAppointmentController::slotsIndex.
class BusinessClinicSlot {
  final int id;
  final DateTime? startsAt;
  final int durationMinutes;
  final int? servicePriceId;
  final String? visitKind;
  final int? appointmentId;
  final bool isOpen;

  const BusinessClinicSlot({
    required this.id,
    this.startsAt,
    required this.durationMinutes,
    this.servicePriceId,
    this.visitKind,
    this.appointmentId,
    required this.isOpen,
  });

  factory BusinessClinicSlot.fromJson(Map<String, dynamic> json) => BusinessClinicSlot(
    id: json['id'] as int,
    startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
    durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
    servicePriceId: json['service_price_id'] as int?,
    visitKind: json['visit_kind'] as String?,
    appointmentId: json['appointment_id'] as int?,
    isOpen: json['is_open'] as bool,
  );
}
