/// Mirrors `BookingController::form()` — what this business's booking
/// screen must ask, in what order, and which of it is required. The app
/// knows nothing about hotels or clinics; it draws whatever this says.
class BookingFormField {
  final String key;
  final String label;
  final bool required;

  const BookingFormField({required this.key, required this.label, required this.required});

  factory BookingFormField.fromJson(Map<String, dynamic> json) => BookingFormField(
    key: json['key'] as String? ?? '',
    label: json['label'] as String? ?? '',
    required: json['required'] as bool? ?? false,
  );
}

class BookingShape {
  final String pattern;
  final String patternLabel;
  final List<String> availablePatterns;
  final String unit; // 'always' | 'optional' | 'never'
  final List<BookingFormField> fields;
  final int? slotMinutes;
  final int? minNights;
  final int? leadTimeMinutes;
  final String visitMode; // 'at_business' | 'at_customer' | 'both'
  final List<String> channels;
  final String notesLabel;

  const BookingShape({
    required this.pattern,
    required this.patternLabel,
    required this.availablePatterns,
    required this.unit,
    required this.fields,
    this.slotMinutes,
    this.minNights,
    this.leadTimeMinutes,
    required this.visitMode,
    required this.channels,
    required this.notesLabel,
  });

  bool get needsUnit => unit == 'always';

  factory BookingShape.fromJson(Map<String, dynamic> json) => BookingShape(
    pattern: json['pattern'] as String? ?? '',
    patternLabel: json['pattern_label'] as String? ?? '',
    availablePatterns: (json['available_patterns'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    unit: json['unit'] as String? ?? 'never',
    fields: (json['fields'] as List<dynamic>? ?? [])
        .map((e) => BookingFormField.fromJson(e as Map<String, dynamic>))
        .toList(),
    slotMinutes: json['slot_minutes'] as int?,
    minNights: json['min_nights'] as int?,
    leadTimeMinutes: json['lead_time_minutes'] as int?,
    visitMode: json['visit_mode'] as String? ?? 'at_business',
    channels: (json['channels'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    notesLabel: json['notes_label'] as String? ?? '',
  );
}

class BookableUnitOption {
  final int id;
  final String title;
  final String? code;
  final String? itemType;
  final int? capacity;
  final int? quantity;

  const BookableUnitOption({
    required this.id,
    required this.title,
    this.code,
    this.itemType,
    this.capacity,
    this.quantity,
  });

  /// `/bookings/form/{business}` shape — every active unit, unscoped.
  factory BookableUnitOption.fromFormJson(Map<String, dynamic> json) => BookableUnitOption(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    code: json['code'] as String?,
    itemType: json['item_type'] as String?,
    capacity: json['capacity'] as int?,
    quantity: json['quantity'] as int?,
  );

  /// `/discovery/offerings/{business}` shape — already scoped to the one
  /// priced line the customer tapped (see `OfferingItem.units`).
  factory BookableUnitOption.fromOfferingJson(Map<String, dynamic> json) => BookableUnitOption(
    id: json['id'] as int,
    title: (json['label'] as String?) ?? (json['code'] as String?) ?? '',
    code: json['code'] as String?,
    capacity: json['capacity'] as int?,
  );
}

/// A priced modifier this business already sells («شاشة كبيرة +٢٠»),
/// grouped by the line it applies to and by its own taxonomy group —
/// `groupId`/`selectionType` say whether the group is a single (radio) or
/// multiple (checkbox) pick, same concept as a menu item's extra groups.
class BookingModifier {
  static const selectionSingle = 'single';

  final int priceId;
  final String? line;
  final int optionId;
  final String name;
  final int? groupId;
  final String? groupName;
  final String selectionType;
  final String adjustType; // 'amount' | 'percent'
  final double adjustValue;

  const BookingModifier({
    required this.priceId,
    this.line,
    required this.optionId,
    required this.name,
    this.groupId,
    this.groupName,
    required this.selectionType,
    required this.adjustType,
    required this.adjustValue,
  });

  bool get isSingleSelect => selectionType == selectionSingle;

  factory BookingModifier.fromJson(Map<String, dynamic> json) => BookingModifier(
    priceId: json['price_id'] as int? ?? 0,
    line: json['line'] as String?,
    optionId: json['option_id'] as int,
    name: json['name'] as String? ?? '',
    groupId: json['group_id'] as int?,
    groupName: json['group_name'] as String?,
    selectionType: json['selection_type'] as String? ?? 'multiple',
    adjustType: json['adjust_type'] as String? ?? 'amount',
    adjustValue: (json['adjust_value'] as num?)?.toDouble() ?? 0,
  );
}

class BookingFormPayload {
  final int businessId;
  final BookingShape? shape;
  final List<BookableUnitOption> units;
  final List<BookingModifier> modifiers;

  const BookingFormPayload({
    required this.businessId,
    this.shape,
    required this.units,
    required this.modifiers,
  });

  factory BookingFormPayload.fromJson(Map<String, dynamic> json) => BookingFormPayload(
    businessId: json['business_id'] as int,
    shape: json['shape'] != null ? BookingShape.fromJson(json['shape'] as Map<String, dynamic>) : null,
    units: (json['units'] as List<dynamic>? ?? [])
        .map((e) => BookableUnitOption.fromFormJson(e as Map<String, dynamic>))
        .toList(),
    modifiers: (json['modifiers'] as List<dynamic>? ?? [])
        .map((e) => BookingModifier.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
