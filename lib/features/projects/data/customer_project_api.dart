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
}
