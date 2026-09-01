import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'watermark_settings.dart';

/// Persists the owner's watermark preferences as JSON — same pattern as the
/// other settings stores (one SharedPreferences key), just holding a small
/// object instead of a single string.
class WatermarkSettingsStorage {
  static const _key = 'bim_watermark_settings';

  Future<WatermarkSettings?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return WatermarkSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> write(WatermarkSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
