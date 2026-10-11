import '../../../../core/env/env.dart';

/// Mirrors `ClinicAppointmentController::serialize()` — the patient's own
/// clinic appointment.
class ClinicAppointment {
  final int id;
  final String status;
  final DateTime? scheduledAt;
  final int durationMinutes;
  final String? reason;
  final int? clinicId;
  final String? clinicName;
  final String? clinicLogoUrl;
  final int? prescriptionId;

  /// «يجب التواجد قبل الموعد بـ ١٥ دقيقة» — the clinic's own notice.
  final String? arrivalNotice;

  const ClinicAppointment({
    required this.id,
    required this.status,
    this.scheduledAt,
    required this.durationMinutes,
    this.reason,
    this.clinicId,
    this.clinicName,
    this.clinicLogoUrl,
    this.prescriptionId,
    this.arrivalNotice,
  });

  bool get isCancellable => status == 'requested' || status == 'confirmed';

  /// cancel()/reschedule() return the appointment with only `clinic: {id}` —
  /// no name/logo — so callers merge onto the list item instead of replacing
  /// it wholesale, keeping the display fields the mutation response omits.
  ClinicAppointment copyWith({
    String? status,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? reason,
  }) {
    return ClinicAppointment(
      id: id,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reason: reason ?? this.reason,
      clinicId: clinicId,
      clinicName: clinicName,
      clinicLogoUrl: clinicLogoUrl,
      prescriptionId: prescriptionId,
      arrivalNotice: arrivalNotice,
    );
  }

  factory ClinicAppointment.fromJson(Map<String, dynamic> json) {
    final clinic = json['clinic'] as Map<String, dynamic>?;
    return ClinicAppointment(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'requested',
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'] as String) : null,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String?,
      clinicId: clinic?['id'] as int?,
      clinicName: clinic?['name'] as String?,
      clinicLogoUrl: Env.assetUrl(clinic?['logo'] as String?),
      prescriptionId: json['prescription_id'] as int?,
      arrivalNotice: json['arrival_notice'] is Map<String, dynamic> ? (json['arrival_notice'] as Map<String, dynamic>)['message'] as String? : null,
    );
  }
}
