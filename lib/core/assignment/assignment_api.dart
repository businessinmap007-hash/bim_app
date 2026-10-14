import '../network/api_client.dart';
import 'assignee.dart';

/// «نظام التعيين» over HTTP — see Api\V2\AssignmentController. Every business uses the same three calls.
class AssignmentApi {
  final ApiClient _client;
  const AssignmentApi(this._client);

  /// Who can be assigned at the business I work for ([businessId] when a delegate acts for one of several).
  Future<List<Assignee>> providers({int? businessId}) async {
    final data = await _client.get('/business/providers', query: {'business_id': ?businessId}) as Map<String, dynamic>;
    return _list(data);
  }

  /// The people a customer may see at a business.
  Future<List<Assignee>> publicProviders(int businessId) async {
    final data = await _client.get('/businesses/$businessId/providers') as Map<String, dynamic>;
    return _list(data);
  }

  /// Hands a booking to [assigneeId], or takes it back with null. Returns who is responsible now.
  Future<Assignee?> assignBooking(int bookingId, int? assigneeId, {int? businessId}) async {
    final path = '/business/bookings/$bookingId/assignee${businessId == null ? '' : '?business_id=$businessId'}';
    final data = await _client.put(path, data: {'assignee_id': assigneeId}) as Map<String, dynamic>;
    final json = data['assignee'];
    return json is Map<String, dynamic> ? Assignee.fromJson(json) : null;
  }

  List<Assignee> _list(Map<String, dynamic> data) =>
      ((data['providers'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(Assignee.fromJson).toList();
}
