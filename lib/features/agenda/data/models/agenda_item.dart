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

/// One day of the week grid — every day is present, empty ones included.
class AgendaWeekDay {
  final DateTime date;
  final List<AgendaItem> items;

  const AgendaWeekDay({required this.date, this.items = const []});

  factory AgendaWeekDay.fromJson(Map<String, dynamic> json) => AgendaWeekDay(
    date: DateTime.parse(json['date'] as String),
    items: (json['items'] as List<dynamic>? ?? []).map((e) => AgendaItem.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

/// `GET /agenda/week` — seven days starting from the Saturday of the week that
/// contains the requested date.
class AgendaWeek {
  final DateTime from;
  final DateTime to;
  final List<AgendaWeekDay> days;

  const AgendaWeek({required this.from, required this.to, this.days = const []});

  factory AgendaWeek.fromJson(Map<String, dynamic> json) => AgendaWeek(
    from: DateTime.parse(json['from'] as String),
    to: DateTime.parse(json['to'] as String),
    days: (json['days'] as List<dynamic>? ?? []).map((e) => AgendaWeekDay.fromJson(e as Map<String, dynamic>)).toList(),
  );
}
