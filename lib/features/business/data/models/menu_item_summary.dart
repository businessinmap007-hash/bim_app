import '../../../../core/env/env.dart';

class MenuItemVariant {
  final int id;
  final String name;
  final double price;
  final bool isDefault;
  /// 'payment' for «كاش» / «تقسيط» prices — the picker is then «اختر طريقة الدفع».
  final String type;
  /// An instalment price says over how many months it runs.
  final int? installmentMonths;
  /// The down payment (per unit), paid with the first month.
  final double? installmentDown;

  const MenuItemVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.isDefault,
    this.type = '',
    this.installmentMonths,
    this.installmentDown,
  });

  factory MenuItemVariant.fromJson(Map<String, dynamic> json) => MenuItemVariant(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    isDefault: json['is_default'] as bool? ?? false,
    type: json['type'] as String? ?? '',
    installmentMonths: (json['installment_months'] as num?)?.toInt(),
    installmentDown: (json['installment_down'] as num?)?.toDouble(),
  );
}

/// One way of paying an item on instalments («كاش» is the item's own price and has no row): over
/// [months] months, [down] paid with the first one (per unit), at [markupPercent] over the cash price.
/// See `payment_plans` in MenuDiscoveryController::itemPayload().
class MenuItemPaymentPlan {
  final int id;
  final int months;
  final double? down;
  final double markupPercent;

  const MenuItemPaymentPlan({required this.id, required this.months, this.down, required this.markupPercent});

  factory MenuItemPaymentPlan.fromJson(Map<String, dynamic> json) => MenuItemPaymentPlan(
    id: (json['id'] as num).toInt(),
    months: (json['months'] as num).toInt(),
    down: (json['down'] as num?)?.toDouble(),
    markupPercent: (json['markup_percent'] as num?)?.toDouble() ?? 0,
  );

  /// What ONE unit costs on this plan, given what it costs in cash.
  double unitPrice(double cash) => (cash * (1 + markupPercent / 100) * 100).round() / 100;

  /// The regular month, per unit: what is left after the down payment, over the months.
  double monthly(double cash) => (unitPrice(cash) - (down ?? 0)) / months;
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

  /// The app's own language first, the other name if that one is blank —
  /// same rule as the backend's OptionGroup::displayName()/User::displayName().
  String displayName(bool isEnglish) {
    final primary = isEnglish ? nameEn : nameAr;
    if (primary != null && primary.isNotEmpty) return primary;
    final secondary = isEnglish ? nameAr : nameEn;
    return secondary ?? '';
  }
}

/// One row of a linked catalog master's spec table (processor, RAM…) — see
/// MenuDiscoveryController::itemPayload()'s `specs`, populated only when the
/// merchant pointed this item at a real `catalog_products` row (a device
/// model, a laptop…). Empty for every item that wasn't.
class MenuItemSpec {
  final String code;
  final String name;
  final String value;

  const MenuItemSpec({required this.code, required this.name, required this.value});

  factory MenuItemSpec.fromJson(Map<String, dynamic> json) => MenuItemSpec(
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    value: json['value'] as String? ?? '',
  );
}

/// «جديد»/«مستعمل» — the item's own «حالة المنتج» modifier, when the
/// merchant set one. See MenuDiscoveryController::itemPayload()'s
/// `condition`. Null for an item with no condition modifier at all.
class MenuItemCondition {
  final int id;
  final String name;
  const MenuItemCondition({required this.id, required this.name});

  factory MenuItemCondition.fromJson(Map<String, dynamic> json) =>
      MenuItemCondition(id: json['id'] as int, name: json['name'] as String? ?? '');
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
  /// The licence credit of a catalog photo shown in place of the merchant's
  /// own (CC BY-SA asks for it) — null for the merchant's own photo.
  final String? imageCredit;
  final List<String> imageUrls;
  /// The gallery photos that are live camera shots (`source: camera`) —
  /// badged with the camera icon wherever they show.
  final Set<String> cameraImageUrls;
  final double basePrice;
  final String? saleUnitLabel;
  final int? availableQuantity;
  final bool isFeatured;
  final MenuItemCondition? condition;
  final MenuItemBranch? lineOption;
  final List<MenuItemVariant> variants;

  /// «كاش أو أقساط» — only for the kinds that sell on instalments; empty = cash only.
  final List<MenuItemPaymentPlan> paymentPlans;
  final List<MenuItemExtraGroup> extraGroups;
  final List<MenuItemExtra> extras;
  final List<MenuItemSpec> specs;
  /// The maker, when known — for a catalog-linked item this comes from the
  /// real product's own `catalog_brands` row automatically (never a
  /// separate «ماركات الموبايلات»/«ماركات السيارات» pick), for a hand-typed
  /// item it's whatever the merchant typed. See
  /// [[tech-spec-menu-implementation]].
  final String? brandName;
  /// The catalog master's own brand and series («سامسونج» · «Galaxy A») —
  /// what the storefront's brand → series chips filter a section by. Null for
  /// an item with no catalog master.
  final String? catalogBrand;
  final String? series;
  /// The card's one line from the fields this item's detail kind puts on the
  /// card («2021 · 42500 كم · أوتوماتيك»), in the admin's order — null under a
  /// basic menu, where [specSummary] falls back to the first few specs.
  final String? cardSummary;

