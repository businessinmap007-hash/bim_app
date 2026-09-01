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

class MenuItemExtra {
  final int id;
  final String name;
  final double price;

  const MenuItemExtra({required this.id, required this.name, required this.price});

  factory MenuItemExtra.fromJson(Map<String, dynamic> json) => MenuItemExtra(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );
}

/// Mirrors `MenuDiscoveryController::itemPayload()` — one item in a
/// business's menu. Add-to-cart is a later module; this is the read-only
/// browse shape.
class MenuItemSummary {
  final int id;
  final String name;
  final String description;
  final String? offeringLabel;
  final String? imageUrl;
  final List<String> imageUrls;
  final double basePrice;
  final String? saleUnitLabel;
  final int? availableQuantity;
  final List<MenuItemVariant> variants;
  final List<MenuItemExtra> extras;

  const MenuItemSummary({
    required this.id,
    required this.name,
    required this.description,
    this.offeringLabel,
    this.imageUrl,
    required this.imageUrls,
    required this.basePrice,
    this.saleUnitLabel,
    this.availableQuantity,
    required this.variants,
    required this.extras,
  });

  /// `null` = not tracked (always orderable); `0` = tracked and out of stock.
  bool get isOutOfStock => availableQuantity == 0;

  factory MenuItemSummary.fromJson(Map<String, dynamic> json) => MenuItemSummary(
    id: json['id'] as int,
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
    variants: (json['variants'] as List<dynamic>? ?? [])
        .map((e) => MenuItemVariant.fromJson(e as Map<String, dynamic>))
        .toList(),
    extras: (json['extras'] as List<dynamic>? ?? [])
        .map((e) => MenuItemExtra.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
