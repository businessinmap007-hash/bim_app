import '../../data_import/data/import_core.dart';
import '../application/patient_records_providers.dart' show newRecordId;
import 'patient_record.dart';

/// The columns a clinic's old patient sheet may have. One row is one patient — or one VISIT of a patient (several rows
/// with the same phone/name become one file with several entries), so a sheet written either way imports.
const patientImportFields = <ImportField>[
  ImportField(key: 'name', label: 'اسم المريض', required: true, aliases: ['الاسم', 'الاسم بالكامل', 'المريض', 'name', 'patient', 'patient name', 'full name']),
  ImportField(key: 'phone', label: 'رقم الهاتف', aliases: ['الهاتف', 'الموبايل', 'المحمول', 'تليفون', 'رقم الموبايل', 'phone', 'mobile', 'tel']),
  ImportField(key: 'national_id', label: 'الرقم القومي', aliases: ['رقم قومي', 'الرقم القومى', 'national id', 'nid', 'id number']),
  ImportField(key: 'birth_date', label: 'تاريخ الميلاد', aliases: ['الميلاد', 'تاريخ الميلاد', 'birth', 'birthdate', 'dob', 'date of birth']),
  ImportField(key: 'gender', label: 'النوع', aliases: ['الجنس', 'النوع', 'gender', 'sex']),
  ImportField(key: 'chronic', label: 'الأمراض المزمنة', aliases: ['امراض مزمنه', 'مزمن', 'chronic', 'chronic diseases', 'conditions']),
  ImportField(key: 'allergies', label: 'الحساسية', aliases: ['حساسيه', 'allergy', 'allergies']),
  ImportField(key: 'notes', label: 'ملاحظات', aliases: ['ملاحظه', 'notes', 'note', 'comments']),
  ImportField(key: 'visit_date', label: 'تاريخ الزيارة', aliases: ['تاريخ الكشف', 'التاريخ', 'تاريخ', 'visit date', 'date', 'visit']),
  ImportField(key: 'diagnosis', label: 'التشخيص', aliases: ['تشخيص', 'الشكوى', 'diagnosis', 'complaint']),
  ImportField(key: 'medicines', label: 'الأدوية', aliases: ['ادويه', 'الدواء', 'العلاج', 'الروشته', 'روشته', 'medicines', 'medication', 'medications', 'prescription', 'treatment']),
  ImportField(key: 'tests', label: 'التحاليل', aliases: ['تحاليل', 'التحليل', 'tests', 'lab', 'labs', 'lab tests']),
  ImportField(key: 'radiology', label: 'الأشعة', aliases: ['اشعه', 'الاشعه', 'radiology', 'xray', 'x-ray', 'imaging', 'scan']),
  ImportField(key: 'visit_notes', label: 'ملاحظات الزيارة', aliases: ['ملاحظات الكشف', 'visit notes', 'visit note']),
];

class PatientImportResult {
  final List<PatientRecord> records;

  /// 1-based sheet row numbers (header = 1) with the reason a row was left out.
  final List<({int row, String reason})> skipped;

  const PatientImportResult({required this.records, required this.skipped});
}

/// Turn a sheet (header row first) into patient files, reading the columns [mapping] points at (field key → 0-based
/// column index). The rows of one patient (same phone, or same name when there is no phone) are folded into one file.
PatientImportResult recordsFromGrid(List<List<String>> grid, Map<String, int?> mapping) {
  if (grid.length < 2) return const PatientImportResult(records: [], skipped: []);

  String cell(List<String> row, String key) {
    final i = mapping[key];
    if (i == null || i < 0 || i >= row.length) return '';
    return row[i].trim();
  }

  final byKey = <String, PatientRecord>{};
  final skipped = <({int row, String reason})>[];

  for (var r = 1; r < grid.length; r++) {
    final row = grid[r];
    final name = cell(row, 'name');
    if (name.isEmpty) {
      skipped.add((row: r + 1, reason: 'بلا اسم'));
      continue;
    }

    final phone = cell(row, 'phone');
    final visitDate = parseSheetDate(cell(row, 'visit_date'));
    final entries = <RecordEntry>[];

    void add(RecordKind kind, String title, {String detail = ''}) {
      if (title.isEmpty) return;
      entries.add(RecordEntry(id: newRecordId(), date: visitDate, kind: kind, title: title, detail: detail));
    }

    final diagnosis = cell(row, 'diagnosis');
    final visitNotes = cell(row, 'visit_notes');
    if (diagnosis.isNotEmpty) {
      add(RecordKind.visit, diagnosis, detail: visitNotes);
    } else if (visitNotes.isNotEmpty) {
      add(RecordKind.visit, visitNotes);
    }
    add(RecordKind.medicine, cell(row, 'medicines'));
    add(RecordKind.test, cell(row, 'tests'));
    add(RecordKind.radiology, cell(row, 'radiology'));

    final incoming = PatientRecord(
      id: newRecordId(),
      name: name,
      phone: phone,
      nationalId: cell(row, 'national_id'),
      birthDate: parseSheetDate(cell(row, 'birth_date')),
      gender: cell(row, 'gender'),
      chronic: cell(row, 'chronic'),
      allergies: cell(row, 'allergies'),
      notes: cell(row, 'notes'),
      entries: entries,
      updatedAt: DateTime.now(),
    );

    final key = incoming.phoneNormalized.isNotEmpty ? 'p:${incoming.phoneNormalized}' : 'n:${incoming.nameNormalized}';
    final existing = byKey[key];
    byKey[key] = existing == null ? incoming : existing.mergedWith(incoming);
  }

  return PatientImportResult(records: byKey.values.toList(), skipped: skipped);
}
