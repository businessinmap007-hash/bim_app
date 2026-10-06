import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/notification_preferences_api.dart';

final notificationPreferencesApiProvider = Provider<NotificationPreferencesApi>((ref) => NotificationPreferencesApi(ref.watch(apiClientProvider)));

/// The switches of «إعدادات الإشعارات». A flip shows at once and is saved; if the save fails it flips back.
class NotificationPreferencesController extends StateNotifier<AsyncValue<List<NotificationCategory>>> {
  final NotificationPreferencesApi _api;

  NotificationPreferencesController(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.load());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Returns false when the save failed (the switch is put back).
  Future<bool> set(String key, bool enabled) async {
    final before = state.valueOrNull;
    if (before == null) return false;
    state = AsyncValue.data([for (final c in before) c.key == key ? c.copyWith(enabled: enabled) : c]);
    try {
      state = AsyncValue.data(await _api.save({key: enabled}));
      return true;
    } catch (_) {
      state = AsyncValue.data(before);
      return false;
    }
  }
}

final notificationPreferencesControllerProvider =
    StateNotifierProvider.autoDispose<NotificationPreferencesController, AsyncValue<List<NotificationCategory>>>(
      (ref) => NotificationPreferencesController(ref.watch(notificationPreferencesApiProvider)),
    );
