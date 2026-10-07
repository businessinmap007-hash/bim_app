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
/// «Day use» — the room type is also sold through the day: a window and a flat price.
class DayUseOffer {
  final String from;
  final String to;
  final double price;
  const DayUseOffer({required this.from, required this.to, required this.price});

  factory DayUseOffer.fromJson(Map<String, dynamic> json) => DayUseOffer(
    from: json['from'] as String? ?? '09:00',
    to: json['to'] as String? ?? '18:00',
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );
}

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

  /// null unless the hotel sells this room type through the day as well
  final DayUseOffer? dayUse;

  /// what this room carries that is already inside its price («إطلالة على المسبح») — the hotel ticked it on the room
  final List<String> features;

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
    this.dayUse,
    this.features = const [],
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
    dayUse: json['day_use'] is Map<String, dynamic> ? DayUseOffer.fromJson(json['day_use'] as Map<String, dynamic>) : null,
    features: (json['modifiers'] as List<dynamic>? ?? [])
        .map((e) => (e as Map<String, dynamic>)['name'] as String?)
        .whereType<String>()
        .where((n) => n.isNotEmpty)
        .toList(),
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

/// «شكل الحجز» — how this business's booking page is drawn, as the admin arranged it (`data.shape` of
/// `/discovery/units/{business}`; null for a trade nobody has put on a shape, which the app draws as it always did).
class UnitShape {
  final String code;
  final String name;
  final String pattern;
  final Map<String, dynamic> settings;

  const UnitShape({required this.code, required this.name, required this.pattern, this.settings = const {}});

  bool _flag(String key, bool fallback) => settings[key] is bool ? settings[key] as bool : fallback;

  /// rooms grouped under their kind, like the menu's sections — otherwise one flat list
  bool get sectioned => (settings['layout'] as String? ?? 'sections') == 'sections';
  bool get showPhotos => _flag('show_photos', true);
  bool get showPrice => _flag('show_price', true);
  bool get showCapacity => _flag('show_capacity', true);
  bool get showAvailability => _flag('show_availability', true);

  /// the unit first, then the add-ons, then the dates (the hotel's way) — or the dates first
  bool get unitFirst => (settings['pick_order'] as String? ?? 'unit_then_dates') == 'unit_then_dates';
  bool get askGuestCounts => _flag('ask_guest_counts', true);
  bool get askChildren => _flag('ask_children', true);
  bool get offerDayUse => _flag('offer_day_use', false);
  bool get pickProvider => _flag('pick_provider', false);
  bool get multiSelect => _flag('multi_select', false);
  bool get askAttachment => _flag('ask_attachment', false);
  bool get offerHomeService => _flag('offer_home_service', false);

  factory UnitShape.fromJson(Map<String, dynamic> json) => UnitShape(
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    pattern: json['pattern'] as String? ?? '',
    settings: (json['settings'] as Map<String, dynamic>?) ?? const {},
  );
}

/// Everything `/discovery/units/{business}` says: the kinds with their units, and the shape the page is drawn in.
class UnitCatalog {
  final int? serviceId;
  final List<UnitKindGroup> kinds;
  final UnitShape? shape;

  const UnitCatalog({this.serviceId, this.kinds = const [], this.shape});

  bool get hasUnits => kinds.any((k) => k.units.isNotEmpty);

  factory UnitCatalog.fromJson(Map<String, dynamic> json) => UnitCatalog(
    serviceId: (json['service_id'] as num?)?.toInt(),
    kinds: (json['kinds'] as List<dynamic>? ?? [])
        .map((e) => UnitKindGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    shape: json['shape'] is Map<String, dynamic> ? UnitShape.fromJson(json['shape'] as Map<String, dynamic>) : null,
  );
}
