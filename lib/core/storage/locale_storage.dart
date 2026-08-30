import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's chosen app language across launches. Not secure data
/// (unlike the auth token), so shared_preferences is the right store.
class LocaleStorage {
  static const _key = 'bim_locale_code';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> write(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }
}
