import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';

/// Drives the app's [ThemeMode] — defaults to following the OS (system),
/// but the user can pin light or dark explicitly from Settings.
class ThemeModeController extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeController(this._ref) : super(ThemeMode.system) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _ref.read(themeModeStorageProvider).read();
      state = switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      // Keep the system default — storage being unavailable shouldn't crash launch.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _ref.read(themeModeStorageProvider).write(mode.name);
    } catch (_) {
      // Best-effort persistence; the in-memory switch already took effect.
    }
  }
}

final themeModeControllerProvider = StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref);
});
