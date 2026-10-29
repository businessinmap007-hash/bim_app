import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/inventory/data/inventory_api.dart';

/// The desktop suite's own copy on THIS computer (owner, 2026-10-29: «كل البيانات تحفظ محليا»): what the server last
/// answered for every screen (`cache`), the writes waiting for a connection (`outbox`, replayed in order), and this
/// device's identity and office-network keys (`meta`). All three boxes are AES-encrypted with a key held in the
/// platform's secure storage (Windows DPAPI / macOS Keychain), so the files are unreadable outside the app.
class SuiteStore {
  final Box<String> cache;
  final Box<String> outbox;
  final Box<String> meta;

  SuiteStore._(this.cache, this.outbox, this.meta);

  static Future<SuiteStore> open(FlutterSecureStorage secure) async {
    await Hive.initFlutter('bim_suite');

    const keyName = 'bim_suite_store_key';
    var encoded = await secure.read(key: keyName);
    if (encoded == null) {
      encoded = base64UrlEncode(Hive.generateSecureKey());
      await secure.write(key: keyName, value: encoded);
    }
    final cipher = HiveAesCipher(base64Url.decode(encoded));

    return SuiteStore._(
      await Hive.openBox<String>('suite_cache', encryptionCipher: cipher),
      await Hive.openBox<String>('suite_outbox', encryptionCipher: cipher),
      await Hive.openBox<String>('suite_meta', encryptionCipher: cipher),
    );
  }

  /// This computer's permanent id — what the server and the main computer know it by.
  String get deviceUuid {
    final existing = meta.get('device_uuid');
    if (existing != null) return existing;
    final created = InventoryApi.newUuid();
    meta.put('device_uuid', created);
    return created;
  }

  static String cacheKey(int? businessId, String path, Map<String, dynamic>? query) {
    final q = (query == null || query.isEmpty) ? '' : '?${(query.keys.toList()..sort()).map((k) => '$k=${query[k]}').join('&')}';
    return '${businessId ?? 0}|$path$q';
  }

  void putCache(String key, dynamic data) => cache.put(key, jsonEncode(data));

  dynamic readCache(String key) {
    final raw = cache.get(key);
    return raw == null ? null : jsonDecode(raw);
  }

  // ── the outbox ──

  Future<void> enqueue(OutboxEntry entry) => outbox.put(entry.id, jsonEncode(entry.toJson()));

  List<OutboxEntry> pending() {
    final rows = outbox.values.map((raw) => OutboxEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>)).toList();
    rows.sort((a, b) => a.id.compareTo(b.id));
    return rows;
  }

  Future<void> remove(String id) => outbox.delete(id);

  /// Writes the server refused (a validation error after a long offline spell) — kept for the user to read, never lost.
  List<Map<String, dynamic>> rejected() {
    final raw = meta.get('rejected');
    return raw == null ? [] : (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> addRejected(OutboxEntry entry, String message) {
    final rows = rejected()..insert(0, {'path': entry.path, 'method': entry.method, 'message': message, 'at': DateTime.now().toIso8601String()});
    return meta.put('rejected', jsonEncode(rows.take(100).toList()));
  }

  Future<void> clearRejected() => meta.delete('rejected');
}

/// One write waiting for the server. It carries the token of the person who made it, so the server records HIM and
/// checks HIS permissions, whichever computer finally sends it.
class OutboxEntry {
  final String id; // sortable: microseconds since epoch + device suffix
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final String? token;
  final int? businessId;
  final String origin; // device uuid that made it

  const OutboxEntry({required this.id, required this.method, required this.path, this.body, this.token, this.businessId, required this.origin});

  static String nextId(String origin) => '${DateTime.now().microsecondsSinceEpoch.toString().padLeft(20, '0')}-${origin.substring(0, 8)}';

  Map<String, dynamic> toJson() => {'id': id, 'method': method, 'path': path, 'body': body, 'token': token, 'business_id': businessId, 'origin': origin};

  factory OutboxEntry.fromJson(Map<String, dynamic> j) => OutboxEntry(
        id: j['id'] as String,
        method: j['method'] as String,
        path: j['path'] as String,
        body: (j['body'] as Map?)?.cast<String, dynamic>(),
        token: j['token'] as String?,
        businessId: j['business_id'] as int?,
        origin: j['origin'] as String? ?? '',
      );
}
