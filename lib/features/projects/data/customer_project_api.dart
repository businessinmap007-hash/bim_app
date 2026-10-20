import '../../../core/network/api_client.dart';
import 'models/customer_project_view.dart';

/// /operations/{type}/{id}/project — a customer's read-only progress view
/// of the project a business linked to their order/booking. See
/// Api\V2\CustomerProjectController::show.
class CustomerProjectApi {
  final ApiClient _client;
  const CustomerProjectApi(this._client);

  /// Null when the business hasn't linked a project to this operation yet.
  Future<CustomerProjectView?> show(String operationType, int operationId) async {
    final data = await _client.get('/operations/$operationType/$operationId/project') as Map<String, dynamic>;
    if (data['project'] == null) return null;
    return CustomerProjectView.fromJson(data);
  }

  /// Which side is asking (`business` / `customer`) — needed even when no project is linked yet.
  Future<String> viewerOf(String operationType, int operationId) async {
    final data = await _client.get('/operations/$operationType/$operationId/project') as Map<String, dynamic>;
    return data['viewer'] as String? ?? 'customer';
  }

  String _base(String type, int id) => '/operations/$type/$id/project';

  Future<void> agreeToPlan(String type, int id) => _client.post('${_base(type, id)}/agreement/agree');

  Future<void> declinePlan(String type, int id, String note) => _client.post('${_base(type, id)}/agreement/decline', data: {'note': note});

  Future<void> decideRequest(String type, int id, int requestId, {required bool approve, String? note}) =>
      _client.post('${_base(type, id)}/change-requests/$requestId/${approve ? 'approve' : 'reject'}', data: {'note': ?note});

  Future<void> decideStart(String type, int id, int taskId, {required bool approve, String? note}) =>
      _client.post('${_base(type, id)}/tasks/$taskId/start/${approve ? 'approve' : 'decline'}', data: {'note': ?note});

  /// The customer approves a completed stage that asked for it.
  Future<void> approve(String operationType, int operationId, int taskId) =>
      _client.post('/operations/$operationType/$operationId/project/tasks/$taskId/approve');

  /// …or sends it back; [note] is required.
  Future<void> reject(String operationType, int operationId, int taskId, String note) =>
      _client.post('/operations/$operationType/$operationId/project/tasks/$taskId/reject', data: {'note': note});
}
