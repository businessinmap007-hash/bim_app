import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/notifications/local_reminders.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../settings/application/locale_controller.dart';
import '../data/agenda_api.dart';
import '../data/agenda_local_store.dart';
import '../data/models/agenda_item.dart';
import '../data/models/agenda_settings.dart';
import 'agenda_reminders.dart';
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

/// «الإشعارات المحلية للتذكيرات» — the phone's own notifications (Android and iOS; nothing elsewhere).
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => DeviceReminderScheduler(),
);

const _remindersKey = 'bim_agenda_local_reminders';

/// Whether this phone shows the agenda's reminders itself (on by default — a phone-only setting, never on the server).
class AgendaLocalRemindersController extends StateNotifier<bool> {
  AgendaLocalRemindersController() : super(true) {
    _load();
  }

  Future<void> _load() async {
    try {
      state =
          (await SharedPreferences.getInstance()).getBool(_remindersKey) ??
          true;
    } catch (_) {
      // the default stands
    }
  }

  Future<void> set(bool value) async {
    state = value;
    try {
      await (await SharedPreferences.getInstance()).setBool(
        _remindersKey,
        value,
      );
    } catch (_) {
      // in-memory only
    }
  }
}

final agendaLocalRemindersProvider =
    StateNotifierProvider<AgendaLocalRemindersController, bool>(
      (ref) => AgendaLocalRemindersController(),
    );

final agendaRemindersProvider = Provider<AgendaReminders>((ref) {
  return AgendaReminders(
    api: ref.watch(agendaApiProvider),
    private: ref.watch(privateAgendaProvider),
    scheduler: ref.watch(reminderSchedulerProvider),
    // read at the moment of syncing, so the switch takes effect at once
    enabled: () async {
      // let a just-created controller finish reading its stored value
      await Future<void>.delayed(Duration.zero);
      return ref.read(agendaLocalRemindersProvider);
    },
    bodyFor: (at) {
      final locale = ref.read(localeControllerProvider);
      return lookupAppLocalizations(
        locale,
      ).agendaReminderBody(DateFormat.Hm(locale.languageCode).format(at));
    },
  );
});

/// Keeps the phone's reminders in step with the account: scheduled when someone signs in, dropped when they sign out
/// (another account must not get this one's notifications). Watched once, from the app's root.
final agendaRemindersAutoSyncProvider = Provider<void>((ref) {
  final auth = ref.watch(authControllerProvider);
  final reminders = ref.read(agendaRemindersProvider);
  final scheduler = ref.read(reminderSchedulerProvider);
  Future.microtask(() async {
    try {
      if (auth is AuthSignedIn) {
        await reminders.sync();
      } else {
        await scheduler.replaceAll(const []);
      }
    } catch (_) {
      // reminders are a convenience: never a crash
    }
  });
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

  /// Brings the phone's own reminders up to date after a task is added or removed.
  final Future<void> Function()? _resync;

  AgendaDayController(
    this._api,
    this._private,
    this.date, {
    Future<void> Function()? resync,
  }) : _resync = resync,
       super(const AgendaDayState()) {
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
    await _resync?.call();
  }

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((i) => i.id != id).toList());
    try {
      await _api.delete(id);
      await _private.forget(id);
      await _resync?.call();
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
          resync: () => ref.read(agendaRemindersProvider).sync(),
        );
      },
    );
