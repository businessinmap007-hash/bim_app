import 'menu_item_image.dart';
import 'menu_variant.dart';

/// A business's own menu item — see Api\V2\BusinessMenuItemController /
/// MenuItemResource. `images`/`variants`/`extras` are only populated when
/// the backend eager-loads them (the list endpoint carries images only;
/// `show` carries all three).
class BusinessMenuItem {
  final int id;
  final String nameAr;
  final String? nameEn;
  final int? menuSectionId;
  final String? descriptionAr;
  final String? descriptionEn;
  final double basePrice;
  final double? supplyPrice;
  final String? brandName;
  final int? availableQuantity;
  final int sortOrder;
  final bool isActive;
  final List<MenuItemImage> images;
  final List<MenuVariant> variants;
  final List<MenuExtraGroup> extraGroups;
  final List<MenuExtra> extras;

  const BusinessMenuItem({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.menuSectionId,
    this.descriptionAr,
    this.descriptionEn,
    required this.basePrice,
    this.supplyPrice,
    this.brandName,
    this.availableQuantity,
    required this.sortOrder,
    required this.isActive,
    this.images = const [],
    this.variants = const [],
    this.extraGroups = const [],
    this.extras = const [],
  });

  factory BusinessMenuItem.fromJson(Map<String, dynamic> json) => BusinessMenuItem(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    menuSectionId: json['menu_section_id'] as int?,
    descriptionAr: json['description_ar'] as String?,
    descriptionEn: json['description_en'] as String?,
    basePrice: (json['base_price'] as num).toDouble(),
    supplyPrice: (json['supply_price'] as num?)?.toDouble(),
    brandName: json['brand_name'] as String?,
    availableQuantity: json['available_quantity'] as int?,
    sortOrder: json['sort_order'] as int,
    isActive: json['is_active'] as bool,
    images: (json['images'] as List<dynamic>?)
            ?.map((e) => MenuItemImage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    variants: (json['variants'] as List<dynamic>?)
            ?.map((e) => MenuVariant.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    extraGroups: (json['extra_groups'] as List<dynamic>?)
            ?.map((e) => MenuExtraGroup.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    extras: (json['extras'] as List<dynamic>?)
            ?.map((e) => MenuExtra.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}
