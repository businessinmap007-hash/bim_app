/// One entry in the shared drug dictionary (25k+ rows). See
/// Api\V2\MedicineController.
class Medicine {
  final int id;
  final String name;
  final String? strength;
  final String? scientificName;
  final String? manufacturer;
  final String? drugClass;
  final String? route;
  final double? priceEgp;
  final String? priceCapturedAt;
  final int usesCount;

  const Medicine({
    required this.id,
    required this.name,
    this.strength,
    this.scientificName,
    this.manufacturer,
    this.drugClass,
    this.route,
    this.priceEgp,
    this.priceCapturedAt,
    this.usesCount = 0,
  });

  String get displayName => strength != null && strength!.isNotEmpty ? '$name — $strength' : name;

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    strength: json['strength'] as String?,
    scientificName: json['scientific_name'] as String?,
    manufacturer: json['manufacturer'] as String?,
    drugClass: json['drug_class'] as String?,
    route: json['route'] as String?,
    priceEgp: (json['price_egp'] as num?)?.toDouble(),
    priceCapturedAt: json['price_captured_at'] as String?,
    usesCount: (json['uses_count'] as num?)?.toInt() ?? 0,
  );
}
