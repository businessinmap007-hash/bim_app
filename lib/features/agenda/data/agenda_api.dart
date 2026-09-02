import '../../../core/network/api_client.dart';
import 'models/agenda_item.dart';

/// /agenda — see Api\V2\AgendaController. Only the day view + personal-task
/// add/delete are wired up; week grid, ICS export, and the calendar
/// subscription feed aren't used by this app.
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

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
