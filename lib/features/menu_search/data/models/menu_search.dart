import '../../../../core/env/env.dart';
import '../../../business_menu/data/models/menu_item_image.dart';
import '../../../business_menu/data/models/menu_vocabulary.dart';
import '../../../business/data/models/menu_item_summary.dart' show MenuItemSpec;

/// One detail kind a customer can search — «سيارات»، «كمبيوتر ولاب توب»… —
/// with only the fields that are filters for it. See
/// Api\V2\MenuItemSearchController::kinds().
class SearchKind {
  final String code;
  final String name;
  final int count;
  final List<DetailField> fields;
  const SearchKind({required this.code, required this.name, required this.count, required this.fields});

  factory SearchKind.fromJson(Map<String, dynamic> json) => SearchKind(
    code: json['code'] as String,
    name: json['name'] as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
    fields: (json['fields'] as List<dynamic>? ?? [])
        .map((e) => DetailField.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class SearchShop {
  final int id;
  final String name;
  final String? logo;
  const SearchShop({required this.id, required this.name, this.logo});

  factory SearchShop.fromJson(Map<String, dynamic> json) => SearchShop(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    logo: Env.assetUrl(json['logo'] as String?),
  );
}

/// One unit on sale at one shop.
class SearchItem {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;

  /// Which part of the photo the card shows — the merchant's crop (the whole photo by default).
  final PhotoCrop imageCrop;
  final int? catalogProductId;
  final int? availableQuantity;
  final List<MenuItemSpec> specs;
  /// The kind's one-line summary («2021 · 42500 كم · أوتوماتيك»).
  final String? summary;
  final SearchShop shop;
  const SearchItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.imageCrop = PhotoCrop.whole,
    this.catalogProductId,
    this.availableQuantity,
    this.specs = const [],
    this.summary,
    required this.shop,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) => SearchItem(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    imageUrl: Env.assetUrl(json['image'] as String?),
    imageCrop: PhotoCrop.fromJson(json['image_crop']),
    catalogProductId: (json['catalog_product_id'] as num?)?.toInt(),
    availableQuantity: (json['available_quantity'] as num?)?.toInt(),
    specs: (json['specs'] as List<dynamic>? ?? [])
        .map((e) => MenuItemSpec.fromJson(e as Map<String, dynamic>))
        .toList(),
    summary: json['summary'] as String?,
    shop: SearchShop.fromJson(json['business'] as Map<String, dynamic>),
  );
}

/// What the matching units offer on one field: a number's range, or a
/// choice's options with how many units carry each.
class SearchFacet {
  final String type;
  final double? min;
  final double? max;
  final List<({int id, String name, int count})> options;
  const SearchFacet({required this.type, this.min, this.max, this.options = const []});

  factory SearchFacet.fromJson(Map<String, dynamic> json) => SearchFacet(
    type: json['type'] as String? ?? '',
    min: (json['min'] as num?)?.toDouble(),
    max: (json['max'] as num?)?.toDouble(),
    options: [
      for (final o in (json['options'] as List<dynamic>? ?? []))
        (
          id: ((o as Map<String, dynamic>)['id'] as num).toInt(),
          name: o['name'] as String? ?? '',
          count: (o['count'] as num?)?.toInt() ?? 0,
        ),
    ],
  );
}

class SearchPage {
  final List<SearchItem> items;
  final Map<String, SearchFacet> facets;
  final int page;
  final int lastPage;
  final int total;
  const SearchPage({
    required this.items,
    required this.facets,
    required this.page,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => page < lastPage;

  factory SearchPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final facets = json['facets'];
    return SearchPage(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SearchItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      // An empty facet list arrives as [] (PHP), not {}.
      facets: facets is Map<String, dynamic>
          ? {for (final e in facets.entries) e.key: SearchFacet.fromJson(e.value as Map<String, dynamic>)}
          : const {},
      page: (meta['page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
      total: (meta['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// The filters a customer has set, keyed the way the endpoint reads them:
/// a figure's bounds (`code_min`/`code_max`), a choice's option ids
/// (`code` → ids), words (`code` → text).
class SearchFilters {
  final Map<String, String> bounds;
  final Map<String, Set<int>> choices;
  final Map<String, String> words;
  const SearchFilters({this.bounds = const {}, this.choices = const {}, this.words = const {}});

  int get count =>
      bounds.values.where((v) => v.isNotEmpty).length +
      choices.values.where((v) => v.isNotEmpty).length +
      words.values.where((v) => v.isNotEmpty).length;

  bool get isEmpty => count == 0;

  Map<String, String> toQuery() => {
    for (final e in bounds.entries)
      if (e.value.isNotEmpty) e.key: e.value,
    for (final e in choices.entries)
      if (e.value.isNotEmpty) e.key: e.value.join(','),
    for (final e in words.entries)
      if (e.value.isNotEmpty) e.key: e.value,
  };
}
