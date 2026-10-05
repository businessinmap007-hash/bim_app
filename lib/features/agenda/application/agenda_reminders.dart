import '../../../core/notifications/local_reminders.dart';
import '../data/agenda_api.dart';
import '../data/models/agenda_item.dart';
import 'private_agenda.dart';

/// «الإشعارات المحلية للتذكيرات» — keeps the phone's own notifications in step with the coming agenda items that ask
/// to be reminded of (a personal task, a medicine dose, an instalment). The words come from [PrivateAgenda], so a
/// private task is announced by what the user wrote, which the server never held.
class AgendaReminders {
  /// A phone can hold only so many pending notifications (iOS: 64) — the nearest ones win.
  static const maxPending = 60;

  final AgendaApi _api;
  final PrivateAgenda _private;
  final ReminderScheduler _scheduler;
  final Future<bool> Function() _enabled;
  final String Function(DateTime at) _bodyFor;

  AgendaReminders({
    required AgendaApi api,
    required PrivateAgenda private,
    required ReminderScheduler scheduler,
    required Future<bool> Function() enabled,
    required String Function(DateTime at) bodyFor,
  }) : _api = api,
       _private = private,
       _scheduler = scheduler,
       _enabled = enabled,
       _bodyFor = bodyFor;

  /// Reads what is coming and schedules it. Never throws: a reminder that could not be set is not worth a crash.
  Future<void> sync({DateTime? now}) async {
    try {
      if (!await _enabled()) {
        await _scheduler.replaceAll(const []);
        return;
      }
      final clock = now ?? DateTime.now();

      final items = await _private.show(await _api.upcoming());
      final lead = Duration(
        minutes: (await _api.reminderPreferences()).agendaLeadMinutes,
      );

      final plans = <ReminderPlan>[];
      for (final item in items) {
        final plan = _plan(item, lead, clock);
        if (plan != null) plans.add(plan);
      }
      plans.sort((a, b) => a.at.compareTo(b.at));
      final nearest = plans.take(maxPending).toList();

      if (nearest.isNotEmpty && !await _scheduler.ensurePermission()) return;
      await _scheduler.replaceAll(nearest);
    } catch (_) {
      // offline, or not signed in yet — the next sync tries again
    }
  }

  ReminderPlan? _plan(AgendaItem item, Duration lead, DateTime now) {
    final start = item.startsAt;
    if (start == null) return null;
    // Agenda times are the user's wall clock, written as a UTC-flagged ISO string: read the digits as local time.
    final at = DateTime(
      start.year,
      start.month,
      start.day,
      start.hour,
      start.minute,
    );
    if (!at.isAfter(now)) return null; // already started
    var fire = at.subtract(lead);
    // inside the lead window: remind now
    if (!fire.isAfter(now)) {
      fire = now.add(const Duration(seconds: 10));
    }
    return ReminderPlan(
      id: item.id,
      at: fire,
      title: item.title,
      body: _bodyFor(at),
    );
  }
}
