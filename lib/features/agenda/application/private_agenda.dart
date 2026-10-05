import '../data/agenda_local_store.dart';
import '../data/models/agenda_item.dart';

/// «الأجندا تُحفظ على الفون» — the title and notes of the user's personal tasks live here, on the phone. The server
/// keeps only the time (so two things are never booked into the same minute, and a reminder can fire).
///
/// [show] puts the phone's words back on what the server sent. A personal task the server still holds whole (made
/// before this, or on another phone) is ADOPTED: written here first, and only then is the server told to drop its
/// copy — so the words are never in neither place.
class PrivateAgenda {
  final AgendaLocalStore _store;
  final int? _userId;

  /// Asks the server to drop the title/notes of these tasks (it keeps the time).
  final Future<void> Function(List<int> ids)? _scrub;
  Map<int, PrivateNote>? _notes;
  Future<void>? _loading;

  PrivateAgenda(
    this._store,
    this._userId, {
    Future<void> Function(List<int>)? scrub,
  }) : _scrub = scrub;

  Future<void> _ensure() => _loading ??= _load();

  Future<void> _load() async {
    final id = _userId;
    _notes = id == null ? <int, PrivateNote>{} : await _store.read(id);
  }

  Future<void> _save() async {
    final id = _userId;
    if (id != null) await _store.write(id, _notes!);
  }

  /// The items as the user wrote them.
  Future<List<AgendaItem>> show(List<AgendaItem> items) async {
    await _ensure();
    final notes = _notes!;

    final adopted = <int>[];
    for (final i in items) {
      if (i.isPersonal &&
          !i.isPrivate &&
          !notes.containsKey(i.id) &&
          i.title.isNotEmpty) {
        notes[i.id] = PrivateNote(title: i.title, notes: i.notes);
        adopted.add(i.id);
      }
    }
    if (adopted.isNotEmpty) {
      await _save();
      try {
        await _scrub?.call(adopted);
      } catch (_) {
        // tried again the next time the day is read
      }
    }

    return [
      for (final i in items)
        if (i.isPersonal && notes[i.id] != null)
          i.copyWith(title: notes[i.id]!.title, notes: notes[i.id]!.notes)
        else
          i,
    ];
  }

  Future<void> remember(Iterable<int> ids, String title, String? notes) async {
    await _ensure();
    for (final id in ids) {
      _notes![id] = PrivateNote(
        title: title,
        notes: notes != null && notes.trim().isNotEmpty ? notes.trim() : null,
      );
    }
    await _save();
  }

  Future<void> forget(int id) async {
    await _ensure();
    if (_notes!.remove(id) != null) await _save();
  }

  /// What the encrypted backup carries.
  Future<List<Map<String, dynamic>>> toJson() async {
    await _ensure();
    return [
      for (final e in _notes!.entries) {'id': e.key, ...e.value.toJson()},
    ];
  }

  /// A restored backup brings back what this phone does not have.
  Future<void> restore(Iterable<Map<String, dynamic>> rows) async {
    await _ensure();
    for (final r in rows) {
      final id = r['id'];
      if (id is int && !_notes!.containsKey(id)) {
        _notes![id] = PrivateNote.fromJson(r);
      }
    }
    await _save();
  }
}
