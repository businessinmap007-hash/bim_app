import '../../../core/network/api_client.dart';
import 'models/agenda_item.dart';
import 'models/agenda_settings.dart';

/// /agenda — see Api\V2\AgendaController. Day view, personal tasks (single
/// and recurring) and the calendar-subscription URL are wired up; the week
/// grid and the one-off .ics download are not (the subscription covers it).
class AgendaApi {
  final ApiClient _client;
  const AgendaApi(this._client);

  Future<List<AgendaItem>> day(DateTime date) async {
    final data = await _client.get(
      '/agenda',
      query: {'date': _dateOnly(date)},
    ) as Map<String, dynamic>;
    return (data['items'] as List<dynamic>? ?? [])
        .map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AgendaItem> addTask({
    required String title,
    required DateTime startsAt,
    DateTime? endsAt,
    String? notes,
    bool remind = false,
  }) async {
    final data = await _client.post(
      '/agenda',
      data: {
        'title': title,
        'starts_at': startsAt.toIso8601String(),
        if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'remind': remind,
      },
    ) as Map<String, dynamic>;
    return AgendaItem.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/agenda/$id');

  /// POST /agenda/recurring — a repeating personal task, from today.
  /// `weekdays` is 0=Sun..6=Sat and only applies to weekly. Days that clash
  /// with an existing commitment are skipped by the server, not failed.
  Future<({int created, int skipped})> addRecurring({
    required String title,
    required String startTime,
    required int durationMinutes,
    required String frequency,
    List<int> weekdays = const [],
    int weeks = 4,
    String? notes,
    bool remind = false,
  }) async {
    final data = await _client.post(
      '/agenda/recurring',
      data: {
        'title': title,
        'start_time': startTime,
        'duration_minutes': durationMinutes,
        'frequency': frequency,
        if (frequency == 'weekly') 'weekdays': weekdays,
        'weeks': weeks,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'remind': remind,
      },
    ) as Map<String, dynamic>;
    return (
      created: (data['created'] as num?)?.toInt() ?? 0,
      skipped: (data['skipped'] as num?)?.toInt() ?? 0,
    );
  }

  /// GET /me/agenda-feed — the calendar-subscription URL (webcal-style ICS).
  Future<String> feedUrl() async {
    final data = await _client.get('/me/agenda-feed') as Map<String, dynamic>;
    return data['url'] as String;
  }

  /// POST /me/agenda-feed/rotate — a new URL; the old one stops working.
  Future<String> rotateFeedUrl() async {
    final data = await _client.post('/me/agenda-feed/rotate') as Map<String, dynamic>;
    return data['url'] as String;
  }

  Future<MealTimes> mealTimes() async {
    final data = await _client.get('/me/meal-times') as Map<String, dynamic>;
    return MealTimes.fromJson(data['meal_times'] as Map<String, dynamic>);
  }

  Future<MealTimes> updateMealTimes({
    required String breakfastAt,
    required String lunchAt,
    required String dinnerAt,
  }) async {
    final data = await _client.put(
      '/me/meal-times',
      data: {'breakfast_at': breakfastAt, 'lunch_at': lunchAt, 'dinner_at': dinnerAt},
    ) as Map<String, dynamic>;
    return MealTimes.fromJson(data['meal_times'] as Map<String, dynamic>);
  }

  Future<ReminderPreferences> reminderPreferences() async {
    final data = await _client.get('/me/reminder-preferences') as Map<String, dynamic>;
    return ReminderPreferences.fromJson(data['reminder_preferences'] as Map<String, dynamic>);
  }

  Future<ReminderPreferences> updateReminderPreferences({
    required int appointmentFirstLeadMinutes,
    required int? appointmentSecondLeadMinutes,
    required int agendaLeadMinutes,
  }) async {
    final data = await _client.put(
      '/me/reminder-preferences',
      data: {
        'appointment_first_lead_minutes': appointmentFirstLeadMinutes,
        'appointment_second_lead_minutes': appointmentSecondLeadMinutes,
        'agenda_lead_minutes': agendaLeadMinutes,
      },
    ) as Map<String, dynamic>;
    return ReminderPreferences.fromJson(data['reminder_preferences'] as Map<String, dynamic>);
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
