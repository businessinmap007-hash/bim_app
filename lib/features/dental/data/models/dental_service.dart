/// The kinds of dental service a clinic lists, in the order a patient reads them.
const dentalKinds = [
  'checkup',
  'preventive',
  'restorative',
  'endodontic',
  'periodontal',
  'surgical',
  'prosthetic',
  'orthodontic',
  'cosmetic',
  'pediatric',
];

/// A service a dental clinic offers, as a patient sees it. [price] null means «السعر بعد الكشف».
class DentalOffering {
  final int id;
  final String name;
  final double? price;

  const DentalOffering({required this.id, required this.name, this.price});

  factory DentalOffering.fromJson(Map<String, dynamic> json) => DentalOffering(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
  );
}

class DentalOfferingSection {
  final String kind;
  final List<DentalOffering> services;

  const DentalOfferingSection({required this.kind, this.services = const []});

  factory DentalOfferingSection.fromJson(Map<String, dynamic> json) => DentalOfferingSection(
    kind: json['kind'] as String? ?? 'checkup',
    services: (json['services'] as List<dynamic>? ?? [])
        .map((e) => DentalOffering.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// One row of the clinic's own catalogue: a platform service or the clinic's own, with what it offers now.
class DentalCatalogEntry {
  final int id;
  final String name;
  final bool own;
  final bool offered;
  final double? price;

  const DentalCatalogEntry({required this.id, required this.name, this.own = false, this.offered = false, this.price});

  factory DentalCatalogEntry.fromJson(Map<String, dynamic> json) => DentalCatalogEntry(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    own: json['own'] as bool? ?? false,
    offered: json['offered'] as bool? ?? false,
    price: (json['price'] as num?)?.toDouble(),
  );
}

class DentalCatalogSection {
  final String kind;
  final List<DentalCatalogEntry> entries;

  const DentalCatalogSection({required this.kind, this.entries = const []});

  factory DentalCatalogSection.fromJson(Map<String, dynamic> json) => DentalCatalogSection(
    kind: json['kind'] as String? ?? 'checkup',
    entries: (json['services'] as List<dynamic>? ?? [])
        .map((e) => DentalCatalogEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
