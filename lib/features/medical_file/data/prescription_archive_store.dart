import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// «روشتاتي المحفوظة على الهاتف» — the patient's prescriptions as the server sent them, kept in the phone's
/// secure storage (one archive per account on this phone). Read offline, shown at a pharmacy by QR, and part of
/// the encrypted backup. It only ever holds the patient's OWN prescriptions.
class PrescriptionArchiveStore {
  final FlutterSecureStorage _storage;
  const PrescriptionArchiveStore(this._storage);

  String _key(int userId) => 'bim_prescription_archive_v1_$userId';

  /// id → the JSON the server sent.
  Future<Map<int, Map<String, dynamic>>> read(int userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    return {for (final e in list) (e as Map<String, dynamic>)['id'] as int: Map<String, dynamic>.from(e)};
  }

  Future<void> write(int userId, Map<int, Map<String, dynamic>> all) =>
      _storage.write(key: _key(userId), value: jsonEncode(all.values.toList()));
}
