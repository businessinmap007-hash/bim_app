import '../../../../core/env/env.dart';

/// One priced add-on offered alongside a kind of unit («إفطار +٥٠»).
class UnitChoice {
  final int optionId;
  final String? name;
  final String adjustType; // 'amount' | 'percent'
  final double adjustValue;
  final bool perPerson;
  final double amount;

  const UnitChoice({
    required this.optionId,
    this.name,
    required this.adjustType,
    required this.adjustValue,
    required this.perPerson,
    required this.amount,
  });

  factory UnitChoice.fromJson(Map<String, dynamic> json) => UnitChoice(
    optionId: (json['option_id'] as num).toInt(),
    name: json['name'] as String?,
    adjustType: json['adjust_type'] as String? ?? 'amount',
    adjustValue: (json['adjust_value'] as num?)?.toDouble() ?? 0,
    perPerson: json['per_person'] as bool? ?? false,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
  );
}

/// One bookable unit as returned by Api\V2\UnitDiscoveryController — a real
/// room/table/pitch, with its own image and (when a date window was asked
/// for) whether it is actually free for it.
class DiscoveredUnit {
  final int id;
  final String? code;
  final String? title;
  final String? label;
  final String? description;
  final int? capacity;
  final List<String> images;
  final double? price;
  final double? total;
  final int? periods;
  final String? periodUnit;
  final bool? available;
  final String? reason;

  const DiscoveredUnit({
    required this.id,
    this.code,
    this.title,
    this.label,
    this.description,
    this.capacity,
    this.images = const [],
    this.price,
    this.total,
    this.periods,
    this.periodUnit,
    this.available,
    this.reason,
  });

  String get displayTitle => (title != null && title!.isNotEmpty) ? title! : (label ?? code ?? '#$id');

  factory DiscoveredUnit.fromJson(Map<String, dynamic> json) => DiscoveredUnit(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String?,
    title: json['title'] as String?,
    label: json['label'] as String?,
    description: json['description'] as String?,
    capacity: (json['capacity'] as num?)?.toInt(),
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => Env.assetUrl((e as Map<String, dynamic>)['image'] as String?))
        .whereType<String>()
        .toList(),
    price: (json['price'] as num?)?.toDouble(),
    total: (json['total'] as num?)?.toDouble(),
    periods: (json['periods'] as num?)?.toInt(),
    periodUnit: json['period_unit'] as String?,
    available: json['available'] as bool?,
    reason: json['reason'] as String?,
  );
}

/// One kind of unit at a business («جناح», «غرفة مفردة») grouped by its line
/// option, with the price that kind sells at and every individual unit of
/// it.
class UnitKindGroup {
  final int? lineOptionId;
  final String? name;
  final String itemType;
  final int unitsCount;
  final int? availableCount;
  final double? price;
  final String? currency;
  final int? offeringId;
  final List<UnitChoice> choices;
  final List<DiscoveredUnit> units;

  const UnitKindGroup({
    this.lineOptionId,
    this.name,
    required this.itemType,
    required this.unitsCount,
    this.availableCount,
    this.price,
    this.currency,
    this.offeringId,
    this.choices = const [],
    this.units = const [],
  });

  factory UnitKindGroup.fromJson(Map<String, dynamic> json) => UnitKindGroup(
    lineOptionId: (json['line_option_id'] as num?)?.toInt(),
    name: json['name'] as String?,
    itemType: json['item_type'] as String? ?? '',
    unitsCount: (json['units_count'] as num?)?.toInt() ?? 0,
    availableCount: (json['available_count'] as num?)?.toInt(),
    price: (json['price'] as num?)?.toDouble(),
    currency: json['currency'] as String?,
    offeringId: (json['offering_id'] as num?)?.toInt(),
    choices: (json['choices'] as List<dynamic>? ?? [])
        .map((e) => UnitChoice.fromJson(e as Map<String, dynamic>))
        .toList(),
    units: (json['units'] as List<dynamic>? ?? [])
        .map((e) => DiscoveredUnit.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
