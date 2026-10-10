/// «بيانات المرضى والتاريخ المرضي على جهاز العيادة وليست على السيرفر» — المالك، 2026-10-10.
///
/// A patient's file as the CLINIC keeps it: on the clinic's own device only (see [PatientRecordStore]); the server never
/// holds it. When a patient with a file walks in, the doctor opens it at once — history, tests, radiology, medicines —
/// and can hand the patient a copy for their own phone.
enum RecordKind { visit, test, radiology, medicine, note }

/// One line of a file: a visit and its diagnosis, a lab test, a scan, the medicines given, or a note — dated.
class RecordEntry {
  final String id;
  final DateTime? date;
  final RecordKind kind;
  final String title;
  final String detail;

  const RecordEntry({required this.id, this.date, required this.kind, required this.title, this.detail = ''});

  /// What makes two entries "the same line": the same kind, day, title and detail — so importing a file twice (or
  /// two sheets that both list a visit) never doubles it.
  String get fingerprint =>
      '${kind.name}|${date == null ? '' : date!.toIso8601String().substring(0, 10)}|${title.trim()}|${detail.trim()}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'k': kind.name,
    if (date != null) 'd': date!.toIso8601String().substring(0, 10),
    't': title,
    if (detail.isNotEmpty) 'x': detail,
  };

  factory RecordEntry.fromJson(Map<String, dynamic> json) => RecordEntry(
    id: '${json['id'] ?? ''}',
    date: DateTime.tryParse('${json['d'] ?? ''}'),
    kind: RecordKind.values.firstWhere((k) => k.name == json['k'], orElse: () => RecordKind.note),
    title: '${json['t'] ?? ''}',
    detail: '${json['x'] ?? ''}',
  );
}

class PatientRecord {
  final String id;
  final String name;
  final String phone;
  final String nationalId;
  final DateTime? birthDate;
  final String gender;
  final String chronic;
  final String allergies;
  final String notes;
  final List<RecordEntry> entries;
  final DateTime updatedAt;

  const PatientRecord({
    required this.id,
    required this.name,
    this.phone = '',
    this.nationalId = '',
    this.birthDate,
    this.gender = '',
    this.chronic = '',
    this.allergies = '',
    this.notes = '',
    this.entries = const [],
    required this.updatedAt,
  });

  /// Digits only, with Egypt's `+20`/`0020` and a missing leading 0 folded away — so «+20 100 123 4567» and
  /// «01001234567» are the same person. Empty when there is no usable number.
  static String phoneKey(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('0020')) d = d.substring(4);
    if (d.startsWith('20') && d.length == 12) d = d.substring(2);
    if (d.length == 10 && d.startsWith('1')) d = '0$d';

    return d.length >= 7 ? d : '';
  }

  String get phoneNormalized => phoneKey(phone);

  /// Names compared without diacritics, tatweel, hamza forms or doubled spaces — «أحمد» and «احمد» match.
  static String nameKey(String raw) => raw
      .replaceAll(RegExp(r'[ً-ْـ]'), '')
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String get nameNormalized => nameKey(name);

  /// Entries newest first; undated ones last.
  List<RecordEntry> get entriesNewestFirst {
    final list = [...entries];
    list.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    return list;
  }

  PatientRecord copyWith({
    String? name,
    String? phone,
    String? nationalId,
    DateTime? birthDate,
    String? gender,
    String? chronic,
    String? allergies,
    String? notes,
    List<RecordEntry>? entries,
  }) => PatientRecord(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    nationalId: nationalId ?? this.nationalId,
    birthDate: birthDate ?? this.birthDate,
    gender: gender ?? this.gender,
    chronic: chronic ?? this.chronic,
    allergies: allergies ?? this.allergies,
    notes: notes ?? this.notes,
    entries: entries ?? this.entries,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'v': 1,
    'id': id,
    'name': name,
    if (phone.isNotEmpty) 'phone': phone,
    if (nationalId.isNotEmpty) 'nid': nationalId,
    if (birthDate != null) 'birth': birthDate!.toIso8601String().substring(0, 10),
    if (gender.isNotEmpty) 'gender': gender,
    if (chronic.isNotEmpty) 'chronic': chronic,
    if (allergies.isNotEmpty) 'allergies': allergies,
    if (notes.isNotEmpty) 'notes': notes,
    'entries': [for (final e in entries) e.toJson()],
    'updated_at': updatedAt.toIso8601String(),
  };

  factory PatientRecord.fromJson(Map<String, dynamic> json) => PatientRecord(
    id: '${json['id'] ?? ''}',
    name: '${json['name'] ?? ''}',
    phone: '${json['phone'] ?? ''}',
    nationalId: '${json['nid'] ?? ''}',
    birthDate: DateTime.tryParse('${json['birth'] ?? ''}'),
    gender: '${json['gender'] ?? ''}',
    chronic: '${json['chronic'] ?? ''}',
    allergies: '${json['allergies'] ?? ''}',
    notes: '${json['notes'] ?? ''}',
    entries: [
      for (final e in json['entries'] as List<dynamic>? ?? const []) RecordEntry.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}') ?? DateTime.now(),
  );

  /// Merge what an import (or a re-import) knows into this file: fill what is empty, keep what is written, and add
  /// the entries it did not have.
  PatientRecord mergedWith(PatientRecord other) {
    String pick(String mine, String theirs) => mine.trim().isNotEmpty ? mine : theirs;
    final seen = {for (final e in entries) e.fingerprint};
    final added = [for (final e in other.entries) if (seen.add(e.fingerprint)) e];

    return PatientRecord(
      id: id,
      name: pick(name, other.name),
      phone: pick(phone, other.phone),
      nationalId: pick(nationalId, other.nationalId),
      birthDate: birthDate ?? other.birthDate,
      gender: pick(gender, other.gender),
      chronic: pick(chronic, other.chronic),
      allergies: pick(allergies, other.allergies),
      notes: pick(notes, other.notes),
      entries: [...entries, ...added],
      updatedAt: DateTime.now(),
    );
  }
}
