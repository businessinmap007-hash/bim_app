import '../../../core/network/api_client.dart';
import 'models/stay_request.dart';

/// A hotel guest's requests during a running stay, and the hotel's side of them.
/// See Api\V2\StayRequestController and Api\V2\BusinessStayRequestController.
class StayRequestsApi {
  final ApiClient _client;
  const StayRequestsApi(this._client);

  // ── the guest ─────────────────────────────────────────────────────────────

  Future<StayRequestOptions> options(int bookingId) async {
    final data = await _client.get('/bookings/$bookingId/stay-requests') as Map<String, dynamic>;
    return StayRequestOptions.fromJson(data);
  }

  Future<StayRequest> create(int bookingId, {required String kind, String? category, String? title, String? note}) async {
    final data = await _client.post(
      '/bookings/$bookingId/stay-requests',
      data: {'kind': kind, 'category': ?category, 'title': ?title, 'note': ?note},
    ) as Map<String, dynamic>;
    return StayRequest.fromJson(data['request'] as Map<String, dynamic>);
  }

  Future<void> cancel(int bookingId, int requestId) => _client.post('/bookings/$bookingId/stay-requests/$requestId/cancel');

  // ── the hotel ─────────────────────────────────────────────────────────────

  Future<StayRequestsPayload> forHotel({String status = 'open'}) async {
    final data = await _client.get('/business/stay-requests', query: {'status': status}) as Map<String, dynamic>;
    return StayRequestsPayload.fromJson(data);
  }

  Future<StayRequest> setStatus(int requestId, String status) async {
    final data = await _client.patch('/business/stay-requests/$requestId', data: {'status': status}) as Map<String, dynamic>;
    return StayRequest.fromJson(data['request'] as Map<String, dynamic>);
  }

  Future<StayServicesPayload> services() async {
    final data = await _client.get('/business/stay-services') as Map<String, dynamic>;
    return StayServicesPayload.fromJson(data);
  }

  Future<StayServicesPayload> addServices(List<String> titles) async {
    final data = await _client.post('/business/stay-services', data: {'titles': titles}) as Map<String, dynamic>;
    return StayServicesPayload.fromJson(data);
  }

  Future<StayServicesPayload> setServiceActive(int id, bool active) async {
    final data = await _client.patch('/business/stay-services/$id', data: {'is_active': active}) as Map<String, dynamic>;
    return StayServicesPayload.fromJson(data);
  }

  Future<StayServicesPayload> removeService(int id) async {
    final data = await _client.delete('/business/stay-services/$id') as Map<String, dynamic>;
    return StayServicesPayload.fromJson(data);
  }
}
