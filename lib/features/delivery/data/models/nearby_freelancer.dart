/// A freelance driver (not on this business's own roster) currently nearby
/// — visibility only. See DeliveryDispatchService::nearbyFreelanceDrivers():
/// a business can never assign one directly, they self-select from the open
/// job board, so this is purely "is anyone actually around right now".
class NearbyFreelancer {
  final int userId;
  final String? name;
  final String? vehicleLabel;
  final double distanceKm;

  const NearbyFreelancer({
    required this.userId,
    this.name,
    this.vehicleLabel,
    required this.distanceKm,
  });

  factory NearbyFreelancer.fromJson(Map<String, dynamic> json) => NearbyFreelancer(
    userId: json['user_id'] as int,
    name: json['name'] as String?,
    vehicleLabel: json['vehicle_label'] as String?,
    distanceKm: (json['distance_km'] as num).toDouble(),
  );
}
