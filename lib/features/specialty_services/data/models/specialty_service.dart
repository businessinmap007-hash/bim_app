/// The kinds of dental service a clinic lists, in the order a patient reads them.
const specialtyKinds = [
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
  'injectables',
  'face_lifting',
  'laser',
  'scars',
  'peels',
  'skin_disease',
  'hair',
  'body',
];

/// A service a dental clinic offers, as a patient sees it. [price] null means «السعر بعد الكشف».
class ServiceOffering {
  final int id;
  final String name;
  final double? price;

  const ServiceOffering({required this.id, required this.name, this.price});

  factory ServiceOffering.fromJson(Map<String, dynamic> json) => ServiceOffering(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
  );
}

class ServiceOfferingSection {
  final String kind;
  final List<ServiceOffering> services;

  const ServiceOfferingSection({required this.kind, this.services = const []});

  factory ServiceOfferingSection.fromJson(Map<String, dynamic> json) => ServiceOfferingSection(
    kind: json['kind'] as String? ?? 'checkup',
    services: (json['services'] as List<dynamic>? ?? [])
        .map((e) => ServiceOffering.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// One row of the clinic's own catalogue: a platform service or the clinic's own, with what it offers now.
class ServiceCatalogEntry {
  final int id;
  final String name;
  final bool own;
  final bool offered;
  final double? price;

  const ServiceCatalogEntry({required this.id, required this.name, this.own = false, this.offered = false, this.price});

  factory ServiceCatalogEntry.fromJson(Map<String, dynamic> json) => ServiceCatalogEntry(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    own: json['own'] as bool? ?? false,
    offered: json['offered'] as bool? ?? false,
    price: (json['price'] as num?)?.toDouble(),
  );
}

class ServiceCatalogSection {
  final String kind;
  final List<ServiceCatalogEntry> entries;

  const ServiceCatalogSection({required this.kind, this.entries = const []});

  factory ServiceCatalogSection.fromJson(Map<String, dynamic> json) => ServiceCatalogSection(
    kind: json['kind'] as String? ?? 'checkup',
    entries: (json['services'] as List<dynamic>? ?? [])
        .map((e) => ServiceCatalogEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
