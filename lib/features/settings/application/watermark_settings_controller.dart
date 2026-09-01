import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/watermark_settings.dart';
import '../data/watermark_settings_storage.dart';

final watermarkSettingsStorageProvider = Provider<WatermarkSettingsStorage>((ref) {
  return WatermarkSettingsStorage();
});

/// The owner's saved watermark preferences — configured once in Settings,
/// not retyped for every photo. Mirrors [ThemeModeController]'s
/// restore-then-persist shape.
class WatermarkSettingsController extends StateNotifier<WatermarkSettings> {
  final Ref _ref;

  WatermarkSettingsController(this._ref) : super(const WatermarkSettings()) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _ref.read(watermarkSettingsStorageProvider).read();
      if (saved != null) state = saved;
    } catch (_) {
      // Keep the off-by-default state — storage being unavailable shouldn't crash launch.
    }
  }

  Future<void> _persist() async {
    try {
      await _ref.read(watermarkSettingsStorageProvider).write(state);
    } catch (_) {
      // Best-effort persistence; the in-memory switch already took effect.
    }
  }

  void setUseMobile(bool value) {
    state = state.copyWith(useMobile: value);
    _persist();
  }

  void setUseBusinessName(bool value) {
    state = state.copyWith(useBusinessName: value);
    _persist();
  }

  void setRepeatCount(int value) {
    state = state.copyWith(repeatCount: value);
    _persist();
  }
}

final watermarkSettingsControllerProvider =
    StateNotifierProvider<WatermarkSettingsController, WatermarkSettings>((ref) {
      return WatermarkSettingsController(ref);
    });

/// The literal text to stamp, built from the signed-in profile according to
/// the saved settings — null when disabled (nothing checked), signed out,
/// or the enabled fields are empty, meaning no watermark should be applied.
final watermarkTextProvider = Provider<String?>((ref) {
  final settings = ref.watch(watermarkSettingsControllerProvider);
  if (!settings.isEnabled) return null;

  final authState = ref.watch(authControllerProvider);
  if (authState is! AuthSignedIn) return null;

  final parts = <String>[
    if (settings.useMobile) authState.user.phone,
    if (settings.useBusinessName) authState.user.name,
  ]..removeWhere((part) => part.trim().isEmpty);

  if (parts.isEmpty) return null;
  return parts.join(' • ');
});
