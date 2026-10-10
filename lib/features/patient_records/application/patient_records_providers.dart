import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/patient_record.dart';
import '../data/patient_record_store.dart';

final patientRecordStoreProvider = Provider<PatientRecordStore>((ref) => PatientRecordStore(ref.watch(secureStorageProvider)));

/// The signed-in clinic's patient files, on this device only. Every change is saved at once.
class PatientRecordsController extends StateNotifier<AsyncValue<List<PatientRecord>>> {
  final PatientRecordStore _store;
  final int? _userId;

  PatientRecordsController(this._store, this._userId) : super(const AsyncValue.loading()) {
    _load();
  }

  /// When the last backup was made or restored on this device; null = never.
  DateTime? backupAt;

  Future<void> _load() async {
    final id = _userId;
    if (id == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      backupAt = await _store.readBackupAt(id);
      state = AsyncValue.data(await _store.all(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<PatientRecord> get _records => state.valueOrNull ?? const [];

  /// The file of this patient: by phone when there is one, otherwise by name. Null when the clinic has none.
  PatientRecord? match({String phone = '', String name = ''}) {
    final key = PatientRecord.phoneKey(phone);
    if (key.isNotEmpty) {
      for (final r in _records) {
        if (r.phoneNormalized == key) return r;
      }
    }
    final nk = PatientRecord.nameKey(name);
    if (nk.isNotEmpty) {
      for (final r in _records) {
        if (r.nameNormalized == nk) return r;
      }
    }

    return null;
  }

  Future<void> markBackedUp(DateTime at) async {
    backupAt = at;
    final id = _userId;
    if (id != null) await _store.writeBackupAt(id, at);
    state = AsyncValue.data(_records);
  }

  /// How many files changed after the last backup (all of them when there was none).
  int get changedSinceBackup {
    final at = backupAt;
    if (at == null) return _records.length;

    return _records.where((r) => r.updatedAt.isAfter(at)).length;
  }

  /// A backup read back: a file this device does not have is added; one it has is replaced only by the NEWER copy — so
  /// restoring never throws away what was written after the backup.
  Future<({int added, int updated})> restore(List<PatientRecord> backup) async {
    final id = _userId;
    if (id == null) return (added: 0, updated: 0);

    final have = {for (final r in _records) r.id: r};
    final write = <PatientRecord>[];
    var added = 0;
    var updated = 0;
    for (final b in backup) {
      final mine = have[b.id];
      if (mine == null) {
        write.add(b);
        added++;
      } else if (b.updatedAt.isAfter(mine.updatedAt)) {
        write.add(b);
        updated++;
      }
    }

    await _store.putAll(id, write);
    state = AsyncValue.data(await _store.all(id));

    return (added: added, updated: updated);
  }

  /// A hand-made file or an edited one.
  Future<void> save(PatientRecord record) async {
    final id = _userId;
    if (id == null) return;
    await _store.put(id, record);
    final list = [..._records];
    final i = list.indexWhere((r) => r.id == record.id);
    if (i >= 0) {
      list[i] = record;
    } else {
      list.add(record);
    }
    list.sort((a, b) => PatientRecord.nameKey(a.name).compareTo(PatientRecord.nameKey(b.name)));
    state = AsyncValue.data(list);
  }

  Future<void> remove(String recordId) async {
    final id = _userId;
    if (id == null) return;
    await _store.delete(id, recordId);
    state = AsyncValue.data([..._records.where((r) => r.id != recordId)]);
  }

  /// What an import brings: a file whose phone (or, with no phone, name) the clinic already holds is merged into it —
  /// nothing written is overwritten, new entries are added — otherwise a new file is made.
  Future<({int created, int merged})> importRecords(List<PatientRecord> incoming) async {
    final id = _userId;
    if (id == null) return (created: 0, merged: 0);

    final byPhone = <String, PatientRecord>{};
    final byName = <String, PatientRecord>{};
    for (final r in _records) {
      if (r.phoneNormalized.isNotEmpty) byPhone[r.phoneNormalized] = r;
      byName[r.nameNormalized] = r;
    }

    final touched = <String, PatientRecord>{};
    var created = 0;
    var merged = 0;

    for (final inc in incoming) {
      final phone = inc.phoneNormalized;
      final existing = (phone.isNotEmpty ? byPhone[phone] : null) ?? (phone.isEmpty ? byName[inc.nameNormalized] : null);

      if (existing != null) {
        final next = touched[existing.id] ?? existing;
        final m = next.mergedWith(inc);
        touched[existing.id] = m;
        byName[m.nameNormalized] = m;
        if (m.phoneNormalized.isNotEmpty) byPhone[m.phoneNormalized] = m;
        merged++;
      } else {
        final fresh = PatientRecord(
          id: newRecordId(),
          name: inc.name,
          phone: inc.phone,
          nationalId: inc.nationalId,
          birthDate: inc.birthDate,
          gender: inc.gender,
          chronic: inc.chronic,
          allergies: inc.allergies,
          notes: inc.notes,
          entries: inc.entries,
          updatedAt: DateTime.now(),
        );
        touched[fresh.id] = fresh;
        byName[fresh.nameNormalized] = fresh;
        if (fresh.phoneNormalized.isNotEmpty) byPhone[fresh.phoneNormalized] = fresh;
        created++;
      }
    }

    await _store.putAll(id, touched.values);
    state = AsyncValue.data(await _store.all(id));

    return (created: created, merged: merged);
  }
}

final patientRecordsProvider = StateNotifierProvider.autoDispose<PatientRecordsController, AsyncValue<List<PatientRecord>>>((ref) {
  final auth = ref.watch(authControllerProvider);
  return PatientRecordsController(ref.watch(patientRecordStoreProvider), auth is AuthSignedIn ? auth.user.id : null);
});

/// A random 128-bit id for a file or an entry — nothing about the patient in it.
String newRecordId() {
  final r = Random.secure();
  return [for (var i = 0; i < 16; i++) r.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
}
