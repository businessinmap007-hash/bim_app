class PriceVocabOption {
  final int id;
  final String? name;

  const PriceVocabOption({required this.id, this.name});

  factory PriceVocabOption.fromJson(Map<String, dynamic> json) {
    return PriceVocabOption(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
    );
  }
}

class PriceModifierAdjust {
  final String type;
  final double value;

  const PriceModifierAdjust({required this.type, required this.value});

  factory PriceModifierAdjust.fromJson(Map<String, dynamic> json) {
    return PriceModifierAdjust(
      type: json['type'] as String? ?? 'amount',
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PriceServiceRef {
  final int id;
  final String? key;
  final String? name;

  const PriceServiceRef({required this.id, this.key, this.name});

  factory PriceServiceRef.fromJson(Map<String, dynamic> json) {
    return PriceServiceRef(
      id: (json['id'] as num).toInt(),
      key: json['key'] as String?,
      name: json['name'] as String?,
    );
  }
}

/// Api\V2\BusinessServicePriceResource — one (service, item type, line) row.
class PriceRow {
  final int id;
  final PriceServiceRef service;
  final String bookableItemType;
  final PriceVocabOption? lineOption;
  final List<PriceVocabOption> modifierOptions;
  final Map<int, PriceModifierAdjust> modifierAdjust;
  final String? label;
  final double price;
  final String chargeMode;
  final double chargeAmount;
  final int? durationMinutes;
  final String currency;
  final bool isActive;
  final bool discountEnabled;
  final int discountPercent;

  const PriceRow({
    required this.id,
    required this.service,
    required this.bookableItemType,
    this.lineOption,
    this.modifierOptions = const [],
    this.modifierAdjust = const {},
    this.label,
    required this.price,
    required this.chargeMode,
    required this.chargeAmount,
    this.durationMinutes,
    required this.currency,
    required this.isActive,
    required this.discountEnabled,
    required this.discountPercent,
  });

  factory PriceRow.fromJson(Map<String, dynamic> json) {
    return PriceRow(
      id: (json['id'] as num).toInt(),
      service: PriceServiceRef.fromJson(json['service'] as Map<String, dynamic>),
      bookableItemType: json['bookable_item_type'] as String? ?? '',
      lineOption: json['line_option'] != null
          ? PriceVocabOption.fromJson(json['line_option'] as Map<String, dynamic>)
          : null,
      modifierOptions: (json['modifier_options'] as List<dynamic>? ?? [])
          .map((e) => PriceVocabOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifierAdjust: (json['modifier_adjust'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(int.parse(key), PriceModifierAdjust.fromJson(value as Map<String, dynamic>)),
      ),
      label: json['label'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      chargeMode: json['charge_mode'] as String? ?? 'standard',
      chargeAmount: (json['charge_amount'] as num?)?.toDouble() ?? 0,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      currency: json['currency'] as String? ?? 'EGP',
      isActive: json['is_active'] as bool? ?? true,
      discountEnabled: json['discount_enabled'] as bool? ?? false,
      discountPercent: (json['discount_percent'] as num?)?.toInt() ?? 0,
    );
  }
}
