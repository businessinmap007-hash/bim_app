/// Mirrors `BodyCompositionReport::deltaFrom()` — this report's change from
/// the previous month, per measure; null where either side is unmeasured.
class BodyReportChange {
  final double? weightKg;
  final double? muscleMassKg;
  final double? fatPercent;
  final double? waterPercent;
  final double? boneMassKg;
  final double? visceralFat;

  const BodyReportChange({
    this.weightKg,
    this.muscleMassKg,
    this.fatPercent,
    this.waterPercent,
    this.boneMassKg,
    this.visceralFat,
  });

  factory BodyReportChange.fromJson(Map<String, dynamic> json) => BodyReportChange(
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    muscleMassKg: (json['muscle_mass_kg'] as num?)?.toDouble(),
    fatPercent: (json['fat_percent'] as num?)?.toDouble(),
    waterPercent: (json['water_percent'] as num?)?.toDouble(),
    boneMassKg: (json['bone_mass_kg'] as num?)?.toDouble(),
    visceralFat: (json['visceral_fat'] as num?)?.toDouble(),
  );
}

/// One monthly reading from `BodyCompositionController::clientIndex()`.
class BodyReport {
  final int id;
  final String? forMonth;
  final DateTime? measuredOn;
  final double? weightKg;
  final double? muscleMassKg;
  final double? fatPercent;
  final double? waterPercent;
  final double? boneMassKg;
  final double? visceralFat;
  final String? notes;
  final BodyReportChange change;

  const BodyReport({
    required this.id,
    this.forMonth,
    this.measuredOn,
    this.weightKg,
    this.muscleMassKg,
    this.fatPercent,
    this.waterPercent,
    this.boneMassKg,
    this.visceralFat,
    this.notes,
    required this.change,
  });

  factory BodyReport.fromJson(Map<String, dynamic> json) => BodyReport(
    id: json['id'] as int,
    forMonth: json['for_month'] as String?,
    measuredOn: json['measured_on'] != null ? DateTime.tryParse(json['measured_on'] as String) : null,
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    muscleMassKg: (json['muscle_mass_kg'] as num?)?.toDouble(),
    fatPercent: (json['fat_percent'] as num?)?.toDouble(),
    waterPercent: (json['water_percent'] as num?)?.toDouble(),
    boneMassKg: (json['bone_mass_kg'] as num?)?.toDouble(),
    visceralFat: (json['visceral_fat'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
    change: BodyReportChange.fromJson(json['change'] as Map<String, dynamic>? ?? const {}),
  );
}