  const MenuItemSummary({
    required this.id,
    this.kind = 'menu',
    required this.name,
    required this.description,
    this.offeringLabel,
    this.imageUrl,
    this.imageCredit,
    required this.imageUrls,
    this.cameraImageUrls = const {},
    required this.basePrice,
    this.saleUnitLabel,
    this.availableQuantity,
    this.isFeatured = false,
    this.condition,
    this.lineOption,
    required this.variants,
    this.paymentPlans = const [],
    this.extraGroups = const [],
    required this.extras,
    this.specs = const [],
    this.brandName,
    this.catalogBrand,
    this.series,
    this.cardSummary,
  });

  /// The brand a filter chip groups this item under — the catalog's own
  /// brand when linked, else whatever the merchant typed.
  String? get filterBrand {
    final b = (catalogBrand ?? brandName)?.trim();
    return b == null || b.isEmpty ? null : b;
  }

  /// The card's compact spec line — "Core i5 · 8GB RAM · 256GB SSD" — the
  /// first three specs joined, matching the Tech Catalog Setup canvas's
  /// storefront card. Brand is shown via [brandName] instead, so it's
  /// skipped here to avoid repeating it.
  String? get specSummary {
    final card = cardSummary;
    if (card != null && card.isNotEmpty) {
      return card.split(' · ').map((v) => '\u2068$v\u2069').join(' · ');
    }
    final rows = specs.where((s) => s.code != 'brand').take(3).map((s) => s.value).where((v) => v.isNotEmpty);
    // Each value is a bidi isolate (FSI…PDI): «8 جيجا» beside «256GB» and
    // «Apple A17 Pro» otherwise reorders into «8 · جيجا 256GB» in RTL.
    return rows.isEmpty ? null : rows.map((v) => '\u2068$v\u2069').join(' · ');
  }

  /// `null` = not tracked (always orderable); `0` = tracked and out of stock.
  bool get isOutOfStock => availableQuantity == 0;

  /// Whether picking this item needs a choice at all — decides the card's
  /// contextual action (a direct add vs. one that opens the picker first).
  /// A catalog-linked item (real specs) always counts as one even with no
  /// variants/extras of its own — a real device deserves its full detail
  /// page (see TechProductDetailScreen), never a bare quantity stepper.
  bool get hasChoices => variants.isNotEmpty || paymentPlans.isNotEmpty || extras.isNotEmpty || specs.isNotEmpty;

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
    imageCredit: json['image_credit'] as String?,
    imageUrls: (json['images'] as List<dynamic>? ?? [])
        .map((e) => Env.assetUrl((e as Map<String, dynamic>)['image'] as String?))
        .whereType<String>()
        .toList(),
    cameraImageUrls: (json['images'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .where((e) => e['source'] == 'camera')
        .map((e) => Env.assetUrl(e['image'] as String?))
        .whereType<String>()
        .toSet(),
    basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
    saleUnitLabel: json['sale_unit_label'] as String?,
    availableQuantity: (json['available_quantity'] as num?)?.toInt(),
    isFeatured: json['is_featured'] as bool? ?? false,
    condition: json['condition'] != null
        ? MenuItemCondition.fromJson(json['condition'] as Map<String, dynamic>)
        : null,
    lineOption: json['line_option'] != null
        ? MenuItemBranch.fromJson(json['line_option'] as Map<String, dynamic>)
        : null,
    variants: (json['variants'] as List<dynamic>? ?? [])
        .map((e) => MenuItemVariant.fromJson(e as Map<String, dynamic>))
        .toList(),
    paymentPlans: (json['payment_plans'] as List<dynamic>? ?? [])
        .map((e) => MenuItemPaymentPlan.fromJson(e as Map<String, dynamic>))
        .toList(),
    extraGroups: (json['extra_groups'] as List<dynamic>? ?? [])
        .map((e) => MenuItemExtraGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    extras: (json['extras'] as List<dynamic>? ?? [])
        .map((e) => MenuItemExtra.fromJson(e as Map<String, dynamic>))
        .toList(),
    specs: (json['specs'] as List<dynamic>? ?? [])
        .map((e) => MenuItemSpec.fromJson(e as Map<String, dynamic>))
        .toList(),
    brandName: json['brand_name'] as String?,
    cardSummary: json['card_summary'] as String?,
    catalogBrand: json['catalog_brand'] as String?,
    series: json['series'] as String?,
  );
}
