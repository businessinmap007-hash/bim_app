/// «الملف الطبي» — kept on the patient's phone only (see [MedicalFileStore]); the server never holds it.
/// «التاريخ المرضى يحفظ على الفون وعند مشاركته يقرأ ويعرض للطبيب او الصيدلى» — المالك، 2026-10-05.
enum MedicalSection { conditions, allergies, medications, surgeries }

/// One line of a section: «سكر من النوع الثاني — منذ 2019», «بنسلين — طفح جلدي».
class MedicalEntry {
  final String title;
  final String detail;

  const MedicalEntry({required this.title, this.detail = ''});

  Map<String, dynamic> toJson() => {'title': title, if (detail.isNotEmpty) 'detail': detail};

  factory MedicalEntry.fromJson(Map<String, dynamic> json) =>
      MedicalEntry(title: '${json['title'] ?? ''}', detail: '${json['detail'] ?? ''}');
}

class MedicalFile {
  /// «A+» … «O-», or empty when not known.
  final String bloodType;
  final Map<MedicalSection, List<MedicalEntry>> sections;
  final String notes;
  final DateTime? updatedAt;

  const MedicalFile({this.bloodType = '', this.sections = const {}, this.notes = '', this.updatedAt});

  static const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  List<MedicalEntry> entries(MedicalSection section) => sections[section] ?? const [];

  bool get isEmpty => bloodType.isEmpty && notes.trim().isEmpty && sections.values.every((l) => l.isEmpty);

  MedicalFile copyWith({String? bloodType, Map<MedicalSection, List<MedicalEntry>>? sections, String? notes}) => MedicalFile(
    bloodType: bloodType ?? this.bloodType,
    sections: sections ?? this.sections,
    notes: notes ?? this.notes,
    updatedAt: DateTime.now(),
  );

  MedicalFile withEntries(MedicalSection section, List<MedicalEntry> list) =>
      copyWith(sections: {...sections, section: List.unmodifiable(list)});

  Map<String, dynamic> toJson() => {
    'v': 1,
    if (bloodType.isNotEmpty) 'blood_type': bloodType,
    'sections': {
      for (final s in MedicalSection.values)
        if (entries(s).isNotEmpty) s.name: [for (final e in entries(s)) e.toJson()],
    },
    if (notes.trim().isNotEmpty) 'notes': notes,
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  factory MedicalFile.fromJson(Map<String, dynamic> json) {
    final raw = json['sections'] as Map<String, dynamic>? ?? const {};
    return MedicalFile(
      bloodType: '${json['blood_type'] ?? ''}',
      sections: {
        for (final s in MedicalSection.values)
          if (raw[s.name] is List)
            s: [for (final e in raw[s.name] as List) MedicalEntry.fromJson(Map<String, dynamic>.from(e as Map))],
      },
      notes: '${json['notes'] ?? ''}',
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }

  /// Only what the patient chose to show — the blood type and notes count as their own choices.
  MedicalFile only({required Set<MedicalSection> sections, required bool bloodType, required bool notes}) => MedicalFile(
    bloodType: bloodType ? this.bloodType : '',
    sections: {for (final s in sections) s: entries(s)},
    notes: notes ? this.notes : '',
    updatedAt: updatedAt,
  );
}
