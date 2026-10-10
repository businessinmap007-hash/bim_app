import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../medical_file/data/medical_backup_crypto.dart';
import 'patient_record.dart';

/// «النسخة الاحتياطية المشفرة لملفات المرضى» — المالك، 2026-10-11.
///
/// All the clinic's files are gzipped (text compresses five to ten times) and sealed with AES-256-GCM under a key made
/// from a passphrase only the clinic knows (PBKDF2-HMAC-SHA256, 310,000 rounds, a random salt per backup — the same
/// derivation as the patient's own backup). The passphrase is kept nowhere: forgetting it loses the backup, and the
/// server, which may hold the blob, can read nothing of it — not even how many patients there are.
class PatientBackupCrypto {
  static final _aes = AesGcm.with256bits();

  /// The blob to keep (as a file, or on the server): JSON `{v, kind, kdf, iterations, salt, data}`.
  static Future<String> seal(List<PatientRecord> records, String passphrase) async {
    final packed = await compute(_pack, [for (final r in records) r.toJson()]);
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final key = await MedicalBackupCrypto.derive(passphrase, salt, MedicalBackupCrypto.iterations);
    final box = await _aes.encrypt(packed, secretKey: key);

    return jsonEncode({
      'v': 1,
      'kind': 'clinic_files',
      'kdf': 'pbkdf2-sha256',
      'iterations': MedicalBackupCrypto.iterations,
      'salt': base64Encode(salt),
      'data': base64Encode(box.concatenation()),
    });
  }

  /// Throws when the passphrase is wrong, the blob was changed, or it is not a clinic-files backup.
  static Future<List<PatientRecord>> open(String blob, String passphrase) async {
    final json = jsonDecode(blob) as Map<String, dynamic>;
    if (json['kind'] != 'clinic_files') throw const FormatException('not a clinic-files backup');

    final key = await MedicalBackupCrypto.derive(passphrase, base64Decode('${json['salt']}'), (json['iterations'] as num).toInt());
    final box = SecretBox.fromConcatenation(base64Decode('${json['data']}'), nonceLength: 12, macLength: 16);
    final clear = await _aes.decrypt(box, secretKey: key);
    final list = await compute(_unpack, clear);

    return [for (final m in list) PatientRecord.fromJson(m)];
  }
}

/// JSON → gzip, off the UI isolate: thousands of files are megabytes of text.
List<int> _pack(List<Map<String, dynamic>> records) => gzip.encode(utf8.encode(jsonEncode({'v': 1, 'records': records})));

List<Map<String, dynamic>> _unpack(List<int> packed) {
  final content = jsonDecode(utf8.decode(gzip.decode(packed))) as Map<String, dynamic>;

  return [for (final r in content['records'] as List<dynamic>? ?? const []) Map<String, dynamic>.from(r as Map)];
}

/// The server's end of the optional copy: one opaque blob per account (see ClinicFilesBackupController).
class PatientBackupApi {
  final ApiClient _client;
  const PatientBackupApi(this._client);

  Future<DateTime> put(String blob) async {
    final data = await _client.put('/clinic-files-backup', data: {'blob': blob}) as Map<String, dynamic>;
    return DateTime.parse('${data['updated_at']}').toLocal();
  }

  /// null when the account never made a server backup.
  Future<({String blob, DateTime updatedAt, int bytes})?> get() async {
    try {
      final data = await _client.get('/clinic-files-backup') as Map<String, dynamic>;
      return (
        blob: '${data['blob']}',
        updatedAt: DateTime.parse('${data['updated_at']}').toLocal(),
        bytes: (data['bytes'] as num?)?.toInt() ?? 0,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> delete() => _client.delete('/clinic-files-backup');
}
