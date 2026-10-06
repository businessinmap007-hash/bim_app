/// Persisted watermark preferences — configured once in Settings, then
/// applied automatically to every photo added afterward rather than
/// retyped per photo. Text comes from the signed-in profile, not free
/// input: [useMobile] and [useBusinessName] are independent switches, so
/// both (or neither) can be on at once.
class WatermarkSettings {
  final bool useMobile;
  final bool useBusinessName;
  final int repeatCount;

  /// Stamp the watermark on PRODUCT photos too (the switch beside a product's photos) — remembered on this device.
  final bool onProducts;

  const WatermarkSettings({
    this.useMobile = false,
    this.useBusinessName = false,
    this.repeatCount = 6,
    this.onProducts = true,
  });

  bool get isEnabled => useMobile || useBusinessName;

  WatermarkSettings copyWith({bool? useMobile, bool? useBusinessName, int? repeatCount, bool? onProducts}) {
    return WatermarkSettings(
      useMobile: useMobile ?? this.useMobile,
      useBusinessName: useBusinessName ?? this.useBusinessName,
      repeatCount: repeatCount ?? this.repeatCount,
      onProducts: onProducts ?? this.onProducts,
    );
  }

  Map<String, dynamic> toJson() => {
    'useMobile': useMobile,
    'useBusinessName': useBusinessName,
    'repeatCount': repeatCount,
    'onProducts': onProducts,
  };

  factory WatermarkSettings.fromJson(Map<String, dynamic> json) => WatermarkSettings(
    useMobile: json['useMobile'] as bool? ?? false,
    useBusinessName: json['useBusinessName'] as bool? ?? false,
    repeatCount: json['repeatCount'] as int? ?? 6,
    onProducts: json['onProducts'] as bool? ?? true,
  );
}
