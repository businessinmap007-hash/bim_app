import '../../../../core/env/env.dart';

class MenuItemVariant {
  final int id;
  final String name;
  final double price;
  final bool isDefault;

  const MenuItemVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.isDefault,
  });

  factory MenuItemVariant.fromJson(Map<String, dynamic> json) => MenuItemVariant(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    isDefault: json['is_default'] as bool? ?? false,
  );
}

/// A group of extras deciding how they're picked — see
/// MenuDiscoveryController's `extra_groups`.
class MenuItemExtraGroup {
  static const selectionSingle = 'single';

  final int id;
  final String name;
  final String selectionType;

  const MenuItemExtraGroup({required this.id, required this.name, required this.selectionType});

  bool get isSingle => selectionType == selectionSingle;

  factory MenuItemExtraGroup.fromJson(Map<String, dynamic> json) => MenuItemExtraGroup(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    selectionType: json['selection_type'] as String? ?? 'multiple',
  );
}

/// The branch an item sits under within its section — e.g. "ثلاجات" inside
/// "أنواع الأجهزة الكهربائية" — see MenuDiscoveryController::itemPayload().
class MenuItemBranch {
  final int id;
  final String nameAr;
  final String? nameEn;
  const MenuItemBranch({required this.id, required this.nameAr, this.nameEn});

  factory MenuItemBranch.fromJson(Map<String, dynamic> json) => MenuItemBranch(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
  );
}

class MenuItemExtra {
  final int id;
  final String name;
  final double price;
  final int? extraGroupId;

  const MenuItemExtra({required this.id, required this.name, required this.price, this.extraGroupId});

  factory MenuItemExtra.fromJson(Map<String, dynamic> json) => MenuItemExtra(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    extraGroupId: json['extra_group_id'] as int?,
  );
}

/// Mirrors `MenuDiscoveryController::itemPayload()` — one item in a
/// business's menu. Add-to-cart is a later module; this is the read-only
/// browse shape.
class MenuItemSummary {
  final int id;
  /// 'menu' | 'bundle' — see MenuDiscoveryController's `itemPayload`/
  /// `bundlePayload`. Decides which cart "kind" add-to-cart sends.
  final String kind;
  final String name;
  final String description;
  final String? offeringLabel;
  final String? imageUrl;
  final List<String> imageUrls;
  final double basePrice;
  final String? saleUnitLabel;
  final int? availableQuantity;
  final bool isFeatured;
  final MenuItemBranch? lineOption;
  final List<MenuItemVariant> variants;
  final List<MenuItemExtraGroup> extraGroups;
  final List<MenuItemExtra> extras;

  const MenuItemSummary({
    required this.id,
    this.kind = 'menu',
    required this.name,
    required this.description,
    this.offeringLabel,
    this.imageUrl,
    required this.imageUrls,
    required this.basePrice,
    this.saleUnitLabel,
    this.availableQuantity,
    this.isFeatured = false,
    this.lineOption,
    required this.variants,
    this.extraGroups = const [],
    required this.extras,
  });

  /// `null` = not tracked (always orderable); `0` = tracked and out of stock.
  bool get isOutOfStock => availableQuantity == 0;

  /// Whether picking this item needs a choice at all — decides the card's
  /// contextual action (a direct add vs. one that opens the picker first).
  bool get hasChoices => variants.isNotEmpty || extras.isNotEmpty;

  /// The lowest variant price, when there's more than one size/price to
  /// choose from — the card shows "From X" instead of a single price.
  double? get startingPrice =>
      variants.isEmpty ? null : variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);

  factory MenuItemSummary.fromJson(Map<String, dynamic> json) => MenuItemSummary(
    id: json['id'] as int,
    kind: json['kind'] as String? ?? 'menu',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    offeringLabel: json['offering_label'] as String?,
    imageUrl: Env.assetUrl(json['image'] as String?),
    imageUrls: (json['images'] as List<dynamic>? ?? [])
        .map((e) => Env.assetUrl((e as Map<String, dynamic>)['image'] as String?))
        .whereType<String>()
        .toList(),
    basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
    saleUnitLabel: json['sale_unit_label'] as String?,
    availableQuantity: (json['available_quantity'] as num?)?.toInt(),
    isFeatured: json['is_featured'] as bool? ?? false,
    lineOption: json['line_option'] != null
        ? MenuItemBranch.fromJson(json['line_option'] as Map<String, dynamic>)
        : null,
    variants: (json['variants'] as List<dynamic>? ?? [])
        .map((e) => MenuItemVariant.fromJson(e as Map<String, dynamic>))
        .toList(),
    extraGroups: (json['extra_groups'] as List<dynamic>? ?? [])
        .map((e) => MenuItemExtraGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    extras: (json['extras'] as List<dynamic>? ?? [])
        .map((e) => MenuItemExtra.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
