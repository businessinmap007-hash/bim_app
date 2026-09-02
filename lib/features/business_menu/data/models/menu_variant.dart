/// One choice on a menu item (e.g. size) — see
/// Api\V2\BusinessMenuItemController::storeVariant / MenuItemResource.
class MenuVariant {
  final int id;
  final String type;
  final String nameAr;
  final String? nameEn;
  final double? price;
  final double? priceDelta;
  final bool isDefault;
  final bool isActive;

  const MenuVariant({
    required this.id,
    required this.type,
    required this.nameAr,
    this.nameEn,
    this.price,
    this.priceDelta,
    required this.isDefault,
    required this.isActive,
  });

  factory MenuVariant.fromJson(Map<String, dynamic> json) => MenuVariant(
    id: json['id'] as int,
    type: json['type'] as String,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    price: (json['price'] as num?)?.toDouble(),
    priceDelta: (json['price_delta'] as num?)?.toDouble(),
    isDefault: json['is_default'] as bool,
    isActive: json['is_active'] as bool,
  );
}

/// An optional add-on with its own price — see
/// Api\V2\BusinessMenuItemController::storeExtra / MenuItemResource.
class MenuExtra {
  final int id;
  final String? groupKey;
  final String nameAr;
  final String? nameEn;
  final double price;
  final int maxQty;
  final bool isActive;

  const MenuExtra({
    required this.id,
    this.groupKey,
    required this.nameAr,
    this.nameEn,
    required this.price,
    required this.maxQty,
    required this.isActive,
  });

  factory MenuExtra.fromJson(Map<String, dynamic> json) => MenuExtra(
    id: json['id'] as int,
    groupKey: json['group_key'] as String?,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    price: (json['price'] as num).toDouble(),
    maxQty: json['max_qty'] as int,
    isActive: json['is_active'] as bool,
  );
}
