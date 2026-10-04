import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'medical_file.dart';

/// The medical file on THIS phone: kept in the platform's secure storage (Android Keystore / iOS Keychain —
/// encrypted by the system with a key the phone itself guards), one per account that signs in here. Nothing
/// of it is ever sent anywhere except, encrypted, when the patient shares part of it.
class MedicalFileStore {
  final FlutterSecureStorage _storage;
  const MedicalFileStore(this._storage);

  String _key(int userId) => 'bim_medical_file_v1_$userId';

  Future<MedicalFile> read(int userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null || raw.isEmpty) return const MedicalFile();
    return MedicalFile.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<void> write(int userId, MedicalFile file) => _storage.write(key: _key(userId), value: jsonEncode(file.toJson()));
}
