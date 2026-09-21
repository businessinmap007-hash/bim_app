import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../chat/data/models/thread_message.dart';
import 'models/body_report.dart';
import 'models/training_plan.dart';
import 'models/exercise_library.dart';
import 'models/set_log.dart';
import 'models/trainer_weekly_summary.dart';
import 'models/weekly_summary.dart';

typedef TrainingChatPage = ({List<ThreadMessage> messages, ChatThread thread});


String _isoDate(DateTime d) => d.toIso8601String().split('T').first;

/// /training-plans — the client's side of the plans a trainer assigned them.
/// See Api\V2\ClientTrainingController, TrainingChatController (client* methods),
/// BodyCompositionController::clientIndex. A plan is assigned by the trainer,
/// not requested by the client — there's no "browse and enroll" flow here,
/// only a "plans assigned to me" list, same as `mineOrFail()` scopes every
/// action on the backend.
class TrainingApi {
  final ApiClient _client;
  const TrainingApi(this._client);

  Future<Paginated<TrainingPlan>> myPlans({
    String? status,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/training-plans',
              query: {'status': ?status, 'page': page},
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, TrainingPlan.fromJson);
  }

  Future<TrainingPlan> plan(int id) async {
    final data =
        await _client.get('/training-plans/$id') as Map<String, dynamic>;
    return TrainingPlan.fromJson(data['plan'] as Map<String, dynamic>);
  }

  /// The trainer's plan is `pending` until I confirm it — the only thing
  /// that actually activates it (TrainingPlanService::accept()).
  Future<TrainingPlan> accept(int planId) async {
    final data = await _client.post('/training-plans/$planId/accept') as Map<String, dynamic>;
    return TrainingPlan.fromJson(data['plan'] as Map<String, dynamic>);
  }

  Future<TrainingPlan> decline(int planId) async {
    final data = await _client.post('/training-plans/$planId/decline') as Map<String, dynamic>;
    return TrainingPlan.fromJson(data['plan'] as Map<String, dynamic>);
  }

  Future<PlanProgressLog> logProgress(
    int planId, {
    DateTime? loggedOn,
    double? weight,
    String? notes,
  }) async {
    final data =
        await _client.post(
              '/training-plans/$planId/progress',
              data: {
                if (loggedOn != null) 'logged_on': _isoDate(loggedOn),
                'weight': ?weight,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
              },
            )
            as Map<String, dynamic>;
    return PlanProgressLog.fromJson(data['progress'] as Map<String, dynamic>);
  }

  /// Confirms one set. [reps] and [weight] are what was actually done —
  /// both optional; a set can be confirmed without numbers.
  Future<SetConfirmation> completeRound(
    int planId,
    int exerciseId, {
    DateTime? forDate,
    int? reps,
    double? weight,
  }) async {
    final data =
        await _client.post(
              '/training-plans/$planId/exercises/$exerciseId/complete-round',
              data: {
                if (forDate != null) 'for_date': _isoDate(forDate),
                'reps': ?reps,
                'weight': ?weight,
              },
            )
            as Map<String, dynamic>;
    return SetConfirmation(
      round: LoggedSet.fromJson(data['round'] as Map<String, dynamic>),
      completedRounds: data['completed_rounds'] as int,
      totalSets: data['total_sets'] as int?,
      sessionCompleted: data['session_completed'] as bool? ?? false,
    );
  }

  /// Corrects the reps/weight of a set already confirmed.
  Future<LoggedSet> updateRound(int planId, int exerciseId, int roundId, {int? reps, double? weight}) async {
    final data =
        await _client.put(
              '/training-plans/$planId/exercises/$exerciseId/rounds/$roundId',
              data: {'reps': reps, 'weight': weight},
            )
            as Map<String, dynamic>;
    return LoggedSet.fromJson(data['round'] as Map<String, dynamic>);
  }

