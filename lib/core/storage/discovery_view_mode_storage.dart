import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the list/grid choice on the discovery screens (activities, priced items) across restarts.
/// Nothing stored = grid, the default of every list/grid button.
class DiscoveryViewModeStorage {
  static const _key = 'bim_discovery_grid';

  Future<bool?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key);
  }

  Future<void> write(bool grid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, grid);
  }
}
