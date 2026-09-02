import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../chat/data/models/thread_message.dart';
import 'models/body_report.dart';
import 'models/training_plan.dart';
import 'models/weekly_summary.dart';

typedef TrainingChatPage = ({List<ThreadMessage> messages, ChatThread thread});
typedef CompleteRoundResult = ({int roundNumber, int completedRounds, int? totalSets});

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

  Future<Paginated<TrainingPlan>> myPlans({String? status, int page = 1}) async {
    final data = await _client.get(
      '/training-plans',
      query: {if (status != null) 'status': status, 'page': page},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, TrainingPlan.fromJson);
  }

  Future<TrainingPlan> plan(int id) async {
    final data = await _client.get('/training-plans/$id') as Map<String, dynamic>;
    return TrainingPlan.fromJson(data['plan'] as Map<String, dynamic>);
  }

  Future<PlanProgressLog> logProgress(int planId, {DateTime? loggedOn, double? weight, String? notes}) async {
    final data = await _client.post(
      '/training-plans/$planId/progress',
      data: {
        if (loggedOn != null) 'logged_on': _isoDate(loggedOn),
        if (weight != null) 'weight': weight,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    ) as Map<String, dynamic>;
    return PlanProgressLog.fromJson(data['progress'] as Map<String, dynamic>);
  }

  Future<CompleteRoundResult> completeRound(int planId, int exerciseId, {DateTime? forDate}) async {
    final data = await _client.post(
      '/training-plans/$planId/exercises/$exerciseId/complete-round',
      data: {if (forDate != null) 'for_date': _isoDate(forDate)},
    ) as Map<String, dynamic>;
    return (
      roundNumber: data['round_number'] as int,
      completedRounds: data['completed_rounds'] as int,
      totalSets: data['total_sets'] as int?,
    );
  }

  Future<TrainingWeeklySummary> weeklySummary(int planId, {DateTime? from}) async {
    final data = await _client.get(
      '/training-plans/$planId/weekly-summary',
      query: {if (from != null) 'from': _isoDate(from)},
    ) as Map<String, dynamic>;
    return TrainingWeeklySummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  Future<List<BodyReport>> bodyReports(int planId) async {
    final data = await _client.get('/training-plans/$planId/body-reports') as Map<String, dynamic>;
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
        : const ChatThread(id: 0, status: 'open', locked: false, expired: false);
    return (messages: messages, thread: thread);
  }

  Future<ThreadMessage> chatPost(int planId, String body) async {
    final data = await _client.post(
      '/training-plans/$planId/chat/messages',
      data: {'body': body},
    ) as Map<String, dynamic>;
    return ThreadMessage.fromJson(data);
  }
}
