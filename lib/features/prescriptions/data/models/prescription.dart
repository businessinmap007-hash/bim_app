import '../../../../core/env/env.dart';

/// A scan of the physical paper, or a doctor's supporting note.
class PrescriptionImage {
  final int id;
  final String url;
  const PrescriptionImage({required this.id, required this.url});

  factory PrescriptionImage.fromJson(Map<String, dynamic> json) => PrescriptionImage(
    id: json['id'] as int,
    url: Env.assetUrl(json['image'] as String?) ?? '',
  );
}

/// One of the prescription's parties (doctor/patient/pharmacy/a shared-in
/// doctor) — the backend only ever sends {id, name}.
class PrescriptionParty {
  final int id;
  final String? name;
  const PrescriptionParty({required this.id, this.name});

  factory PrescriptionParty.fromJson(Map<String, dynamic> json) =>
      PrescriptionParty(id: json['id'] as int, name: json['name'] as String?);
}

/// One drug line. Written by the doctor at issue time — read-only here.
class PrescriptionItem {
  final int id;
  final String? name;
  final String? dosage;
  final String? quantity;
  final String? instructions;
  final int? frequencyPerDay;
  final String? foodTiming;
  final List<String> timeSlots;
  final int? durationDays;
  final int? durationValue;
  final String? durationUnit;
  final double? unitPrice;
  final String? billedQuantity;
  final double? lineTotal;

  const PrescriptionItem({
    required this.id,
    this.name,
    this.dosage,
    this.quantity,
    this.instructions,
    this.frequencyPerDay,
    this.foodTiming,
    this.timeSlots = const [],
    this.durationDays,
    this.durationValue,
    this.durationUnit,
    this.unitPrice,
    this.billedQuantity,
    this.lineTotal,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) => PrescriptionItem(
    id: json['id'] as int,
    name: json['name'] as String?,
    dosage: json['dosage'] as String?,
    quantity: json['quantity'] as String?,
    instructions: json['instructions'] as String?,
    frequencyPerDay: (json['frequency_per_day'] as num?)?.toInt(),
    foodTiming: json['food_timing'] as String?,
    timeSlots: (json['time_slots'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    durationDays: (json['duration_days'] as num?)?.toInt(),
    durationValue: (json['duration_value'] as num?)?.toInt(),
    durationUnit: json['duration_unit'] as String?,
    unitPrice: (json['unit_price'] as num?)?.toDouble(),
    billedQuantity: json['billed_quantity'] as String?,
    lineTotal: (json['line_total'] as num?)?.toDouble(),
  );
}

/// Mirrors `PrescriptionController::serialize()`.
class Prescription {
  final int id;
  final String status;
  final int? appointmentId;
  final int? revisesPrescriptionId;
  final bool superseded;
  final String? fulfillmentType;
  final String? diagnosis;
  final String? patientCondition;
  final String? notes;
  final String? deliveryAddress;
  final int? deliveryAddressId;
  final double? medicineTotal;
  final DateTime? pricedAt;
  final List<PrescriptionImage> images;
  final PrescriptionParty doctor;
  final PrescriptionParty patient;
  final PrescriptionParty? pharmacy;
  final List<PrescriptionParty> sharedWith;
  final List<PrescriptionItem> items;
  final DateTime? issuedAt;
  final DateTime? dispensedAt;

  const Prescription({
    required this.id,
    required this.status,
    this.appointmentId,
    this.revisesPrescriptionId,
    this.superseded = false,
    this.fulfillmentType,
    this.diagnosis,
    this.patientCondition,
    this.notes,
    this.deliveryAddress,
    this.deliveryAddressId,
    this.medicineTotal,
    this.pricedAt,
    this.images = const [],
    required this.doctor,
    required this.patient,
    this.pharmacy,
    this.sharedWith = const [],
    this.items = const [],
    this.issuedAt,
    this.dispensedAt,
  });

  bool get canSend => status == 'issued';
  bool get canCancel => status != 'dispensed' && status != 'cancelled';

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    id: json['id'] as int,
    status: json['status'] as String? ?? 'issued',
    appointmentId: (json['appointment_id'] as num?)?.toInt(),
    revisesPrescriptionId: (json['revises_prescription_id'] as num?)?.toInt(),
    superseded: json['superseded'] as bool? ?? false,
    fulfillmentType: json['fulfillment_type'] as String?,
    diagnosis: json['diagnosis'] as String?,
    patientCondition: json['patient_condition'] as String?,
    notes: json['notes'] as String?,
    deliveryAddress: json['delivery_address'] as String?,
    deliveryAddressId: (json['delivery_address_id'] as num?)?.toInt(),
    medicineTotal: (json['medicine_total'] as num?)?.toDouble(),
    pricedAt: json['priced_at'] != null ? DateTime.tryParse(json['priced_at'] as String) : null,
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => PrescriptionImage.fromJson(e as Map<String, dynamic>))
        .toList(),
    doctor: PrescriptionParty.fromJson(json['doctor'] as Map<String, dynamic>),
    patient: PrescriptionParty.fromJson(json['patient'] as Map<String, dynamic>),
    pharmacy: json['pharmacy'] != null
        ? PrescriptionParty.fromJson(json['pharmacy'] as Map<String, dynamic>)
        : null,
    sharedWith: (json['shared_with'] as List<dynamic>? ?? [])
        .map((e) => PrescriptionParty.fromJson(e as Map<String, dynamic>))
        .toList(),
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => PrescriptionItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    issuedAt: json['issued_at'] != null ? DateTime.tryParse(json['issued_at'] as String) : null,
    dispensedAt: json['dispensed_at'] != null ? DateTime.tryParse(json['dispensed_at'] as String) : null,
  );
}
