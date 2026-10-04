import '../../../../core/env/env.dart';
import 'menu_item_image.dart';
import 'menu_variant.dart';

/// One option row as it comes back attached to an item or listed in the
/// merchant's vocabulary — {id, name_ar, name_en} everywhere it appears.
class VocabularyOptionRef {
  final int id;
  final String nameAr;
  final String? nameEn;
  /// An instalment option of the payment group — the server says so.
  final bool isInstallment;
  const VocabularyOptionRef({required this.id, required this.nameAr, this.nameEn, this.isInstallment = false});

  factory VocabularyOptionRef.fromJson(Map<String, dynamic> json) => VocabularyOptionRef(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    isInstallment: json['is_installment'] as bool? ?? false,
  );
}

/// One row of a catalog product's spec table — {code, name, value}, already
/// localized and unit-formatted server-side. See ProductSpecs.php.
class CatalogSpecRow {
  final String code;
  final String name;
  final String value;
  const CatalogSpecRow({required this.code, required this.name, required this.value});

  factory CatalogSpecRow.fromJson(Map<String, dynamic> json) => CatalogSpecRow(
    code: json['code'] as String,
    name: json['name'] as String,
    value: json['value'] as String,
  );
}

/// A real catalog master (a real phone/laptop model…) a merchant may LINK a
/// menu item to instead of retyping its specs — see [[menu-catalog-specs-link]].
/// Carries its own spec table so the item form can preview it without a
/// second round trip, both from a catalog-lookup search result and from an
/// already-linked item.
class CatalogProductRef {
  final int id;
  final String name;
  final String? brand;
  final int? brandId;
  /// «Galaxy A», «Reno», «F»… — the family below the brand.
  final String? series;
  final String? image;
  /// Proposed by this business («الموديل مش موجود») and not reviewed yet.
  final bool pending;
  final List<CatalogSpecRow> specs;
  const CatalogProductRef({
    required this.id,
    required this.name,
    this.brand,
    this.brandId,
    this.series,
    this.image,
    this.pending = false,
    this.specs = const [],
  });

