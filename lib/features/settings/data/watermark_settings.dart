/// Persisted watermark preferences — configured once in Settings, then
/// applied automatically to every photo added afterward rather than
/// retyped per photo. Text comes from the signed-in profile, not free
/// input: [useMobile] and [useBusinessName] are independent switches, so
/// both (or neither) can be on at once.
class WatermarkSettings {
  final bool useMobile;
  final bool useBusinessName;
  final int repeatCount;

  const WatermarkSettings({
    this.useMobile = false,
    this.useBusinessName = false,
    this.repeatCount = 6,
  });

  bool get isEnabled => useMobile || useBusinessName;

  WatermarkSettings copyWith({bool? useMobile, bool? useBusinessName, int? repeatCount}) {
    return WatermarkSettings(
      useMobile: useMobile ?? this.useMobile,
      useBusinessName: useBusinessName ?? this.useBusinessName,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'useMobile': useMobile,
    'useBusinessName': useBusinessName,
    'repeatCount': repeatCount,
  };

  factory WatermarkSettings.fromJson(Map<String, dynamic> json) => WatermarkSettings(
    useMobile: json['useMobile'] as bool? ?? false,
    useBusinessName: json['useBusinessName'] as bool? ?? false,
    repeatCount: json['repeatCount'] as int? ?? 6,
  );
}
