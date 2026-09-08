import 'menu_item_image.dart';
import 'menu_variant.dart';

/// One option row as it comes back attached to an item or listed in the
/// merchant's vocabulary — {id, name_ar, name_en} everywhere it appears.
class VocabularyOptionRef {
  final int id;
  final String nameAr;
  final String? nameEn;
  const VocabularyOptionRef({required this.id, required this.nameAr, this.nameEn});

  factory VocabularyOptionRef.fromJson(Map<String, dynamic> json) => VocabularyOptionRef(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
  );
}

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
  /// null = priced by the item. Set means the price is "per" this unit
  /// (كجم، لتر...) — see Api\V2\BusinessMenuItemController::saleUnits().
  final String? saleUnit;
  final String? saleUnitLabel;
  final String? brandName;
  final int? availableQuantity;
  final int sortOrder;
  final bool isActive;
  /// What this item IS — a `line` option (e.g. "ثلاجات") from the merchant's
  /// own vocabulary. Null for a hand-typed item (a restaurant's dish).
  final VocabularyOptionRef? lineOption;
  /// What qualifies it — brand, condition... any number, from `modifier`
  /// groups in the merchant's vocabulary.
  final List<VocabularyOptionRef> modifierOptions;
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
    this.saleUnit,
    this.saleUnitLabel,
    this.brandName,
    this.availableQuantity,
    required this.sortOrder,
    required this.isActive,
    this.lineOption,
    this.modifierOptions = const [],
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
    saleUnit: json['sale_unit'] as String?,
    saleUnitLabel: json['sale_unit_label'] as String?,
    brandName: json['brand_name'] as String?,
    availableQuantity: json['available_quantity'] as int?,
    sortOrder: json['sort_order'] as int,
    isActive: json['is_active'] as bool,
    lineOption: json['line_option'] != null
        ? VocabularyOptionRef.fromJson(json['line_option'] as Map<String, dynamic>)
        : null,
    modifierOptions: (json['modifier_options'] as List<dynamic>?)
            ?.map((e) => VocabularyOptionRef.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
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
