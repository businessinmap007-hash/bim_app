import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's manual light/dark/system choice — separate storage
/// from the token/locale stores since it's a distinct, unrelated setting.
class ThemeModeStorage {
  static const _key = 'bim_theme_mode';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> write(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}
