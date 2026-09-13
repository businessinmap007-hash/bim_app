import '../../../core/network/api_client.dart';
import '../../orders/data/models/placed_order.dart';
import 'models/roster_driver.dart';

/// The connected delivery loop — driver identity/availability, a business's
/// own assignment of one of its roster drivers, and the two-QR pickup/
/// delivery handoff. See Api\V2\DeliveryController / DeliveryDispatchService.
class DeliveryApi {
  final ApiClient _client;
  const DeliveryApi(this._client);

  // ─────────────────────────── Driver identity ───────────────────────────

  /// Read-only: null means "not a registered driver yet". Never
  /// creates/reactivates a row the way register() deliberately does.
  Future<DriverStatus?> me() async {
    final data = await _client.get('/delivery/me') as Map<String, dynamic>?;
    return data == null ? null : DriverStatus.fromJson(data);
  }

  Future<DriverStatus> register({String? phone, String? vehicleLabel}) async {
    final data = await _client.post('/delivery/register', data: {
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (vehicleLabel != null && vehicleLabel.isNotEmpty) 'vehicle_label': vehicleLabel,
    }) as Map<String, dynamic>;
    return DriverStatus.fromJson(data);
  }

  Future<DriverStatus> setAvailability(bool isActive) async {
    final data = await _client.post('/delivery/availability', data: {'is_active': isActive}) as Map<String, dynamic>;
    return DriverStatus.fromJson(data);
  }

  Future<DriverStatus> pingLocation(double lat, double lng) async {
    final data = await _client.post('/delivery/location', data: {'lat': lat, 'lng': lng}) as Map<String, dynamic>;
    return DriverStatus.fromJson(data);
  }

  /// The driver's own currently in-progress deliveries — full invoice,
  /// customer address/phone/location included (OrderResource).
  Future<List<PlacedOrder>> myOrders() async {
    final body = await _client.getForBody('/delivery/my-orders');
    final items = body['data'] as List<dynamic>? ?? [];
    return items.map((e) => PlacedOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─────────────────────────── Business-owned fleet ───────────────────────

  /// The business's own roster, with live workload and distance — the
  /// "choose who delivers this" screen after marking an order ready.
  Future<List<RosterDriver>> businessRoster() async {
    final data = await _client.get('/business/delivery-drivers') as Map<String, dynamic>;
    final drivers = data['drivers'] as List<dynamic>? ?? [];
    return drivers.map((e) => RosterDriver.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// The merchant hands the order directly to one of its own drivers.
  Future<void> assignDriver({required int orderId, required int driverId}) =>
      _client.post('/business/orders/$orderId/assign-driver', data: {'driver_id': driverId});

  // ─────────────────────────── Pickup / delivery QR ────────────────────────

  /// The business (or, in principle, the driver — but the assignment screen
  /// is where this is actually called from) issues the pickup QR's token.
  Future<String> issuePickupToken(int orderId) async {
    final data = await _client.post('/delivery/orders/$orderId/pickup-token') as Map<String, dynamic>;
    return data['pickup_token'] as String;
  }

  /// The driver issues the delivery QR's token, once they've picked up.
  Future<String> issueDeliveryToken(int orderId) async {
    final data = await _client.post('/delivery/orders/$orderId/delivery-token') as Map<String, dynamic>;
    return data['delivery_token'] as String;
  }

  /// The driver scans the restaurant's pickup QR.
  Future<void> confirmPickup(String token) => _client.post('/delivery/pickup/$token/confirm');

  /// The customer scans the driver's delivery QR.
  Future<void> confirmDelivery(String token) => _client.post('/delivery/deliver/$token/confirm');

  /// A driver accepting an unassigned order from the open pool (existing,
  /// pre-assignment path — kept here so the driver dashboard can offer it
  /// alongside "my active orders" if the driver isn't privately linked).
  Future<void> acceptOrder(int orderId) => _client.post('/delivery/orders/$orderId/accept');

  Future<List<Map<String, dynamic>>> availableOrders() async {
    final body = await _client.getForBody('/delivery/available-orders');
    final orders = body['orders'] as List<dynamic>? ?? [];
    return orders.cast<Map<String, dynamic>>();
  }
}
