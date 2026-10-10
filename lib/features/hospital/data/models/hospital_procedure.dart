/// The three kinds of medical procedure a hospital offers, in the order a patient reads them.
const procedureKinds = ['surgery', 'endoscopy', 'procedure'];

/// A procedure a hospital offers, as a patient sees it. [id] is the offering a patient asks for; [price] null means
/// «السعر بعد التقييم».
class ProcedureOffering {
  final int id;
  final String name;
  final double? price;
  final String? notes;

  const ProcedureOffering({required this.id, required this.name, this.price, this.notes});

  factory ProcedureOffering.fromJson(Map<String, dynamic> json) => ProcedureOffering(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
  );
}

class ProcedureOfferingSection {
  final String kind;
  final List<ProcedureOffering> procedures;

  const ProcedureOfferingSection({required this.kind, this.procedures = const []});

  factory ProcedureOfferingSection.fromJson(Map<String, dynamic> json) => ProcedureOfferingSection(
    kind: json['kind'] as String? ?? 'procedure',
    procedures: (json['procedures'] as List<dynamic>? ?? [])
        .map((e) => ProcedureOffering.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// One row of the hospital's own catalogue: a platform procedure or the hospital's own, with what it offers now.
class ProcedureCatalogEntry {
  final int id;
  final String name;
  final bool own;
  final bool offered;
  final double? price;

  const ProcedureCatalogEntry({required this.id, required this.name, this.own = false, this.offered = false, this.price});

  factory ProcedureCatalogEntry.fromJson(Map<String, dynamic> json) => ProcedureCatalogEntry(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    own: json['own'] as bool? ?? false,
    offered: json['offered'] as bool? ?? false,
    price: (json['price'] as num?)?.toDouble(),
  );
}

class ProcedureCatalogSection {
  final String kind;
  final List<ProcedureCatalogEntry> entries;

  const ProcedureCatalogSection({required this.kind, this.entries = const []});

  factory ProcedureCatalogSection.fromJson(Map<String, dynamic> json) => ProcedureCatalogSection(
    kind: json['kind'] as String? ?? 'procedure',
    entries: (json['procedures'] as List<dynamic>? ?? [])
        .map((e) => ProcedureCatalogEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// A patient's request for a procedure — read by the patient and by the hospital.
class ProcedureRequestItem {
  static const requested = 'requested';
  static const accepted = 'accepted';
  static const completed = 'completed';
  static const declined = 'declined';
  static const cancelled = 'cancelled';

  final int id;
  final String status;
  final String kind;
  final String name;
  final double? price;
  final DateTime? preferredDate;
  final String? notes;
  final DateTime? scheduledAt;
  final String? hospitalNote;
  final String? hospitalName;
  final String? patientName;
  final String? patientPhone;

  const ProcedureRequestItem({
    required this.id,
    required this.status,
    required this.kind,
    required this.name,
    this.price,
    this.preferredDate,
    this.notes,
    this.scheduledAt,
    this.hospitalNote,
    this.hospitalName,
    this.patientName,
    this.patientPhone,
  });

  bool get canCancel => status == requested || status == accepted;

  factory ProcedureRequestItem.fromJson(Map<String, dynamic> json) {
    final hospital = json['hospital'] as Map<String, dynamic>?;
    final patient = json['patient'] as Map<String, dynamic>?;

    return ProcedureRequestItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? requested,
      kind: json['kind'] as String? ?? 'procedure',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      preferredDate: json['preferred_date'] != null ? DateTime.tryParse(json['preferred_date'] as String) : null,
      notes: json['notes'] as String?,
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'] as String) : null,
      hospitalNote: json['hospital_note'] as String?,
      hospitalName: hospital?['name'] as String?,
      patientName: patient?['name'] as String?,
      patientPhone: patient?['phone'] as String?,
    );
  }
}
