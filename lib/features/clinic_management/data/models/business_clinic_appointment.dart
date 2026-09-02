/// The clinic's own view of an appointment — see
/// Api\V2\BusinessClinicAppointmentController::serialize.
class BusinessClinicAppointment {
  final int id;
  final String status;
  final DateTime? scheduledAt;
  final int durationMinutes;
  final String? reason;
  final String? notes;
  final int? prescriptionId;
  final int patientId;
  final String? patientName;
  final String? patientPhone;

  const BusinessClinicAppointment({
    required this.id,
    required this.status,
    this.scheduledAt,
    required this.durationMinutes,
    this.reason,
    this.notes,
    this.prescriptionId,
    required this.patientId,
    this.patientName,
    this.patientPhone,
  });

  factory BusinessClinicAppointment.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?;
    return BusinessClinicAppointment(
      id: json['id'] as int,
      status: json['status'] as String,
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'] as String) : null,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      prescriptionId: json['prescription_id'] as int?,
      patientId: patient?['id'] as int? ?? 0,
      patientName: patient?['name'] as String?,
      patientPhone: patient?['phone'] as String?,
    );
  }
}
