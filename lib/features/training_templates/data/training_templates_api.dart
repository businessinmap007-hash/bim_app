import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/training_template.dart';

/// /business/training-templates — see Api\V2\TrainingTemplateController.
/// Gated server-side on the "training" business capability (owner, or a
/// delegate granted it). `apply` instantiates a plan for a client the
/// trainer found by exact phone/e-mail (see TrainingApi.lookupClient).
class TrainingTemplatesApi {
  final ApiClient _client;
  const TrainingTemplatesApi(this._client);

  Future<Paginated<TrainingTemplate>> list({int page = 1}) async {
    final data =
        await _client.get('/business/training-templates', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, TrainingTemplate.fromJson);
  }

  Future<TrainingTemplate> show(int id) async {
    final data =
        await _client.get('/business/training-templates/$id')
            as Map<String, dynamic>;
    return TrainingTemplate.fromJson(data['template'] as Map<String, dynamic>);
  }

  Future<TrainingTemplate> create({
    required String title,
    String? goal,
    String? notes,
  }) async {
    final data =
        await _client.post(
              '/business/training-templates',
              data: {
                'title': title,
                if (goal != null && goal.isNotEmpty) 'goal': goal,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
              },
            )
            as Map<String, dynamic>;
    return TrainingTemplate.fromJson(data['template'] as Map<String, dynamic>);
  }

  Future<TrainingTemplate> update(
    int id, {
    required String title,
    String? goal,
    String? notes,
    int? durationWeeks,
  }) async {
    final data =
        await _client.put(
              '/business/training-templates/$id',
              data: {
                'title': title,
                if (goal != null && goal.isNotEmpty) 'goal': goal,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                'duration_weeks': durationWeeks,
              },
            )
            as Map<String, dynamic>;
    return TrainingTemplate.fromJson(data['template'] as Map<String, dynamic>);
  }

  /// POST /business/training-templates/{id}/apply — a plan for [clientId], from a
  /// COPY of the template. [weeks] overrides the template's own length.
  /// Returns the new plan's id; the client gets it to accept.
  Future<int> apply(int id, {required int clientId, DateTime? startsOn, int? weeks}) async {
    final data =
        await _client.post(
              '/business/training-templates/$id/apply',
              data: {
                'client_id': clientId,
                if (startsOn != null) 'starts_on': '${startsOn.year}-${startsOn.month.toString().padLeft(2, '0')}-${startsOn.day.toString().padLeft(2, '0')}',
                'duration_weeks': ?weeks,
              },
            )
            as Map<String, dynamic>;
    return data['plan_id'] as int;
  }

  Future<void> delete(int id) =>
      _client.delete('/business/training-templates/$id');

  Future<void> addExercise(
    int templateId, {
    int? dayOfWeek,
    required String name,
    int? libraryExerciseId,
    int? sets,
    String? reps,
    String? dayLabel,
    List<double>? setWeights,
    int? progressEveryWeeks,
    double? progressIncrementKg,
    int? restSeconds,
    String? notes,
  }) async {
    await _client.post(
      '/business/training-templates/$templateId/exercises',
      data: {
        'day_of_week': ?dayOfWeek,
        'name': name,
        'library_exercise_id': ?libraryExerciseId,
        if (dayLabel != null && dayLabel.isNotEmpty) 'day_label': dayLabel,
        if (setWeights != null && setWeights.isNotEmpty) 'set_weights': setWeights,
        'progress_every_weeks': ?progressEveryWeeks,
        'progress_increment_kg': ?progressIncrementKg,
        'sets': ?sets,
        if (reps != null && reps.isNotEmpty) 'reps': reps,
        'rest_seconds': ?restSeconds,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  Future<void> removeExercise(int templateId, int exerciseId) => _client.delete(
    '/business/training-templates/$templateId/exercises/$exerciseId',
  );

  Future<void> addMeal(
    int templateId, {
    required String mealType,
    required String name,
    int? calories,
    String? notes,
  }) async {
    await _client.post(
      '/business/training-templates/$templateId/meals',
      data: {
        'meal_type': mealType,
        'name': name,
        'calories': ?calories,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  Future<void> removeMeal(int templateId, int mealId) =>
      _client.delete('/business/training-templates/$templateId/meals/$mealId');
}
