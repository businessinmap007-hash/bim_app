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

/// A group of extras that decides how they're picked — one at a time
/// (radio, e.g. «المقاس») or any number (checkbox, e.g. «الصوصات»). See
/// Api\V2\BusinessMenuItemController::storeExtraGroup / MenuItemResource.
class MenuExtraGroup {
  static const selectionSingle = 'single';
  static const selectionMultiple = 'multiple';

  final int id;
  final String nameAr;
  final String? nameEn;
  final String selectionType;
  final bool isActive;

  const MenuExtraGroup({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.selectionType,
    required this.isActive,
  });

  bool get isSingle => selectionType == selectionSingle;

  factory MenuExtraGroup.fromJson(Map<String, dynamic> json) => MenuExtraGroup(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    selectionType: json['selection_type'] as String? ?? selectionMultiple,
    isActive: json['is_active'] as bool,
  );
}

/// An optional add-on with its own price — see
/// Api\V2\BusinessMenuItemController::storeExtra / MenuItemResource.
class MenuExtra {
  final int id;
  final int? extraGroupId;
  final String nameAr;
  final String? nameEn;
  final double price;
  final int maxQty;
  final bool isActive;

  const MenuExtra({
    required this.id,
    this.extraGroupId,
    required this.nameAr,
    this.nameEn,
    required this.price,
    required this.maxQty,
    required this.isActive,
  });

  factory MenuExtra.fromJson(Map<String, dynamic> json) => MenuExtra(
    id: json['id'] as int,
    extraGroupId: json['extra_group_id'] as int?,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    price: (json['price'] as num).toDouble(),
    maxQty: json['max_qty'] as int,
    isActive: json['is_active'] as bool,
  );
}
