import 'price_row.dart';

class PriceItemType {
  final String key;
  final String? label;

  const PriceItemType({required this.key, this.label});

  factory PriceItemType.fromJson(Map<String, dynamic> json) {
    return PriceItemType(
      key: json['key'] as String? ?? '',
      label: json['label'] as String?,
    );
  }
}

class PriceServiceOption {
  final int id;
  final String? key;
  final String? name;
  final List<PriceItemType> itemTypes;

  const PriceServiceOption({required this.id, this.key, this.name, this.itemTypes = const []});

  factory PriceServiceOption.fromJson(Map<String, dynamic> json) {
    return PriceServiceOption(
      id: (json['id'] as num).toInt(),
      key: json['key'] as String?,
      name: json['name'] as String?,
      itemTypes: (json['item_types'] as List<dynamic>? ?? [])
          .map((e) => PriceItemType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PriceVocabGroup {
  final String group;
  final List<PriceVocabOption> options;

  const PriceVocabGroup({required this.group, this.options = const []});

  factory PriceVocabGroup.fromJson(Map<String, dynamic> json) {
    return PriceVocabGroup(
      group: json['group'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => PriceVocabOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// GET /business/prices/options — everything the create/edit form needs,
/// already narrowed to what THIS merchant may say (see
/// MerchantOfferingVocabulary on the backend).
class PriceOptions {
  final List<String> chargeModes;
  final List<PriceServiceOption> services;
  final List<PriceVocabGroup> lines;
  final List<PriceVocabGroup> modifiers;

  const PriceOptions({
    this.chargeModes = const [],
    this.services = const [],
    this.lines = const [],
    this.modifiers = const [],
  });

  factory PriceOptions.fromJson(Map<String, dynamic> json) {
    return PriceOptions(
      chargeModes: (json['charge_modes'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => PriceServiceOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((e) => PriceVocabGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifiers: (json['modifiers'] as List<dynamic>? ?? [])
          .map((e) => PriceVocabGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
