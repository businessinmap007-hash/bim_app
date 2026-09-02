import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/training_template.dart';

/// /business/training-templates — see Api\V2\TrainingTemplateController.
/// Gated server-side on the "training" business capability (owner, or a
/// delegate granted it). `apply` (instantiate a plan for a client) is
/// deliberately not wired up here — it needs a client_id, and this app has
/// no way to search/pick a person by phone or name yet (same gap noted for
/// the friend co-guarantor feature and direct clinic booking).
class TrainingTemplatesApi {
  final ApiClient _client;
  const TrainingTemplatesApi(this._client);

  Future<Paginated<TrainingTemplate>> list({int page = 1}) async {
    final data = await _client.get('/business/training-templates', query: {'page': page}) as Map<String, dynamic>;
    return Paginated.fromJson(data, TrainingTemplate.fromJson);
  }

  Future<TrainingTemplate> show(int id) async {
    final data = await _client.get('/business/training-templates/$id') as Map<String, dynamic>;
    return TrainingTemplate.fromJson(data['template'] as Map<String, dynamic>);
  }

  Future<TrainingTemplate> create({required String title, String? goal, String? notes}) async {
    final data = await _client.post(
      '/business/training-templates',
      data: {
        'title': title,
        if (goal != null && goal.isNotEmpty) 'goal': goal,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    ) as Map<String, dynamic>;
    return TrainingTemplate.fromJson(data['template'] as Map<String, dynamic>);
  }

  Future<TrainingTemplate> update(int id, {required String title, String? goal, String? notes}) async {
    final data = await _client.put(
      '/business/training-templates/$id',
      data: {
        'title': title,
        if (goal != null && goal.isNotEmpty) 'goal': goal,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    ) as Map<String, dynamic>;
    return TrainingTemplate.fromJson(data['template'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/business/training-templates/$id');

  Future<void> addExercise(
    int templateId, {
    int? dayOfWeek,
    required String name,
    int? sets,
    String? reps,
    int? restSeconds,
    String? notes,
  }) async {
    await _client.post('/business/training-templates/$templateId/exercises', data: {
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      'name': name,
      if (sets != null) 'sets': sets,
      if (reps != null && reps.isNotEmpty) 'reps': reps,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<void> removeExercise(int templateId, int exerciseId) =>
      _client.delete('/business/training-templates/$templateId/exercises/$exerciseId');

  Future<void> addMeal(
    int templateId, {
    required String mealType,
    required String name,
    int? calories,
    String? notes,
  }) async {
    await _client.post('/business/training-templates/$templateId/meals', data: {
      'meal_type': mealType,
      'name': name,
      if (calories != null) 'calories': calories,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<void> removeMeal(int templateId, int mealId) =>
      _client.delete('/business/training-templates/$templateId/meals/$mealId');
}
