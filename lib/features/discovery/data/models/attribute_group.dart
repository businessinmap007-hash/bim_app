/// One filterable option, and how many businesses under this child actually
/// carry it — see Api\V2\DiscoveryController::attributes. An option nobody
/// has ticked never reaches this model at all (the backend drops it), so
/// there is no `businesses == 0` case to guard against here.
class AttributeOption {
  final int id;
  final String name;
  final int businesses;

  const AttributeOption({required this.id, required this.name, required this.businesses});

  factory AttributeOption.fromJson(Map<String, dynamic> json) => AttributeOption(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    businesses: (json['businesses'] as num?)?.toInt() ?? 0,
  );
}

class AttributeGroup {
  final int? id;
  final String name;
  final List<AttributeOption> options;

  const AttributeGroup({required this.id, required this.name, required this.options});

  factory AttributeGroup.fromJson(Map<String, dynamic> json) => AttributeGroup(
    id: json['id'] as int?,
    name: json['name'] as String? ?? '',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => AttributeOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
