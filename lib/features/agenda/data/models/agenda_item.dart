/// Mirrors `AgendaController::serialize()` — one entry on a day: an
/// appointment, a booking, a medication dose, or a personal task the user
/// added themselves. Only `kind == 'personal'` items can be deleted from
/// this screen — everything else is a mirror of its own source (a booking,
/// an appointment) and gets cancelled from there.
class AgendaItem {
  final int id;
  final String kind;
  final String title;
  final String? notes;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool blocking;

  const AgendaItem({
    required this.id,
    required this.kind,
    required this.title,
    this.notes,
    this.startsAt,
    this.endsAt,
    required this.blocking,
  });

  bool get isPersonal => kind == 'personal';

  factory AgendaItem.fromJson(Map<String, dynamic> json) => AgendaItem(
    id: json['id'] as int,
    kind: json['kind'] as String? ?? 'personal',
    title: json['title'] as String? ?? '',
    notes: json['notes'] as String?,
    startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
    endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
    blocking: json['blocking'] as bool? ?? false,
  );
}
