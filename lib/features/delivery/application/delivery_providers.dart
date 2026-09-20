import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/providers/core_providers.dart';
import '../../orders/data/models/placed_order.dart';
import '../data/delivery_api.dart';
import '../data/models/roster_driver.dart';

final deliveryApiProvider = Provider<DeliveryApi>((ref) {
  return DeliveryApi(ref.watch(apiClientProvider));
});

/// The business's own roster for the "choose who delivers this" screen —
/// autoDispose since it's only ever open for the duration of an assignment.
final businessRosterProvider = FutureProvider.autoDispose.family<List<RosterDriver>, int?>((ref, businessId) {
  return ref.watch(deliveryApiProvider).businessRoster(businessId: businessId);
});

/// The roster + nearby freelancers, for the standalone "My Drivers"
/// management screen (distinct lifecycle from the assignment picker above).
final businessRosterFullProvider = FutureProvider.autoDispose<BusinessRoster>((ref) {
  return ref.watch(deliveryApiProvider).businessRosterFull();
});

/// Ready-to-take delivery orders open to this driver (a freelance driver
/// sees the whole pool, a business's own driver only that business's).
final availableDeliveryOrdersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  double? lat;
  double? lng;
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 8)),
      );
      lat = position.latitude;
      lng = position.longitude;
    }
  } catch (_) {
    // No position -> the list simply comes without distances.
  }
  return ref.watch(deliveryApiProvider).availableOrders(lat: lat, lng: lng);
});

/// A linked (business-team) driver's own status, shown under "أعمالي".
final myLinkedDriverProvider = FutureProvider.autoDispose<DriverStatus?>((ref) {
  return ref.watch(deliveryApiProvider).me();
});

/// The signed-in driver's own active deliveries.
final myDeliveriesProvider = FutureProvider.autoDispose<List<PlacedOrder>>((ref) {
  return ref.watch(deliveryApiProvider).myOrders();
});

class DriverAvailabilityState {
  final DriverStatus? status;
  final bool isLoading;
  final String? error;

  const DriverAvailabilityState({this.status, this.isLoading = false, this.error});

  DriverAvailabilityState copyWith({DriverStatus? status, bool? isLoading, String? error, bool clearError = false}) {
    return DriverAvailabilityState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Whether the signed-in user is a registered driver, and their on/off-duty
/// switch — a user with no `delivery_drivers` row yet reads as `status: null`
/// until they tap "become a driver" (register()), which the backend treats
/// as idempotent either way.
class DriverAvailabilityController extends StateNotifier<DriverAvailabilityState> {
  final DeliveryApi _api;
  DriverAvailabilityController(this._api) : super(const DriverAvailabilityState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final status = await _api.me();
      state = DriverAvailabilityState(status: status, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register({String? phone, String? vehicleLabel}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final status = await _api.register(phone: phone, vehicleLabel: vehicleLabel);
      state = state.copyWith(status: status, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setActive(bool active) async {
    final previous = state.status;
    if (previous == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final status = await _api.setAvailability(active);
      state = state.copyWith(status: status, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final driverAvailabilityControllerProvider =
    StateNotifierProvider<DriverAvailabilityController, DriverAvailabilityState>((ref) {
  return DriverAvailabilityController(ref.watch(deliveryApiProvider));
});
