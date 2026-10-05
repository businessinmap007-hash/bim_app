import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// What a personal task says — kept only on this phone.
class PrivateNote {
  final String title;
  final String? notes;
  const PrivateNote({required this.title, this.notes});

  Map<String, dynamic> toJson() => {
    't': title,
    if (notes != null && notes!.isNotEmpty) 'n': notes,
  };

  factory PrivateNote.fromJson(Map<String, dynamic> json) =>
      PrivateNote(title: '${json['t'] ?? ''}', notes: json['n'] as String?);
}

/// «الأجندا تُحفظ على الفون» — the title and notes of the user's personal tasks, in the phone's secure storage (one
/// map per account on this phone): server item id → what it says. The server keeps only the time.
class AgendaLocalStore {
  final FlutterSecureStorage _storage;
  const AgendaLocalStore(this._storage);

  String _key(int userId) => 'bim_agenda_private_v1_$userId';

  Future<Map<int, PrivateNote>> read(int userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final e in map.entries)
        int.parse(e.key): PrivateNote.fromJson(
          Map<String, dynamic>.from(e.value as Map),
        ),
    };
  }

  Future<void> write(int userId, Map<int, PrivateNote> all) => _storage.write(
    key: _key(userId),
    value: jsonEncode({
      for (final e in all.entries) '${e.key}': e.value.toJson(),
    }),
  );
}
