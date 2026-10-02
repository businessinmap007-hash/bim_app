import 'menu_item.dart';

/// One option group as it appears in this merchant's own vocabulary — e.g.
/// "أنواع الأجهزة الكهربائية" (a `line` group, its options are the branches
/// like "ثلاجات") or "ماركات الأجهزة الكهربائية" (a `modifier` group).
class VocabularyGroup {
  final int groupId;
  final String groupName;
  final List<VocabularyOptionRef> options;
  /// True for a group like "ماركات الأجهزة الكهربائية" — a closed brand
  /// dictionary, singled out by the backend so the item form can give it
  /// its own dropdown instead of lumping it into the generic modifier chips.
  final bool isBrand;
  /// True for «حالة المنتج» (جديد/مستعمل) — singled out the same way
  /// [isBrand] is, so a form can give it its own single-select toggle
  /// instead of lumping it into generic modifier chips.
  final bool isCondition;
  /// null = every sale unit is fair game. Non-null (e.g. «أعشاب وورقيات»
  /// → bunch/kg/g) narrows a quick-price picker to just these codes —
  /// same restriction MenuMarketCatalogService already applies to «تعبئة
  /// الرفوف»'s own unit dropdown, mirrored here for this vocabulary.
  final List<String>? saleUnitCodes;
  /// True when «مكونات الخدمة» split this group's branches into their own
  /// storefront sections (`branches_as_sections`) — e.g. «موبايل»/«تابلت»
  /// each standalone instead of living under one «أجهزة الموبايل
  /// وملحقاتها» heading. A branch under a detailed group opens the
  /// catalog-linked "التسعير والتفاصيل" flow (product picker + real specs)
  /// instead of the plain quantity/price dialog, and — unlike an ordinary
  /// branch — may carry more than one priced item (several real models).
  /// See [[tech-spec-menu-implementation]].
  final bool detailed;
  /// Which «منيو تفصيلي» this group is (mobiles, laptops, cars…) and the
  /// fields that kind is described by — set per group in the admin's «أشكال
  /// المنيو». null = «منيو أساسي». Never decided in the app.
  final DetailProfile? detailProfile;
  /// True when the admin's «مكونات الخدمة» made this group DESCRIBE what the
  /// item is for this trade («مودرن»، «زان» on a bedroom) — it is offered as a
  /// choice on the item, never as a second thing the item IS.
  final bool descriptive;
  /// True when «مكونات الخدمة» → «فروع المجموعة أقسام» is ticked for this group:
  /// «غرفة نوم»، «سفرة»، «أنتريه» are the merchant's SECTIONS — each its own
  /// heading, its cards under it, «إضافة منتج» under those. The one switch that
  /// decides it; never guessed from the kind of menu.
  final bool branchesAsSections;
  const VocabularyGroup({
    required this.groupId,
    required this.groupName,
    required this.options,
    this.isBrand = false,
    this.isCondition = false,
    this.saleUnitCodes,
    this.detailed = false,
    this.detailProfile,
    this.descriptive = false,
    this.branchesAsSections = false,
  });

  factory VocabularyGroup.fromJson(Map<String, dynamic> json) => VocabularyGroup(
    groupId: json['group_id'] as int,
    groupName: json['group_name'] as String,
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => VocabularyOptionRef.fromJson(e as Map<String, dynamic>))
        .toList(),
    isBrand: json['is_brand'] as bool? ?? false,
    isCondition: json['is_condition'] as bool? ?? false,
    saleUnitCodes: (json['sale_unit_codes'] as List<dynamic>?)?.map((e) => e as String).toList(),
    detailed: json['detailed'] as bool? ?? false,
    descriptive: json['descriptive'] as bool? ?? false,
    branchesAsSections: json['branches_as_sections'] as bool? ?? false,
    detailProfile: json['detail_profile'] is Map<String, dynamic>
        ? DetailProfile.fromJson(json['detail_profile'] as Map<String, dynamic>)
        : null,
  );
}

/// One kind of «منيو تفصيلي» and its fields, in display order — what
/// «التسعير والتفاصيل» lists for the picked product. See
/// Api\V2\BusinessMenuItemController::detailProfilesFor().
class DetailProfile {
  final String code;
  final String name;
  final List<DetailField> fields;
  /// false = no catalog behind this kind (a bedroom has no «model» to pick):
  /// the merchant names the item himself and states every field. Set in the
  /// admin's «أشكال المنيو», never here.
  final bool usesCatalog;
  const DetailProfile({required this.code, required this.name, required this.fields, this.usesCatalog = true});

  factory DetailProfile.fromJson(Map<String, dynamic> json) => DetailProfile(
    code: json['code'] as String,
    name: json['name'] as String? ?? '',
    usesCatalog: json['uses_catalog'] as bool? ?? true,
    fields: (json['fields'] as List<dynamic>? ?? [])
        .map((e) => DetailField.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class DetailField {
  final int id;
  final String code;
  final String name;
  final String? unit;
  final bool showOnCard;
  /// The merchant states it for each unit (a car's year) instead of taking it
  /// from the catalog product.
  final bool perItem;
  /// 'number' | 'select' | 'text'.
  final String dataType;
  final List<DetailOption> options;
  const DetailField({
    required this.id,
    required this.code,
    required this.name,
    this.unit,
    this.showOnCard = false,
    this.perItem = false,
    this.dataType = 'text',
    this.options = const [],
  });

  factory DetailField.fromJson(Map<String, dynamic> json) => DetailField(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String? ?? '',
    unit: json['unit'] as String?,
    showOnCard: json['show_on_card'] as bool? ?? false,
    perItem: json['per_item'] as bool? ?? false,
    dataType: json['data_type'] as String? ?? 'text',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => DetailOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class DetailOption {
  final int id;
  final String name;
  const DetailOption({required this.id, required this.name});

  factory DetailOption.fromJson(Map<String, dynamic> json) =>
      DetailOption(id: json['id'] as int, name: json['name'] as String? ?? '');
}

/// GET /business/menu/vocabulary — what this merchant may say a catalog item
/// IS (`lines`, grouped into what becomes its menu section) and what may
/// qualify it (`modifiers` — brand, condition...), narrowed to this
/// business's own catalog. See Api\V2\BusinessMenuItemController::vocabulary().
class MenuVocabulary {
  final List<VocabularyGroup> lines;
  final List<VocabularyGroup> modifiers;
  const MenuVocabulary({required this.lines, required this.modifiers});

  factory MenuVocabulary.fromJson(Map<String, dynamic> json) => MenuVocabulary(
    lines: (json['lines'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    modifiers: (json['modifiers'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  bool get hasLines => lines.any((g) => g.options.isNotEmpty);

  /// The closed brand dictionary for this business's specialty, if it has
  /// one (e.g. appliance businesses see "ماركات الأجهزة الكهربائية"). Null
  /// for a business with no brand vocabulary — the item form falls back to
  /// a free-text brand field for those.
  VocabularyGroup? get brandGroup {
    for (final g in modifiers) {
      if (g.isBrand && g.options.isNotEmpty) return g;
    }
    return null;
  }

  /// «حالة المنتج» (جديد/مستعمل), when this business's specialty carries
  /// it — used by «التسعير والتفاصيل» for its single-select condition toggle.
  VocabularyGroup? get conditionGroup {
    for (final g in modifiers) {
      if (g.isCondition && g.options.isNotEmpty) return g;
    }
    return null;
  }
}
