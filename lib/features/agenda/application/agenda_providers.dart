import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/agenda_api.dart';
import '../data/agenda_local_store.dart';
import '../data/models/agenda_item.dart';
import '../data/models/agenda_settings.dart';
import 'private_agenda.dart';

final agendaApiProvider = Provider<AgendaApi>((ref) {
  return AgendaApi(ref.watch(apiClientProvider));
});

final agendaLocalStoreProvider = Provider<AgendaLocalStore>(
  (ref) => AgendaLocalStore(ref.watch(secureStorageProvider)),
);

/// The words of the user's personal tasks, kept on this phone (the server keeps only the time).
final privateAgendaProvider = Provider<PrivateAgenda>((ref) {
  final auth = ref.watch(authControllerProvider);
  final api = ref.watch(agendaApiProvider);
  return PrivateAgenda(
    ref.watch(agendaLocalStoreProvider),
    auth is AuthSignedIn ? auth.user.id : null,
    scrub: api.scrub,
  );
});

/// The week containing the given (date-only) day.
final agendaWeekProvider = FutureProvider.autoDispose
    .family<AgendaWeek, DateTime>((ref, date) async {
      final week = await ref.watch(agendaApiProvider).week(date);
      final private = ref.read(privateAgendaProvider);
      return AgendaWeek(
        from: week.from,
        to: week.to,
        days: [
          for (final d in week.days)
            AgendaWeekDay(date: d.date, items: await private.show(d.items)),
        ],
      );
    });

final agendaFeedUrlProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(agendaApiProvider).feedUrl();
});

final mealTimesProvider = FutureProvider.autoDispose<MealTimes>((ref) {
  return ref.watch(agendaApiProvider).mealTimes();
});

final reminderPreferencesProvider =
    FutureProvider.autoDispose<ReminderPreferences>((ref) {
      return ref.watch(agendaApiProvider).reminderPreferences();
    });

class AgendaDayState {
  final List<AgendaItem> items;
  final bool isLoading;
  final String? error;

  const AgendaDayState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  AgendaDayState copyWith({
    List<AgendaItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
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
  final PrivateAgenda _private;
  final DateTime date;

  AgendaDayController(this._api, this._private, this.date)
    : super(const AgendaDayState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _private.show(await _api.day(date));
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
    bool remind = false,
  }) async {
    // Only the time goes to the server; what the task says stays on this phone.
    final item = await _api.addTask(
      startsAt: startsAt,
      endsAt: endsAt,
      remind: remind,
    );
    await _private.remember([item.id], title, notes);
    await load();
  }

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((i) => i.id != id).toList());
    try {
      await _api.delete(id);
      await _private.forget(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
    }
  }
}

final agendaDayControllerProvider =
    StateNotifierProvider.family<AgendaDayController, AgendaDayState, DateTime>(
      (ref, date) {
        return AgendaDayController(
          ref.watch(agendaApiProvider),
          ref.watch(privateAgendaProvider),
          date,
        );
      },
    );
