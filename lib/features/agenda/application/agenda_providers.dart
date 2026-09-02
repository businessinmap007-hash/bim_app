import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/agenda_api.dart';
import '../data/models/agenda_item.dart';
import '../data/models/agenda_settings.dart';

final agendaApiProvider = Provider<AgendaApi>((ref) {
  return AgendaApi(ref.watch(apiClientProvider));
});

final mealTimesProvider = FutureProvider.autoDispose<MealTimes>((ref) {
  return ref.watch(agendaApiProvider).mealTimes();
});

final reminderPreferencesProvider = FutureProvider.autoDispose<ReminderPreferences>((ref) {
  return ref.watch(agendaApiProvider).reminderPreferences();
});

class AgendaDayState {
  final List<AgendaItem> items;
  final bool isLoading;
  final String? error;

  const AgendaDayState({this.items = const [], this.isLoading = false, this.error});

  AgendaDayState copyWith({List<AgendaItem>? items, bool? isLoading, String? error, bool clearError = false}) {
    return AgendaDayState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// One controller per calendar day (keyed by a normalized `DateTime` with no
/// time component) — switching days in the UI just watches a different
/// family instance, so each day's items stay cached as the user flips back
/// and forth instead of re-fetching every time.
class AgendaDayController extends StateNotifier<AgendaDayState> {
  final AgendaApi _api;
  final DateTime date;

  AgendaDayController(this._api, this.date) : super(const AgendaDayState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.day(date);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTask({
    required String title,
    required DateTime startsAt,
    DateTime? endsAt,
    String? notes,
  }) async {
    await _api.addTask(title: title, startsAt: startsAt, endsAt: endsAt, notes: notes);
    await load();
  }

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((i) => i.id != id).toList());
    try {
      await _api.delete(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
    }
  }
}

final agendaDayControllerProvider =
    StateNotifierProvider.family<AgendaDayController, AgendaDayState, DateTime>((ref, date) {
      return AgendaDayController(ref.watch(agendaApiProvider), date);
    });
