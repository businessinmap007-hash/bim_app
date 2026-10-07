/// «إضافات الحجز» — one option the hotel prices once for the whole business: a meal plan the guest may add, or a
/// feature a room carries (a pool view).
class AddOnOption {
  final int id;
  final String name;
  final bool enabled;
  final double value;
  final bool perPerson;

  const AddOnOption({required this.id, required this.name, this.enabled = false, this.value = 0, this.perPerson = false});

  AddOnOption copyWith({bool? enabled, double? value, bool? perPerson}) =>
      AddOnOption(id: id, name: name, enabled: enabled ?? this.enabled, value: value ?? this.value, perPerson: perPerson ?? this.perPerson);

  factory AddOnOption.fromJson(Map<String, dynamic> json) => AddOnOption(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    enabled: json['enabled'] as bool? ?? false,
    value: (json['value'] as num?)?.toDouble() ?? 0,
    perPerson: json['per_person'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'option_id': id, 'enabled': enabled, 'value': value, 'adjust_type': 'amount', 'per_person': perPerson};
}

class AddOnGroup {
  final int groupId;
  final String name;

  /// `single` (radio) or `multiple` — add-ons only; features carry no choice.
  final String? selectionType;
  final List<AddOnOption> options;

  /// 'night' (added to each night) or 'day_use' (the meals of a Day use, added to the day's price)
  final String appliesTo;

  const AddOnGroup({
    required this.groupId,
    required this.name,
    this.selectionType,
    this.options = const [],
    this.appliesTo = 'night',
  });

  bool get isDayUse => appliesTo == 'day_use';

  bool get isSingle => selectionType == 'single';

  AddOnGroup copyWith({String? selectionType, List<AddOnOption>? options}) =>
      AddOnGroup(
        groupId: groupId,
        name: name,
        selectionType: selectionType ?? this.selectionType,
        options: options ?? this.options,
        appliesTo: appliesTo,
      );

  factory AddOnGroup.fromJson(Map<String, dynamic> json) => AddOnGroup(
    groupId: json['group_id'] as int? ?? 0,
    name: json['group'] as String? ?? '',
    selectionType: json['selection_type'] as String?,
    appliesTo: json['applies_to'] as String? ?? 'night',
    options: (json['options'] as List<dynamic>? ?? []).map((e) => AddOnOption.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class BookingAddOns {
  final List<AddOnGroup> addOns;
  final List<AddOnGroup> features;
  const BookingAddOns({this.addOns = const [], this.features = const []});

  factory BookingAddOns.fromJson(Map<String, dynamic> json) => BookingAddOns(
    addOns: (json['add_ons'] as List<dynamic>? ?? []).map((e) => AddOnGroup.fromJson(e as Map<String, dynamic>)).toList(),
    features: (json['features'] as List<dynamic>? ?? []).map((e) => AddOnGroup.fromJson(e as Map<String, dynamic>)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'add_ons': [for (final g in addOns) for (final o in g.options) o.toJson()],
    'features': [for (final g in features) for (final o in g.options) o.toJson()],
    'selection_types': {for (final g in addOns) if (g.selectionType != null) '${g.groupId}': g.selectionType},
  };
}

/// A feature a room carries (or may carry) with the price the hotel wrote for it.
class UnitFeature {
  final int id;
  final String name;
  final bool selected;
  final double? price;
  const UnitFeature({required this.id, required this.name, this.selected = false, this.price});

  factory UnitFeature.fromJson(Map<String, dynamic> json) => UnitFeature(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    selected: json['selected'] as bool? ?? false,
    price: (json['price'] as num?)?.toDouble(),
  );
}

List<UnitFeature> parseUnitFeatures(Map<String, dynamic> json) => [
  for (final g in json['features'] as List<dynamic>? ?? [])
    for (final o in (g as Map<String, dynamic>)['options'] as List<dynamic>? ?? []) UnitFeature.fromJson(o as Map<String, dynamic>),
];
