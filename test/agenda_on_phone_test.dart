import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/agenda/application/private_agenda.dart';
import 'package:bim_app/features/agenda/data/agenda_local_store.dart';
import 'package:bim_app/features/agenda/data/models/agenda_item.dart';
import 'package:bim_app/features/medical_file/data/medical_backup_crypto.dart';
import 'package:bim_app/features/medical_file/data/medical_file.dart';

/// «الأجندا تُحفظ على الفون» — a personal task's title and notes live on the phone; the server holds only the time.
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

AgendaItem _personal(
  int id, {
  String title = 'مهمة شخصية',
  String? notes,
  bool isPrivate = true,
}) => AgendaItem(
  id: id,
  kind: 'personal',
  title: title,
  notes: notes,
  startsAt: DateTime(2026, 10, 10, 10),
  blocking: true,
  isPrivate: isPrivate,
);

void main() {
  test(
    'the phone puts the user\'s words back on a neutral item from the server',
    () async {
      final store = _MemoryStore();
      final agenda = PrivateAgenda(store, 5);
      await agenda.remember([7], 'موعد المحامي', 'ملف القضية');

      final shown = await agenda.show([_personal(7), _personal(8)]);

      expect(shown[0].title, 'موعد المحامي');
      expect(shown[0].notes, 'ملف القضية');
      expect(
        shown[1].title,
        'مهمة شخصية',
        reason: 'a task this phone knows nothing about shows the neutral title',
      );
      expect(store.saved[7]!.title, 'موعد المحامي');
    },
  );

  test('an appointment or a booking is never touched', () async {
    final agenda = PrivateAgenda(_MemoryStore(), 5);
    await agenda.remember([3], 'x', null);
    const appointment = AgendaItem(
      id: 3,
      kind: 'appointment',
      title: 'عيادة',
      blocking: true,
    );

    final shown = await agenda.show([appointment]);

    expect(shown.single.title, 'عيادة');
  });

  test(
    'a task the server still holds whole is adopted: stored here first, then the server drops its copy',
    () async {
      final store = _MemoryStore();
      final scrubbed = <List<int>>[];
      final agenda = PrivateAgenda(
        store,
        5,
        scrub: (ids) async {
          expect(
            store.saved.keys,
            containsAll(ids),
            reason:
                'the words are on the phone BEFORE the server is told to drop them',
          );
          scrubbed.add(ids);
        },
      );

      final shown = await agenda.show([
        _personal(9, title: 'سر قديم', notes: 'تفاصيل', isPrivate: false),
      ]);

      expect(shown.single.title, 'سر قديم');
      expect(store.saved[9]!.notes, 'تفاصيل');
      expect(scrubbed.single, [9]);

      await agenda.show([_personal(9, title: 'سر قديم', isPrivate: false)]);
      expect(scrubbed, hasLength(1), reason: 'adopted once');
    },
  );

  test(
    'a failed scrub loses nothing and is retried on the next read',
    () async {
      final store = _MemoryStore();
      var calls = 0;
      final agenda = PrivateAgenda(
        store,
        5,
        scrub: (ids) async {
          calls++;
          if (calls == 1) throw Exception('offline');
        },
      );

      final shown = await agenda.show([
        _personal(9, title: 'سر', isPrivate: false),
      ]);

      expect(shown.single.title, 'سر');
      expect(store.saved[9], isNotNull);
    },
  );

  test('a deleted task is forgotten', () async {
    final store = _MemoryStore();
    final agenda = PrivateAgenda(store, 5);
    await agenda.remember([7], 'x', null);

    await agenda.forget(7);

    expect(store.saved, isEmpty);
  });

  test(
    'the agenda travels in the encrypted backup, and an older backup still opens',
    () async {
      final store = _MemoryStore();
      final agenda = PrivateAgenda(store, 5);
      await agenda.remember([7], 'موعد المحامي', 'ملف');

      final blob = await MedicalBackupCrypto.seal(
        const MedicalFile(bloodType: 'A+'),
        'a long passphrase',
        agenda: await agenda.toJson(),
      );
      final back = await MedicalBackupCrypto.open(blob, 'a long passphrase');

      expect(back.file.bloodType, 'A+');
      final restored = PrivateAgenda(_MemoryStore(), 5);
      await restored.restore(back.agenda);
      expect(
        (await restored.show([_personal(7)])).single.title,
        'موعد المحامي',
      );

      final without = await MedicalBackupCrypto.seal(
        const MedicalFile(),
        'a long passphrase',
      );
      expect(
        (await MedicalBackupCrypto.open(without, 'a long passphrase')).agenda,
        isEmpty,
      );
    },
  );
}