  /// The month rolled up from the confirmed sets, for either side of a plan.
  Future<TrainingMonthlySummary> monthlySummary(int planId, {required String month, bool trainer = false}) async {
    final path = trainer ? '/business/training-plans/$planId/monthly-summary' : '/training-plans/$planId/monthly-summary';
    final data = await _client.get(path, query: {'month': month}) as Map<String, dynamic>;
    return TrainingMonthlySummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  /// Trainer: one day's sets per exercise, next to the prescription.
  Future<List<DayLogExercise>> dayLog(int planId, DateTime date) async {
    final data = await _client.get('/business/training-plans/$planId/log', query: {'date': _isoDate(date)}) as Map<String, dynamic>;
    final log = data['log'] as Map<String, dynamic>;
    return (log['exercises'] as List<dynamic>? ?? [])
        .map((e) => DayLogExercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TrainingWeeklySummary> weeklySummary(
    int planId, {
    DateTime? from,
  }) async {
    final data =
        await _client.get(
              '/training-plans/$planId/weekly-summary',
              query: {if (from != null) 'from': _isoDate(from)},
            )
            as Map<String, dynamic>;
    return TrainingWeeklySummary.fromJson(
      data['summary'] as Map<String, dynamic>,
    );
  }

  Future<List<BodyReport>> bodyReports(int planId) async {
    final data =
        await _client.get('/training-plans/$planId/body-reports')
            as Map<String, dynamic>;
    return (data['reports'] as List<dynamic>? ?? [])
        .map((e) => BodyReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TrainingChatPage> chatShow(int planId, {int perPage = 50}) async {
    final body = await _client.getForBody(
      '/training-plans/$planId/chat',
      query: {'per_page': perPage},
    );
    final messages = (body['data'] as List<dynamic>? ?? [])
        .map((e) => ThreadMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final thread = meta['thread'] != null
        ? ChatThread.fromJson(meta['thread'] as Map<String, dynamic>)
        : const ChatThread(
            id: 0,
            status: 'open',
            locked: false,
            expired: false,
          );
    return (messages: messages, thread: thread);
  }

  Future<ThreadMessage> chatPost(int planId, String body) async {
    final data =
        await _client.post(
              '/training-plans/$planId/chat/messages',
              data: {'body': body},
            )
            as Map<String, dynamic>;
    return ThreadMessage.fromJson(data);
  }

  // ─────────────────────────── Trainer (business) side ───────────────────────
  // Api\V2\TrainingPlanController — the trainer's own view of plans already
  // assigned to a client. No `store()`/create-plan here: it needs a client_id
  // this app has no picker for, the same gap already documented for
  // TrainingTemplateController::apply. Image uploads on exercises/meals
  // aren't wired up either — a smaller, skippable multipart flow.

  Future<Paginated<TrainingPlan>> myClientPlans({
    String? status,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/business/training-plans',
              query: {'status': ?status, 'page': page},
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, TrainingPlan.fromJson);
  }

  /// Sets the programme's length and how the weights climb, for every exercise
  /// at once (later weeks follow: targets are computed from the rule).
  Future<void> updateProgram(int planId, {int? weeks, int? everyWeeks, double? incrementKg}) async {
    await _client.put(
      '/business/training-plans/$planId/program',
      data: {
        'duration_weeks': ?weeks,
        if (everyWeeks != null || incrementKg != null)
          'progression': {'every_weeks': ?everyWeeks, 'increment_kg': ?incrementKg},
      },
    );
  }

  /// GET /business/training/exercise-library — the catalogue a trainer picks from.
  Future<ExerciseLibrary> exerciseLibrary() async {
    final data = await _client.get('/business/training/exercise-library') as Map<String, dynamic>;
    return ExerciseLibrary.fromJson(data);
  }

  /// GET /business/training-plans/weekly-summary — adherence for every
  /// active client at once (one query pass server-side).
  Future<TrainerWeeklySummary> trainerWeeklySummary() async {
    final data =
        await _client.get('/business/training-plans/weekly-summary')
            as Map<String, dynamic>;
    return TrainerWeeklySummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  Future<TrainingPlan> businessPlan(int id) async {
    final data =
        await _client.get('/business/training-plans/$id')
            as Map<String, dynamic>;
    return TrainingPlan.fromJson(data['plan'] as Map<String, dynamic>);
  }

  Future<TrainingPlan> setPlanStatus(int id, String status) async {
    final data =
        await _client.patch(
              '/business/training-plans/$id',
              data: {'status': status},
            )
            as Map<String, dynamic>;
    return TrainingPlan.fromJson(data['plan'] as Map<String, dynamic>);
  }

  Future<PlanExercise> addExercise(
    int planId, {
    required String name,
    int? libraryExerciseId,
    int? dayOfWeek,
    int? sets,
    String? reps,
    double? targetWeight,
    List<double>? setWeights,
    int? progressEveryWeeks,
    double? progressIncrementKg,
    int? restSeconds,
    String? notes,
  }) async {
    final data =
        await _client.post(
              '/business/training-plans/$planId/exercises',
              data: {
                'name': name,
                'library_exercise_id': ?libraryExerciseId,
                'day_of_week': ?dayOfWeek,
                'sets': ?sets,
                if (reps != null && reps.isNotEmpty) 'reps': reps,
                'target_weight': ?targetWeight,
                if (setWeights != null && setWeights.isNotEmpty) 'set_weights': setWeights,
                'progress_every_weeks': ?progressEveryWeeks,
                'progress_increment_kg': ?progressIncrementKg,
                'rest_seconds': ?restSeconds,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
              },
            )
            as Map<String, dynamic>;
    return PlanExercise.fromJson(data['exercise'] as Map<String, dynamic>);
  }

  /// The trainer's private photo library, reusable across clients.
  Future<List<LibraryPhoto>> trainerPhotos() async {
    final data = await _client.get('/business/training/photos') as Map<String, dynamic>;
    return (data['photos'] as List<dynamic>? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return LibraryPhoto(id: m['id'] as int, caption: m['caption'] as String?, url: m['image'] as String? ?? '');
    }).toList();
  }

  Future<void> addTrainerPhotos(List<Uint8List> photos) async {
    await _client.post(
      '/business/training/photos',
      data: FormData.fromMap({
        for (var i = 0; i < photos.length; i++)
          'images[$i]': MultipartFile.fromBytes(photos[i], filename: 'photo_$i.jpg'),
      }),
    );
  }

  Future<void> deleteTrainerPhoto(int id) => _client.delete('/business/training/photos/$id');

  /// Attach library photos to an exercise or meal. Each is copied into the
  /// plan, so one photo can serve any number of clients.
  Future<void> attachLibraryPhotos(int planId, String kind, int itemId, List<int> photoIds) async {
    await _client.post(
      '/business/training-plans/$planId/$kind/$itemId/images/from-library',
      data: {'photo_ids': photoIds},
    );
  }

  /// Trainer-only, private photos for one exercise (`kind` = 'exercises') or
  /// meal (`'meals'`). The server stores them outside the public web root; only
  /// the plan's trainee is ever handed a link.
  Future<void> addPlanPhotos(int planId, String kind, int itemId, List<Uint8List> photos) async {
    await _client.post(
      '/business/training-plans/$planId/$kind/$itemId/images',
      data: FormData.fromMap({
        for (var i = 0; i < photos.length; i++)
          'images[$i]': MultipartFile.fromBytes(photos[i], filename: 'photo_$i.jpg'),
      }),
    );
  }

  Future<void> removePlanPhoto(int planId, String kind, int itemId, int imageId) =>
      _client.delete('/business/training-plans/$planId/$kind/$itemId/images/$imageId');

  Future<void> removeExercise(int planId, int exerciseId) =>
      _client.delete('/business/training-plans/$planId/exercises/$exerciseId');

  Future<PlanMeal> addMeal(
    int planId, {
    required String mealType,
    required String name,
    int? calories,
    String? notes,
  }) async {
    final data =
        await _client.post(
              '/business/training-plans/$planId/meals',
              data: {
                'meal_type': mealType,
                'name': name,
                'calories': ?calories,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
              },
            )
            as Map<String, dynamic>;
    return PlanMeal.fromJson(data['meal'] as Map<String, dynamic>);
  }

  Future<void> removeMeal(int planId, int mealId) =>
      _client.delete('/business/training-plans/$planId/meals/$mealId');

  Future<List<BodyReport>> businessBodyReports(int planId) async {
    final data =
        await _client.get('/business/training-plans/$planId/body-reports')
            as Map<String, dynamic>;
    return (data['reports'] as List<dynamic>? ?? [])
        .map((e) => BodyReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBodyReport(
    int planId, {
    DateTime? forMonth,
    double? weightKg,
    double? muscleMassKg,
    double? fatPercent,
    double? waterPercent,
    String? notes,
  }) => _client.post(
    '/business/training-plans/$planId/body-reports',
    data: {
      if (forMonth != null) 'for_month': _isoDate(forMonth),
      'weight_kg': ?weightKg,
      'muscle_mass_kg': ?muscleMassKg,
      'fat_percent': ?fatPercent,
      'water_percent': ?waterPercent,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    },
  );

  Future<void> deleteBodyReport(int planId, int reportId) =>
      _client.delete('/business/training-plans/$planId/body-reports/$reportId');
}
