/// One row from GET /discovery/service-types — the platform's own service
/// vocabulary (booking/menu/delivery/retail/schedules/training), read-only
/// and unscoped by specialty. See Api\V2\PlatformService.
class PlatformServiceType {
  final int id;
  final String key;
  final String name;

  const PlatformServiceType({required this.id, required this.key, required this.name});

  factory PlatformServiceType.fromJson(Map<String, dynamic> json) => PlatformServiceType(
    id: json['id'] as int,
    key: json['key'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );
}
