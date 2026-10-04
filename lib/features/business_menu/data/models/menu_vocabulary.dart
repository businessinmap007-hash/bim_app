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
  /// For a DESCRIPTIVE group, as «مكونات الخدمة» set it for this trade: how it is
  /// drawn ('auto' | 'chips' | 'dropdown'), one choice or several, and its place
  /// among the other descriptive groups. Nothing here comes from the menu kind.
  final String display;
  final bool multiple;
  final int descriptiveSort;

  /// What kind of product this group sells («أنواع التفاصيل»): the type decides the units and whether
  /// payment plans («كاش / أقساط») exist — only for phones and computers, cars and furniture.
  final bool allowsPaymentPlans;
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
    this.display = 'auto',
    this.multiple = true,
    this.descriptiveSort = 0,
    this.allowsPaymentPlans = false,
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
    display: json['display'] as String? ?? 'auto',
    multiple: json['multiple'] as bool? ?? true,
    descriptiveSort: (json['descriptive_sort'] as num?)?.toInt() ?? 0,
    allowsPaymentPlans: (json['detail_type'] as Map<String, dynamic>?)?['allows_payment_plans'] as bool? ?? false,
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
  const DetailProfile({
    required this.code,
    required this.name,
    required this.fields,
    this.usesCatalog = true,
  });

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
  /// How a list field is drawn, as the admin set it in «أشكال المنيو»:
  /// 'chips' (buttons) | 'dropdown' | 'auto' (buttons up to [DetailDisplay.autoChipsMax]).
  final String display;
  const DetailField({
    required this.id,
    required this.code,
    required this.name,
    this.unit,
    this.showOnCard = false,
    this.perItem = false,
    this.dataType = 'text',
    this.options = const [],
    this.display = 'auto',
  });

  factory DetailField.fromJson(Map<String, dynamic> json) => DetailField(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String? ?? '',
    unit: json['unit'] as String?,
    showOnCard: json['show_on_card'] as bool? ?? false,
    perItem: json['per_item'] as bool? ?? false,
    dataType: json['data_type'] as String? ?? 'text',
    display: json['display'] as String? ?? 'auto',
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
/// A group «مكونات الخدمة» made a PRICE AXIS for the trade («الدفع والسداد»: كاش،
/// تقسيط): the merchant gives each option he offers its own price, the customer
/// picks one on the product page. Not a modifier — «كاش» is a business-level word.
class PriceAxis {
  final int groupId;
  final String groupName;
  final List<VocabularyOptionRef> options;
  const PriceAxis({required this.groupId, required this.groupName, required this.options});

  factory PriceAxis.fromJson(Map<String, dynamic> json) => PriceAxis(
    groupId: (json['group_id'] as num).toInt(),
    groupName: json['group_name'] as String? ?? '',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => VocabularyOptionRef.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class MenuVocabulary {
  final List<VocabularyGroup> lines;
  final List<VocabularyGroup> modifiers;
  final List<PriceAxis> priceAxes;
  const MenuVocabulary({required this.lines, required this.modifiers, this.priceAxes = const []});

  /// The one price axis the item form draws (the first, in the trade's order) —
  /// a second axis would make the customer's pick ambiguous.
  PriceAxis? get priceAxis => priceAxes.where((a) => a.options.isNotEmpty).firstOrNull;

  factory MenuVocabulary.fromJson(Map<String, dynamic> json) => MenuVocabulary(
    lines: (json['lines'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    modifiers: (json['modifiers'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    priceAxes: (json['price_axes'] as List<dynamic>? ?? [])
        .map((e) => PriceAxis.fromJson(e as Map<String, dynamic>))
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

/// The one rule that turns the admin's «العرض» choice into a widget: buttons
/// (everything in view, one tap) or a dropdown (compact, for many options).
abstract final class DetailDisplay {
  /// «auto» draws buttons up to this many options, a dropdown beyond.
  static const autoChipsMax = 6;

  static bool asChips(String display, int optionCount) =>
      display == 'chips' || (display == 'auto' && optionCount <= autoChipsMax);
}
