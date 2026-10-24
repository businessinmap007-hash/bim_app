import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// «أنا مصري/مقيم أم أجنبي»: what this guest said about themselves, kept on the phone. It narrows the room lists to the rooms sold to
/// them and pre-ticks the declaration when they book one. `local`, `foreign`, or null while they have not said.
class GuestOriginNotifier extends StateNotifier<String?> {
  static const _key = 'guest_origin';

  GuestOriginNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    try {
      final v = (await SharedPreferences.getInstance()).getString(_key);
      if (v == 'local' || v == 'foreign') state = v;
    } catch (_) {
      // no storage: it simply starts unset
    }
  }

  Future<void> set(String? origin) async {
    state = origin;
    try {
      final prefs = await SharedPreferences.getInstance();
      origin == null ? await prefs.remove(_key) : await prefs.setString(_key, origin);
    } catch (_) {
      // kept in memory for this session
    }
  }
}

final guestOriginProvider = StateNotifierProvider<GuestOriginNotifier, String?>((ref) => GuestOriginNotifier());
