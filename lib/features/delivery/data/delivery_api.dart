import '../../../core/network/api_client.dart';
import '../../orders/data/models/placed_order.dart';
import 'models/nearby_freelancer.dart';
import 'models/roster_driver.dart';

typedef BusinessRoster = ({List<RosterDriver> drivers, List<NearbyFreelancer> nearbyFreelancers});

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
  Future<List<RosterDriver>> businessRoster({int? businessId}) async {
    final data = await _client.get('/business/delivery-drivers', query: {'business_id': ?businessId}) as Map<String, dynamic>;
    final drivers = data['drivers'] as List<dynamic>? ?? [];
    return drivers.map((e) => RosterDriver.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Same roster, plus nearby freelance drivers (visibility only — a
  /// business can never assign one directly) — the "My Drivers" management
  /// screen, distinct from the plain assignment picker above.
  Future<BusinessRoster> businessRosterFull() async {
    final data = await _client.get('/business/delivery-drivers') as Map<String, dynamic>;
    final drivers = data['drivers'] as List<dynamic>? ?? [];
    final nearby = data['nearby_freelancers'] as List<dynamic>? ?? [];
    return (
      drivers: drivers.map((e) => RosterDriver.fromJson(e as Map<String, dynamic>)).toList(),
      nearbyFreelancers: nearby.map((e) => NearbyFreelancer.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Off duty / on duty for one of the business's own linked drivers — never
  /// a hard delete, so history stays attributable (see the backend's own
  /// doc comment on this endpoint).
  Future<void> setDriverActive(int driverId, bool isActive) =>
      _client.patch('/business/delivery-drivers/$driverId', data: {'is_active': isActive});

  /// The merchant hands the order directly to one of its own drivers.
  Future<void> assignDriver({required int orderId, required int driverId, int? businessId}) =>
      _client.post('/business/orders/$orderId/assign-driver', data: {'driver_id': driverId, 'business_id': ?businessId});

  // ─────────────────────────── Pickup / delivery QR ────────────────────────

  /// The business (or, in principle, the driver — but the assignment screen
  /// is where this is actually called from) issues the pickup QR's token.
  Future<String> issuePickupToken(int orderId, {int? businessId}) async {
    final path = '/business/orders/$orderId/pickup-token${businessId == null ? '' : '?business_id=$businessId'}';
    final data = await _client.post(path) as Map<String, dynamic>;
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

  /// The assigned driver tells the customer roughly when to expect the
  /// order — exactly one of [etaMinutes] (from right now) or [etaAt] (a
  /// specific clock time), never both.
  Future<void> notifyEta(int orderId, {int? etaMinutes, DateTime? etaAt}) => _client.post(
    '/delivery/orders/$orderId/eta',
    data: {'eta_minutes': ?etaMinutes, 'eta_at': ?etaAt?.toIso8601String()},
  );

  /// The assigned driver confirms they collected the delivery_fee in cash
  /// from the customer — their own leg only, refused before the order
  /// actually reaches the delivered stage.
  Future<void> confirmPaymentReceived(int orderId) => _client.post('/delivery/orders/$orderId/confirm-payment');

  /// The business's own flat delivery fee, added to the customer's invoice
  /// automatically at checkout on delivery orders. Null = free delivery.
  Future<double?> businessDeliveryFee() async {
    final data = await _client.get('/business/delivery-settings') as Map<String, dynamic>;
    return (data['delivery_fee_amount'] as num?)?.toDouble();
  }

  Future<double?> setBusinessDeliveryFee(double? amount) async {
    final data =
        await _client.patch('/business/delivery-settings', data: {'delivery_fee_amount': amount}) as Map<String, dynamic>;
    return (data['delivery_fee_amount'] as num?)?.toDouble();
  }

  /// A driver's own flat rate - only a fallback when the business never set
  /// one, never overrides a fee already charged at checkout.
  Future<double?> setOwnDeliveryFee(double? amount) async {
    final data =
        await _client.patch('/delivery/delivery-fee', data: {'delivery_fee_amount': amount}) as Map<String, dynamic>;
    return (data['delivery_fee_amount'] as num?)?.toDouble();
  }

  /// A driver accepting an unassigned order from the open pool (existing,
  /// pre-assignment path — kept here so the driver dashboard can offer it
  /// alongside "my active orders" if the driver isn't privately linked).
  Future<void> acceptOrder(int orderId) => _client.post('/delivery/orders/$orderId/accept');

  Future<List<Map<String, dynamic>>> availableOrders() async {
    final data = await _client.get('/delivery/available-orders') as Map<String, dynamic>;
    final orders = data['orders'] as List<dynamic>? ?? [];
    return orders.cast<Map<String, dynamic>>();
  }
}
