import '../../../../core/env/env.dart';
import '../../../../core/time/egypt_time.dart';

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

  /// The services the patient named when booking, each with the price asked at the time.
  final List<BookedService> services;

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
    this.services = const [],
    this.arrivalNotice,
  });

  bool get isCancellable => status == 'requested' || status == 'confirmed';

  /// The names of the services named, in the order named — «فيلر الشفاه، ليزر إزالة الشعر».
  String get servicesLine => services.map((s) => s.name).where((n) => n.isNotEmpty).join('، ');

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
      services: services,
      arrivalNotice: arrivalNotice,
    );
  }

  factory ClinicAppointment.fromJson(Map<String, dynamic> json) {
    final clinic = json['clinic'] as Map<String, dynamic>?;
    return ClinicAppointment(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'requested',
      scheduledAt: json['scheduled_at'] != null ? EgyptTime.tryParse(json['scheduled_at'] as String) : null,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String?,
      clinicId: clinic?['id'] as int?,
      clinicName: clinic?['name'] as String?,
      clinicLogoUrl: Env.assetUrl(clinic?['logo'] as String?),
      prescriptionId: json['prescription_id'] as int?,
      services: BookedService.listFrom(json['specialty_services']),
      arrivalNotice: json['arrival_notice'] is Map<String, dynamic> ? (json['arrival_notice'] as Map<String, dynamic>)['message'] as String? : null,
    );
  }
}

/// One service a patient named when booking: its name and the price asked at the time (null = after the exam).
class BookedService {
  final String name;
  final double? price;

  const BookedService({required this.name, this.price});

  factory BookedService.fromJson(Map<String, dynamic> json) => BookedService(
    name: json['name'] as String? ?? '',
    price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse('${json['price'] ?? ''}'),
  );

  static List<BookedService> listFrom(dynamic raw) =>
      [for (final e in (raw as List<dynamic>? ?? const [])) BookedService.fromJson(e as Map<String, dynamic>)];
}
