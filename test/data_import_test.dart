import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking_settings/data/models/booking_settings_models.dart' show NamedOption;
import 'package:bim_app/features/data_import/data/import_core.dart';
import 'package:bim_app/features/data_import/data/units_import.dart';
import 'package:bim_app/features/medical_file/data/medical_file.dart';
import 'package:bim_app/features/patient_records/application/patient_records_providers.dart';
import 'package:bim_app/features/patient_records/data/patient_import.dart';
import 'package:bim_app/features/patient_records/data/patient_backup.dart';
import 'package:bim_app/features/patient_records/data/patient_record.dart';
import 'package:bim_app/features/patient_records/data/patient_record_store.dart';

/// «أداة استيراد شاملة» + «بيانات المرضى على جهاز العيادة» — المالك، 2026-10-10.
class _MemoryStore extends PatientRecordStore {
  final Map<String, PatientRecord> rows = {};
  _MemoryStore() : super(const FlutterSecureStorage());

  DateTime? backedUpAt;

  @override
  Future<DateTime?> readBackupAt(int userId) async => backedUpAt;

  @override
  Future<void> writeBackupAt(int userId, DateTime at) async => backedUpAt = at;

  @override
  Future<List<PatientRecord>> all(int userId) async => rows.values.toList();

  @override
  Future<void> put(int userId, PatientRecord record) async => rows[record.id] = record;

  @override
  Future<void> putAll(int userId, Iterable<PatientRecord> records) async {
    for (final r in records) {
      rows[r.id] = r;
    }
  }

  @override
  Future<void> delete(int userId, String id) async => rows.remove(id);
}

