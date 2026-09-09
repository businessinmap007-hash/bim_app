import 'package:shared_preferences/shared_preferences.dart';

/// Persists a CUSTOMER's own list/grid preference for browsing any
/// business's menu — once they pick one, every other business's menu opens
/// in that same mode instead of falling back to that merchant's own stored
/// `display_mode` default. Separate storage from the merchant-side setting,
/// which lives server-side per business.
class CustomerMenuDisplayModeStorage {
  static const _key = 'bim_customer_menu_display_mode';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> write(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}