  factory CatalogProductRef.fromJson(Map<String, dynamic> json) => CatalogProductRef(
    id: json['id'] as int,
    name: json['name'] as String,
    brand: json['brand'] as String?,
    brandId: json['brand_id'] as int?,
    series: json['series'] as String?,
    image: Env.assetUrl(json['image'] as String?),
    pending: json['pending'] == true,
    specs: (json['specs'] as List<dynamic>?)
            ?.map((e) => CatalogSpecRow.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

/// One chip of the picker's brand/series rows — `id` is null for a series.
class CatalogFacet {
  final int? id;
  final String name;
  final int count;
  const CatalogFacet({this.id, required this.name, required this.count});

  factory CatalogFacet.fromJson(Map<String, dynamic> json) => CatalogFacet(
    id: json['id'] as int?,
    name: json['name'] as String,
    count: (json['count'] as int?) ?? 0,
  );
}

/// GET /business/menu/catalog-lookup — a page of products plus the brand and
/// (once a brand is picked) series chips counted inside the same branch.
class CatalogLookupResult {
  final List<CatalogProductRef> items;
  final List<CatalogFacet> brands;
  final List<CatalogFacet> series;
  const CatalogLookupResult({required this.items, this.brands = const [], this.series = const []});

  factory CatalogLookupResult.fromJson(Map<String, dynamic> data) {
    final facets = data['facets'] as Map<String, dynamic>? ?? const {};
    List<CatalogFacet> list(Object? raw) => (raw as List<dynamic>? ?? [])
        .map((e) => CatalogFacet.fromJson(e as Map<String, dynamic>))
        .toList();
    return CatalogLookupResult(
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => CatalogProductRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      brands: list(facets['brands']),
      series: list(facets['series']),
    );
  }
}

/// What the merchant stated for ONE unit — a car's year, mileage, gearbox,
/// colour (see MenuItemAttributes on the backend). `optionId` for a choice,
/// `number` for a figure, `text` for words.
class ItemAttributeValue {
  final int attributeId;
  final String code;
  final String value;
  final int? optionId;
  final double? number;
  final String? text;
  const ItemAttributeValue({
    required this.attributeId,
    required this.code,
    required this.value,
    this.optionId,
    this.number,
    this.text,
  });

  factory ItemAttributeValue.fromJson(Map<String, dynamic> json) => ItemAttributeValue(
    attributeId: json['attribute_id'] as int,
    code: json['code'] as String? ?? '',
    value: json['value'] as String? ?? '',
    optionId: json['option_id'] as int?,
    number: (json['number'] as num?)?.toDouble(),
    text: json['text'] as String?,
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
  /// The real catalog master this item prices, when the merchant linked
  /// one instead of typing specs by hand — see [[menu-catalog-specs-link]].
  final int? catalogProductId;
  final CatalogProductRef? catalogProduct;
  /// What this item IS — a `line` option (e.g. "ثلاجات") from the merchant's
  /// own vocabulary. Null for a hand-typed item (a restaurant's dish).
  final VocabularyOptionRef? lineOption;
  /// What qualifies it — brand, condition... any number, from `modifier`
  /// groups in the merchant's vocabulary.
  final List<VocabularyOptionRef> modifierOptions;
  /// The values this unit states itself — see [ItemAttributeValue].
  final List<ItemAttributeValue> attributes;
  final List<MenuItemImage> images;
  final List<MenuVariant> variants;

  /// «كاش أو أقساط» — what one unit costs on each instalment plan (cash is [basePrice]).
  final List<PaymentPlanRow> paymentPlans;

  /// The shop's services this merchant switches on per item («طريقة الطهي» on the grill, not on the salad).
  /// Empty when the shop carries its services on every item.
  final List<AddonChoice> addonChoices;
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
    this.catalogProductId,
    this.catalogProduct,
    this.lineOption,
    this.modifierOptions = const [],
    this.attributes = const [],
    this.images = const [],
    this.variants = const [],
    this.paymentPlans = const [],
    this.addonChoices = const [],
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
    catalogProductId: json['catalog_product_id'] as int?,
    catalogProduct: json['catalog_product'] != null
        ? CatalogProductRef.fromJson(json['catalog_product'] as Map<String, dynamic>)
        : null,
    lineOption: json['line_option'] != null
        ? VocabularyOptionRef.fromJson(json['line_option'] as Map<String, dynamic>)
        : null,
    modifierOptions: (json['modifier_options'] as List<dynamic>?)
            ?.map((e) => VocabularyOptionRef.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    attributes: (json['attributes'] as List<dynamic>?)
            ?.map((e) => ItemAttributeValue.fromJson(e as Map<String, dynamic>))
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
    paymentPlans: (json['payment_plans'] as List<dynamic>?)
            ?.map((e) => PaymentPlanRow.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    addonChoices: (json['addon_choices'] as List<dynamic>?)
            ?.map((e) => AddonChoice.fromJson(e as Map<String, dynamic>))
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

/// One instalment plan of an item as the merchant wrote it: [months], the [down] payment paid with the
/// first month, and what ONE unit costs in total on the plan ([totalPrice]).
class PaymentPlanRow {
  final int months;
  final double? down;
  final double totalPrice;
  const PaymentPlanRow({required this.months, this.down, required this.totalPrice});

  factory PaymentPlanRow.fromJson(Map<String, dynamic> json) => PaymentPlanRow(
    months: (json['months'] as num).toInt(),
    down: (json['down'] as num?)?.toDouble(),
    totalPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
  );
}

/// One of the shop's services an item may offer, and whether THIS item does.
class AddonChoice {
  final int groupId;
  final String name;
  final bool enabled;
  const AddonChoice({required this.groupId, required this.name, required this.enabled});

  factory AddonChoice.fromJson(Map<String, dynamic> json) => AddonChoice(
    groupId: (json['group_id'] as num).toInt(),
    name: json['group_name'] as String? ?? '',
    enabled: json['enabled'] as bool? ?? false,
  );
}

