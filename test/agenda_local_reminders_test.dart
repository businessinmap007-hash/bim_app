import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/notifications/local_reminders.dart';
import 'package:bim_app/features/agenda/application/agenda_reminders.dart';
import 'package:bim_app/features/agenda/application/private_agenda.dart';
import 'package:bim_app/features/agenda/data/agenda_api.dart';
import 'package:bim_app/features/agenda/data/agenda_local_store.dart';
import 'package:bim_app/features/agenda/data/models/agenda_item.dart';
import 'package:bim_app/features/agenda/data/models/agenda_settings.dart';

/// «الإشعارات المحلية للتذكيرات» — the phone schedules its own notifications from the coming agenda items that ask to
/// be reminded of, with the words the user wrote.
class _FakeScheduler implements ReminderScheduler {
  bool allowed = true;
  int permissionAsks = 0;
  List<ReminderPlan>? scheduled;
  int replaceCalls = 0;

  @override
  Future<bool> ensurePermission() async {
    permissionAsks++;
    return allowed;
  }

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    replaceCalls++;
    scheduled = plans;
  }
}

class _FakeApi implements AgendaApi {
  List<AgendaItem> items;
  int lead;
  bool offline = false;
  _FakeApi(this.items, {this.lead = 0});

  @override
  Future<List<AgendaItem>> upcoming({int days = 14}) async {
    if (offline) throw Exception('offline');
    return items;
  }

  @override
  Future<ReminderPreferences> reminderPreferences() async =>
      ReminderPreferences(
        appointmentFirstLeadMinutes: 60,
        appointmentSecondLeadMinutes: null,
        agendaLeadMinutes: lead,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryStore implements AgendaLocalStore {
  Map<int, PrivateNote> saved = {};

  @override
  Future<Map<int, PrivateNote>> read(int userId) async => Map.of(saved);

  @override
  Future<void> write(int userId, Map<int, PrivateNote> all) async =>
      saved = Map.of(all);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Agenda times are the user's wall clock inside a UTC-flagged string.
AgendaItem _item(
  int id,
  DateTime wall, {
  String kind = 'personal',
  String title = 'مهمة شخصية',
  bool isPrivate = true,
}) => AgendaItem(
  id: id,
  kind: kind,
  title: title,
  startsAt: DateTime.utc(
    wall.year,
    wall.month,
    wall.day,
    wall.hour,
    wall.minute,
  ),
  blocking: kind == 'personal',
  isPrivate: isPrivate,
);

void main() {
  final now = DateTime(2026, 10, 10, 8, 0);

  AgendaReminders build(
    _FakeApi api,
    _FakeScheduler scheduler, {
    bool enabled = true,
    PrivateAgenda? private,
  }) => AgendaReminders(
    api: api,
    private: private ?? PrivateAgenda(_MemoryStore(), 5),
    scheduler: scheduler,
    enabled: () async => enabled,
    bodyFor: (at) => 'at ${at.hour}:${at.minute.toString().padLeft(2, '0')}',
  );

  test(
    'a reminder is scheduled at the task\'s own wall-clock time with the user\'s own words',
    () async {
      final store = _MemoryStore();
      final private = PrivateAgenda(store, 5);
      await private.remember([7], 'موعد المحامي', 'ملف');
      final scheduler = _FakeScheduler();

      await build(
        _FakeApi([_item(7, DateTime(2026, 10, 10, 10, 30))]),
        scheduler,
        private: private,
      ).sync(now: now);

      final plan = scheduler.scheduled!.single;
      expect(plan.id, 7);
      expect(
        plan.title,
        'موعد المحامي',
        reason: 'the server held only the neutral title',
      );
      expect(plan.at, DateTime(2026, 10, 10, 10, 30));
      expect(plan.body, 'at 10:30');
    },
  );

  test('the lead time brings it earlier', () async {
    final scheduler = _FakeScheduler();

    await build(
      _FakeApi([_item(7, DateTime(2026, 10, 10, 10, 30))], lead: 60),
      scheduler,
    ).sync(now: now);

    expect(scheduler.scheduled!.single.at, DateTime(2026, 10, 10, 9, 30));
  });

  test(
    'inside the lead window it reminds almost at once, and a task already started is skipped',
    () async {
      final scheduler = _FakeScheduler();

      await build(
        _FakeApi([
          _item(1, DateTime(2026, 10, 10, 8, 20)),
          _item(2, DateTime(2026, 10, 10, 7, 0)),
        ], lead: 60),
        scheduler,
      ).sync(now: now);

      expect(scheduler.scheduled!.map((p) => p.id), [1]);
      expect(scheduler.scheduled!.single.at.isAfter(now), isTrue);
      expect(
        scheduler.scheduled!.single.at.isBefore(DateTime(2026, 10, 10, 8, 1)),
        isTrue,
      );
    },
  );

  test('only the nearest 60 are kept, soonest first', () async {
    final scheduler = _FakeScheduler();
    final items = [
      for (var i = 0; i < 70; i++)
        _item(
          100 + i,
          DateTime(2026, 10, 11, 9, 0).add(Duration(minutes: (69 - i) * 10)),
        ),
    ];

    await build(_FakeApi(items), scheduler).sync(now: now);

    expect(scheduler.scheduled, hasLength(AgendaReminders.maxPending));
    expect(scheduler.scheduled!.first.id, 169, reason: 'the soonest');
    expect(
      scheduler.scheduled!.map((p) => p.at).toList(),
      orderedEquals([...scheduler.scheduled!.map((p) => p.at)]..sort()),
    );
  });

  test('a medicine dose is reminded with its server title', () async {
    final scheduler = _FakeScheduler();

    await build(
      _FakeApi([
        _item(
          5,
          DateTime(2026, 10, 10, 14, 0),
          kind: 'medication',
          title: 'Panadol 500mg',
          isPrivate: false,
        ),
      ]),
      scheduler,
    ).sync(now: now);

    expect(scheduler.scheduled!.single.title, 'Panadol 500mg');
  });

  test(
    'switched off, everything this phone scheduled is dropped and nothing new is asked for',
    () async {
      final scheduler = _FakeScheduler();

      await build(
        _FakeApi([_item(7, DateTime(2026, 10, 10, 10, 30))]),
        scheduler,
        enabled: false,
      ).sync(now: now);

      expect(scheduler.scheduled, isEmpty);
      expect(scheduler.permissionAsks, 0);
    },
  );

  test(
    'permission is asked only when there is something to remind, and a refusal schedules nothing',
    () async {
      final none = _FakeScheduler();
      await build(_FakeApi(const []), none).sync(now: now);
      expect(none.permissionAsks, 0);
      expect(none.scheduled, isEmpty);

      final refused = _FakeScheduler()..allowed = false;
      await build(
        _FakeApi([_item(7, DateTime(2026, 10, 10, 10, 30))]),
        refused,
      ).sync(now: now);
      expect(refused.permissionAsks, 1);
      expect(refused.scheduled, isNull, reason: 'nothing was scheduled');
    },
  );

  test(
    'offline, a sync does nothing and does not throw (what is already scheduled stays)',
    () async {
      final scheduler = _FakeScheduler();
      final api = _FakeApi([_item(7, DateTime(2026, 10, 10, 10, 30))])
        ..offline = true;

      await build(api, scheduler).sync(now: now);

      expect(scheduler.replaceCalls, 0);
    },
  );
}