void main() {
  group('reading a file', () {
    test('a CSV with quotes, a doubled quote, a line break in a cell, a BOM and a semicolon delimiter', () {
      final rows = parseCsv('﻿الاسم;الهاتف;ملاحظات\r\n"أحمد ""الكبير""";0100;"سطر 1\nسطر 2"\r\nمنى;0111;\r\n');

      expect(rows, [
        ['الاسم', 'الهاتف', 'ملاحظات'],
        ['أحمد "الكبير"', '0100', 'سطر 1\nسطر 2'],
        ['منى', '0111', ''],
      ]);
    });

    test('dates as a sheet writes them', () {
      expect(parseSheetDate('2026-03-02'), DateTime(2026, 3, 2));
      expect(parseSheetDate('2/3/2026'), DateTime(2026, 3, 2), reason: 'Egypt writes the day first');
      expect(parseSheetDate('15-07-24'), DateTime(2024, 7, 15));
      expect(parseSheetDate('45000'), DateTime(2023, 3, 15), reason: 'an Excel serial number');
      expect(parseSheetDate('2026-03-02 00:00:00.000'), DateTime(2026, 3, 2));
      expect(parseSheetDate('تحليل'), isNull);
    });
  });

  group('linking the columns', () {
    test('headers in Arabic and English find our fields, each file column used once', () {
      final mapping = suggestMapping(
        ['م', 'الاسم', 'الموبايل', 'تاريخ الكشف', 'التشخيص', 'الروشتة', 'Tests'],
        patientImportFields,
      );

      expect(mapping['name'], 1);
      expect(mapping['phone'], 2);
      expect(mapping['visit_date'], 3);
      expect(mapping['diagnosis'], 4);
      expect(mapping['medicines'], 5);
      expect(mapping['tests'], 6);
      expect(mapping['radiology'], isNull);
      expect(mapping.values.whereType<int>().toSet().length, mapping.values.whereType<int>().length);
    });
  });

  group('patient files', () {
    test('a phone is the same however it is written, a name without hamza and diacritics too', () {
      expect(PatientRecord.phoneKey('+20 100 123 4567'), '01001234567');
      expect(PatientRecord.phoneKey('0020-100-123-4567'), '01001234567');
      expect(PatientRecord.phoneKey('1001234567'), '01001234567');
      expect(PatientRecord.phoneKey('12'), '');
      expect(PatientRecord.nameKey('أَحمد  عَلي'), PatientRecord.nameKey('احمد علي'));
    });

    test('rows of one patient become ONE file with its visits, and a row without a name is reported', () {
      final grid = [
        ['الاسم', 'الهاتف', 'تاريخ الكشف', 'التشخيص', 'الروشتة', 'التحاليل', 'الأشعة'],
        ['منى علي', '0100 111 2222', '2/3/2026', 'التهاب لوزتين', 'مضاد حيوي', 'صورة دم', ''],
        ['', '0111', '', '', '', '', ''],
        ['منى علي', '+20 100 111 2222', '10/4/2026', 'متابعة', '', '', 'أشعة على الصدر'],
        ['كريم', '', '', '', '', '', ''],
      ];
      final result = recordsFromGrid(grid, suggestMapping(grid.first, patientImportFields));

      expect(result.records, hasLength(2));
      expect(result.skipped.single.row, 3);

      final mona = result.records.firstWhere((r) => r.name == 'منى علي');
      expect(mona.entries.map((e) => e.kind), containsAll([RecordKind.visit, RecordKind.medicine, RecordKind.test, RecordKind.radiology]));
      expect(mona.entries.where((e) => e.kind == RecordKind.visit), hasLength(2));
      expect(mona.entriesNewestFirst.first.title, 'متابعة');
    });

    test('importing twice never doubles a visit, and a file already there is added to, not replaced', () async {
      final store = _MemoryStore();
      final controller = PatientRecordsController(store, 1);
      await Future<void>.delayed(Duration.zero);

      final grid = [
        ['الاسم', 'الهاتف', 'التاريخ', 'التشخيص'],
        ['سامي', '01000000001', '1/1/2026', 'ضغط'],
      ];
      final records = recordsFromGrid(grid, suggestMapping(grid.first, patientImportFields)).records;

      final first = await controller.importRecords(records);
      expect((first.created, first.merged), (1, 0));

      final second = await controller.importRecords(records);
      expect((second.created, second.merged), (0, 1));
      expect(store.rows.values.single.entries, hasLength(1));

      // the clinic finds him by the phone however the front desk writes it
      expect(controller.match(phone: '+20 100 000 0001')?.name, 'سامي');
      expect(controller.match(name: 'سامى')?.name, 'سامي', reason: 'ى and ي are the same letter to a clerk');
      expect(controller.match(phone: '0123456789', name: 'غيره'), isNull);
    });
  });

  group('the encrypted backup of the clinic files', () {
    final records = [
      PatientRecord(
        id: 'a',
        name: 'منى علي',
        phone: '01001112222',
        entries: [RecordEntry(id: 'e1', date: DateTime(2026, 3, 2), kind: RecordKind.test, title: 'صورة دم', detail: 'طبيعي')],
        updatedAt: DateTime(2026, 4, 1),
      ),
      PatientRecord(id: 'b', name: 'سامي', updatedAt: DateTime(2026, 4, 2)),
    ];

    test('it seals to noise, opens only with the passphrase, and says nothing readable', () async {
      final blob = await PatientBackupCrypto.seal(records, 'a long passphrase');

      expect(blob, isNot(contains('منى')));
      expect(blob, isNot(contains('01001112222')));
      expect(blob, contains('"kind":"clinic_files"'));

      final back = await PatientBackupCrypto.open(blob, 'a long passphrase');
      expect(back.map((r) => r.name), ['منى علي', 'سامي']);
      expect(back.first.entries.single.title, 'صورة دم');

      await expectLater(PatientBackupCrypto.open(blob, 'another passphrase'), throwsA(anything));
    });

    test('a blob that is not a clinic-files backup is refused', () async {
      await expectLater(PatientBackupCrypto.open('{"v":1,"kind":"medical_file","salt":"AA==","data":"AA==","iterations":1}', 'x'), throwsA(anything));
    });

    test('restoring adds what is missing and keeps what was written after the backup', () async {
      final store = _MemoryStore();
      final controller = PatientRecordsController(store, 1);
      await Future<void>.delayed(Duration.zero);

      // the device already has «a», edited AFTER the backup was made, and nothing else
      final newer = records.first.copyWith(notes: 'كُتبت بعد النسخة');
      await controller.save(newer);

      final outcome = await controller.restore(records);

      expect((outcome.added, outcome.updated), (1, 0), reason: 'only the missing one comes back');
      expect(store.rows['a']!.notes, 'كُتبت بعد النسخة');
      expect(store.rows.keys, containsAll(['a', 'b']));

      await controller.markBackedUp(DateTime.now());
      expect(controller.changedSinceBackup, 0);
    });
  });

  group('the copy a patient keeps', () {
    test('merging a clinic copy into the patient file adds what is new and never repeats or overwrites', () {
      const mine = MedicalFile(
        bloodType: 'A+',
        sections: {
          MedicalSection.conditions: [MedicalEntry(title: 'سكر')],
        },
        notes: 'ملاحظتي',
      );
      const clinic = MedicalFile(
        bloodType: 'B+',
        sections: {
          MedicalSection.conditions: [MedicalEntry(title: 'سكر'), MedicalEntry(title: 'ضغط')],
          MedicalSection.records: [MedicalEntry(title: '2026-03-02 · تحليل: صورة دم', detail: 'طبيعي')],
        },
        notes: 'ملاحظة العيادة',
      );

      final merged = mine.mergedWith(clinic).mergedWith(clinic);

      expect(merged.bloodType, 'A+');
      expect(merged.notes, 'ملاحظتي');
      expect(merged.entries(MedicalSection.conditions).map((e) => e.title), ['سكر', 'ضغط']);
      expect(merged.entries(MedicalSection.records), hasLength(1));
    });
  });

  group('a hotel sheet of rooms', () {
    final grid = [
      ['رقم الغرفة', 'نوع الغرفة', 'السعة', 'العدد', 'الوصف'],
      ['101', 'غرفة مزدوجة', '٢', '1', 'إطلالة على البحر'],
      ['102', 'جناح', '4', '', ''],
      ['101', 'جناح', '2', '', ''],
      ['', 'جناح', '2', '', ''],
      ['١٠٣', 'غير معروف', 'x', '3.0', ''],
    ];

    test('numbers, capacity in Arabic digits, a repeated number and a row without one', () {
      final mapping = suggestMapping(grid.first, unitImportFields);
      final result = unitsFromGrid(grid, mapping);

      expect(result.units.map((u) => u.code), ['101', '102', '١٠٣']);
      expect(result.units.first.capacity, 2);
      expect(result.units.first.description, 'إطلالة على البحر');
      expect(result.units.last.quantity, 3);
      expect(result.units.last.capacity, isNull);
      expect(result.skipped.map((s) => s.row), [4, 5]);
    });

    test('a kind is matched by name to the merchants own, ignoring hamza and diacritics', () {
      const kinds = [NamedOption(id: 1, name: 'غرفة مزدوجة'), NamedOption(id: 2, name: 'جناح'), NamedOption(id: 3, name: 'غرفة فردية')];

      expect(matchKind('غرفه مزدوجه', kinds)?.id, 1);
      expect(matchKind('جناح ملكي', kinds)?.id, 2);
      expect(matchKind('غير معروف', kinds), isNull);
      expect(matchKind('', kinds), isNull);
      expect(parseWholeNumber('٣'), 3);
      expect(parseWholeNumber('4.0'), 4);
      expect(parseWholeNumber('4.5'), isNull);
    });
  });
}
