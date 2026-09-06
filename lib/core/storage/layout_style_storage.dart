import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's chosen Categories-screen layout (see
/// `CategoriesLayoutStyle`) — separate storage from the token/locale/theme
/// stores since it's a distinct, unrelated setting.
class LayoutStyleStorage {
  static const _key = 'bim_categories_layout_style';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> write(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}
