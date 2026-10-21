import '../../../core/network/api_client.dart';
import '../../projects/data/models/project_showcase.dart';

/// «نتائج موثَّقة» for training / nutrition plans, and the general consent — see Api\\V2\\PlanShowcaseController.
class ShowcaseApi {
  final ApiClient _client;
  const ShowcaseApi(this._client);

  /// Trainer: where my request to show this plan's results stands (null = never asked).
  Future<ShowcaseRequest?> trainerShowcase(int planId) async {
    final data = await _client.get('/business/training-plans/$planId/showcase') as Map<String, dynamic>;
    return ShowcaseRequest.fromJsonOrNull(data['showcase']);
  }

  Future<ShowcaseRequest?> requestShowcase(int planId, {required String publicTitle, String? note, String consentMode = 'once'}) async {
    final data = await _client.post(
      '/business/training-plans/$planId/showcase',
      data: {'public_title': publicTitle, if (note != null && note.isNotEmpty) 'note': note, 'consent_mode': consentMode},
    ) as Map<String, dynamic>;
    return ShowcaseRequest.fromJsonOrNull(data['showcase']);
  }

  Future<void> trainerWithdraw(int planId) => _client.delete('/business/training-plans/$planId/showcase');

  /// Client: answer the trainer's request, or take a live post down.
  Future<void> decide(int planId, {required bool approve, String? note, String? consentMode}) =>
      _client.post('/training-plans/$planId/showcase/${approve ? 'approve' : 'decline'}', data: {'note': ?note, 'consent_mode': ?consentMode});

  /// Month-by-month mode: let one month's results be shown (or not).
  Future<void> decideMonth(int planId, String month, {required bool approve}) =>
      _client.post('/training-plans/$planId/showcase/months/$month/${approve ? 'approve' : 'decline'}');

  Future<void> clientWithdraw(int planId) => _client.post('/training-plans/$planId/showcase/withdraw');
}
