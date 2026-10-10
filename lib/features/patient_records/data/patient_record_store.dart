import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'patient_record.dart';

/// The clinic's patient files on THIS device: an AES-encrypted Hive box per signed-in account, the 256-bit key held in
/// the platform's secure storage (Android Keystore / iOS Keychain / Windows DPAPI). The server holds none of it, and
/// the file never leaves the device except when the doctor hands a patient a copy (see the share screen).
class PatientRecordStore {
  final FlutterSecureStorage _secure;
  PatientRecordStore(this._secure);

  static bool _initialised = false;
  Box<String>? _box;
  int? _boxFor;

  Future<Box<String>> _open(int userId) async {
    if (_box != null && _boxFor == userId && _box!.isOpen) return _box!;

    if (!_initialised) {
      await Hive.initFlutter('bim_clinic_files');
      _initialised = true;
    }

    final keyName = 'bim_patient_files_key_$userId';
    var encoded = await _secure.read(key: keyName);
    if (encoded == null) {
      encoded = base64UrlEncode(Hive.generateSecureKey());
      await _secure.write(key: keyName, value: encoded);
    }

    _box = await Hive.openBox<String>('patient_files_$userId', encryptionCipher: HiveAesCipher(base64Url.decode(encoded)));
    _boxFor = userId;

    return _box!;
  }

  Future<List<PatientRecord>> all(int userId) async {
    final box = await _open(userId);
    final out = <PatientRecord>[];
    for (final raw in box.values) {
      try {
        out.add(PatientRecord.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
      } catch (_) {
        // a damaged row is skipped, never allowed to hide the others
      }
    }
    out.sort((a, b) => PatientRecord.nameKey(a.name).compareTo(PatientRecord.nameKey(b.name)));

    return out;
  }

  Future<void> put(int userId, PatientRecord record) async {
    final box = await _open(userId);
    await box.put(record.id, jsonEncode(record.toJson()));
  }

  Future<void> putAll(int userId, Iterable<PatientRecord> records) async {
    final box = await _open(userId);
    await box.putAll({for (final r in records) r.id: jsonEncode(r.toJson())});
  }

  /// When this device last made (or restored) a backup — only a date, never the passphrase.
  Future<DateTime?> readBackupAt(int userId) async =>
      DateTime.tryParse(await _secure.read(key: 'bim_clinic_files_backup_at_$userId') ?? '');

  Future<void> writeBackupAt(int userId, DateTime at) =>
      _secure.write(key: 'bim_clinic_files_backup_at_$userId', value: at.toIso8601String());

  Future<void> delete(int userId, String id) async {
    final box = await _open(userId);
    await box.delete(id);
  }
}
