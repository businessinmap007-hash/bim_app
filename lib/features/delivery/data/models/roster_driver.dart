/// One row on the business's own delivery-driver roster — see
/// Api\V2\DeliveryController::roster() / DeliveryDispatchService::businessRoster().
/// `distanceKm` is the driver's live distance from the business right now,
/// independent of whether they're already carrying something; null means no
/// fresh location on either side to compare.
class RosterDriver {
  final int id;
  final int userId;
  final String? name;
  final String? phone;
  final String? vehicleLabel;
  final bool isActive;
  final bool busy;
  final int activeOrderCount;
  final int deliveredToday;
  final int deliveredCount;
  final int fastDeliveryCount;
  final bool locationAvailable;
  final double? distanceKm;

  const RosterDriver({
    required this.id,
    required this.userId,
    this.name,
    this.phone,
    this.vehicleLabel,
    required this.isActive,
    required this.busy,
    required this.activeOrderCount,
    required this.deliveredToday,
    required this.deliveredCount,
    required this.fastDeliveryCount,
    required this.locationAvailable,
    this.distanceKm,
  });

  factory RosterDriver.fromJson(Map<String, dynamic> json) => RosterDriver(
    id: json['id'] as int,
    userId: json['user_id'] as int,
    name: json['name'] as String?,
    phone: json['phone'] as String?,
    vehicleLabel: json['vehicle_label'] as String?,
    isActive: json['is_active'] as bool? ?? false,
    busy: json['busy'] as bool? ?? false,
    activeOrderCount: (json['active_order_count'] as num?)?.toInt() ?? 0,
    deliveredToday: (json['delivered_today'] as num?)?.toInt() ?? 0,
    deliveredCount: (json['delivered_count'] as num?)?.toInt() ?? 0,
    fastDeliveryCount: (json['fast_delivery_count'] as num?)?.toInt() ?? 0,
    locationAvailable: json['location_available'] as bool? ?? false,
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
  );
}

/// The signed-in user's own driver status — see DeliveryController::register/availability.
class DriverStatus {
  final int driverId;
  final bool isActive;
  final int assignedCount;
  final int pickedUpCount;
  final int deliveredCount;
  final int fastDeliveryCount;
  final double? deliveryFeeAmount;

  const DriverStatus({
    required this.driverId,
    required this.isActive,
    required this.assignedCount,
    required this.pickedUpCount,
    required this.deliveredCount,
    required this.fastDeliveryCount,
    this.deliveryFeeAmount,
  });

  factory DriverStatus.fromJson(Map<String, dynamic> json) => DriverStatus(
    driverId: json['driver_id'] as int,
    isActive: json['is_active'] as bool? ?? false,
    assignedCount: (json['assigned_count'] as num?)?.toInt() ?? 0,
    pickedUpCount: (json['picked_up_count'] as num?)?.toInt() ?? 0,
    deliveredCount: (json['delivered_count'] as num?)?.toInt() ?? 0,
    fastDeliveryCount: (json['fast_delivery_count'] as num?)?.toInt() ?? 0,
    deliveryFeeAmount: (json['delivery_fee_amount'] as num?)?.toDouble(),
  );
}
