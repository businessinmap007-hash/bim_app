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

  /// The account of the visit: the fee (paid on arrival), the services once done, what was paid, what is left.
  final VisitBilling? billing;

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
    this.billing,
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
    VisitBilling? billing,
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
      billing: billing ?? this.billing,
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
      billing: VisitBilling.fromJsonOrNull(json['billing']),
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

double? _num(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

/// One named service on the account: the price listed, what the clinic finally charged, and whether it counts yet.
class BillingService {
  final int itemId;
  final String name;
  final double? price;
  final double? finalPrice;

  /// What the service costs the patient now; null while it is not charged (the visit is not done).
  final double? amount;
  final bool counted;

  const BillingService({required this.itemId, required this.name, this.price, this.finalPrice, this.amount, this.counted = false});

  factory BillingService.fromJson(Map<String, dynamic> j) => BillingService(
    itemId: (j['item_id'] as num?)?.toInt() ?? 0,
    name: j['name'] as String? ?? '',
    price: _num(j['price']),
    finalPrice: _num(j['final_price']),
    amount: _num(j['amount']),
    counted: j['counted'] as bool? ?? false,
  );
}

/// One amount the clinic recorded as paid (the visit fee, or a service — possibly an instalment).
class VisitPayment {
  final int id;
  final double amount;
  final String kind;
  final String? note;
  final DateTime? paidAt;
  final String? recordedBy;

  /// `pending` (the patient has not answered) | `confirmed` | `disputed`.
  final String confirmation;
  final String? disputeNote;

  /// A payment the patient confirmed is no longer the clinic's to remove.
  final bool canRemove;

  const VisitPayment({
    required this.id,
    required this.amount,
    required this.kind,
    this.note,
    this.paidAt,
    this.recordedBy,
    this.confirmation = 'pending',
    this.disputeNote,
    this.canRemove = true,
  });

  factory VisitPayment.fromJson(Map<String, dynamic> j) => VisitPayment(
    id: (j['id'] as num?)?.toInt() ?? 0,
    amount: _num(j['amount']) ?? 0,
    kind: j['kind'] as String? ?? 'service',
    note: j['note'] as String?,
    paidAt: j['paid_at'] != null ? EgyptTime.tryParse(j['paid_at'] as String) : null,
    recordedBy: j['recorded_by'] as String?,
    confirmation: j['confirmation'] as String? ?? 'pending',
    disputeNote: j['dispute_note'] as String?,
    canRemove: j['can_remove'] as bool? ?? true,
  );
}

/// Mirrors `ClinicBillingService::summary()`.
class VisitBilling {
  final double? visitFee;
  final List<BillingService> services;
  final double servicesTotal;
  final double total;
  final double paid;
  final double remaining;

  /// A named service is not charged yet (the visit is not done): the total is the visit fee until then.
  final bool servicesPending;
  final List<VisitPayment> payments;

  /// Payments the patient has not answered yet.
  final int awaitingConfirmation;

  /// What the clinic will ask at the NEXT session (null = what is left).
  final double? installmentAmount;

  /// What the patient still owes this clinic from earlier visits (`carriedOver`), and what is asked with this one.
  final double carriedOver;
  final double carriedOverDue;

  const VisitBilling({
    this.visitFee,
    this.services = const [],
    this.servicesTotal = 0,
    this.total = 0,
    this.paid = 0,
    this.remaining = 0,
    this.servicesPending = false,
    this.payments = const [],
    this.awaitingConfirmation = 0,
    this.installmentAmount,
    this.carriedOver = 0,
    this.carriedOverDue = 0,
  });

  static VisitBilling? fromJsonOrNull(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;

    return VisitBilling(
      visitFee: _num(raw['visit_fee']),
      services: [for (final e in (raw['services'] as List<dynamic>? ?? const [])) BillingService.fromJson(e as Map<String, dynamic>)],
      servicesTotal: _num(raw['services_total']) ?? 0,
      total: _num(raw['total']) ?? 0,
      paid: _num(raw['paid']) ?? 0,
      remaining: _num(raw['remaining']) ?? 0,
      servicesPending: raw['services_pending'] as bool? ?? false,
      payments: [for (final e in (raw['payments'] as List<dynamic>? ?? const [])) VisitPayment.fromJson(e as Map<String, dynamic>)],
      awaitingConfirmation: (raw['awaiting_confirmation'] as num?)?.toInt() ?? 0,
      installmentAmount: _num(raw['installment_amount']),
      carriedOver: _num((raw['carried_over'] as Map<String, dynamic>?)?['amount']) ?? 0,
      carriedOverDue: _num((raw['carried_over'] as Map<String, dynamic>?)?['due']) ?? 0,
    );
  }
}

/// One visit kind the clinic prices — an option of the radio list, with its fee.
class VisitKindOption {
  final String key;
  final String name;
  final double? price;
  final int? durationMinutes;

  const VisitKindOption({required this.key, required this.name, this.price, this.durationMinutes});

  factory VisitKindOption.fromJson(Map<String, dynamic> j) => VisitKindOption(
    key: j['key'] as String? ?? '',
    name: j['name'] as String? ?? '',
    price: _num(j['price']),
    durationMinutes: (j['duration_minutes'] as num?)?.toInt(),
  );
}

/// `GET clinics/{id}/visit-kinds`: every kind the clinic prices, and what the caller still owes the clinic.
class VisitKindsResult {
  final List<VisitKindOption> kinds;
  final double balance;
  final double balanceDue;

  const VisitKindsResult({this.kinds = const [], this.balance = 0, this.balanceDue = 0});

  factory VisitKindsResult.fromJson(Map<String, dynamic> j) {
    final b = j['my_balance'] as Map<String, dynamic>?;

    return VisitKindsResult(
      kinds: [for (final e in (j['kinds'] as List<dynamic>? ?? const [])) VisitKindOption.fromJson(e as Map<String, dynamic>)],
      balance: _num(b?['amount']) ?? 0,
      balanceDue: _num(b?['due']) ?? 0,
    );
  }
}
