/// «العروض والخصومات» — mirrors Api\V2\PromotionController / PromotionService::serialize().
library;

class PromotionKind {
  static const percent = 'percent';
  static const amount = 'amount';
  static const nForPriceOf = 'n_for_price_of';
  static const spendPercent = 'spend_percent';
}

class PromotionTargetType {
  static const all = 'all';
  static const menuSection = 'menu_section';
  static const menuItem = 'menu_item';
  static const listing = 'listing';
  static const listingCategory = 'listing_category';
}

/// One thing a promotion covers: the whole shop, a section, an item…
class PromotionTarget {
  final String type;
  final int? id;
  final String name;

  const PromotionTarget({required this.type, this.id, this.name = ''});

  factory PromotionTarget.fromJson(Map<String, dynamic> json) => PromotionTarget(
    type: json['type'] as String? ?? '',
    id: (json['id'] as num?)?.toInt(),
    name: json['name'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'type': type, if (id != null) 'id': id};
}

/// An item a promotion covers, with the price of one piece after it when the rule can say that.
class PromotionItem {
  final String type;
  final int id;
  final String name;
  final double price;
  final double? priceAfter;

  const PromotionItem({required this.type, required this.id, required this.name, required this.price, this.priceAfter});

  factory PromotionItem.fromJson(Map<String, dynamic> json) => PromotionItem(
    type: json['type'] as String? ?? '',
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    priceAfter: (json['price_after'] as num?)?.toDouble(),
  );
}

class Promotion {
  final int id;
  final String? title;
  final String kind;
  final Map<String, dynamic> params;
  final String audience;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? maxUses;
  final int usedCount;
  final int? remainingUses;
  final bool isActive;
  final bool isRunning;
  final List<PromotionTarget> targets;
  final List<PromotionItem> items;

  const Promotion({
    required this.id,
    this.title,
    required this.kind,
    required this.params,
    this.audience = 'all',
    this.startsAt,
    this.endsAt,
    this.maxUses,
    this.usedCount = 0,
    this.remainingUses,
    this.isActive = true,
    this.isRunning = false,
    this.targets = const [],
    this.items = const [],
  });

  bool get forNewCustomers => audience == 'new_customers';

  double param(String key) => (params[key] as num?)?.toDouble() ?? 0;

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String?,
    kind: json['kind'] as String? ?? '',
    params: Map<String, dynamic>.from(json['params'] as Map? ?? const {}),
    audience: json['audience'] as String? ?? 'all',
    startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String)?.toLocal() : null,
    endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String)?.toLocal() : null,
    maxUses: (json['max_uses'] as num?)?.toInt(),
    usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
    remainingUses: (json['remaining_uses'] as num?)?.toInt(),
    isActive: json['is_active'] as bool? ?? true,
    isRunning: json['is_running'] as bool? ?? false,
    targets: [for (final t in (json['targets'] as List<dynamic>? ?? const [])) PromotionTarget.fromJson(t as Map<String, dynamic>)],
    items: [for (final i in (json['items'] as List<dynamic>? ?? const [])) PromotionItem.fromJson(i as Map<String, dynamic>)],
  );
}

/// The best single-piece offer on an item (`offer` on a menu row) — for the badge on its card.
class ItemOffer {
  final int promotionId;
  final String kind;
  final Map<String, dynamic> params;
  final double? priceAfter;

  const ItemOffer({required this.promotionId, required this.kind, required this.params, this.priceAfter});

  double param(String key) => (params[key] as num?)?.toDouble() ?? 0;

  static ItemOffer? fromJsonOrNull(Object? json) => json is Map<String, dynamic>
      ? ItemOffer(
          promotionId: (json['promotion_id'] as num).toInt(),
          kind: json['kind'] as String? ?? '',
          params: Map<String, dynamic>.from(json['params'] as Map? ?? const {}),
          priceAfter: (json['price_after'] as num?)?.toDouble(),
        )
      : null;
}

/// A product the merchant can point a promotion at.
class CatalogItem {
  final String type;
  final int id;
  final String name;
  final double price;

  const CatalogItem({required this.type, required this.id, required this.name, required this.price});

  factory CatalogItem.fromJson(Map<String, dynamic> json) => CatalogItem(
    type: json['type'] as String? ?? '',
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );
}

/// A section (or product category) with its products. [type] is null for the products filed under no section.
class CatalogGroup {
  final String? type;
  final int? id;
  final String? name;
  final List<CatalogItem> items;

  const CatalogGroup({this.type, this.id, this.name, required this.items});

  bool get isSection => type != null && id != null;

  factory CatalogGroup.fromJson(Map<String, dynamic> json) => CatalogGroup(
    type: json['type'] as String?,
    id: (json['id'] as num?)?.toInt(),
    name: json['name'] as String?,
    items: [for (final i in (json['items'] as List<dynamic>? ?? const [])) CatalogItem.fromJson(i as Map<String, dynamic>)],
  );
}

class PromotionCatalog {
  final List<CatalogGroup> menu;
  final List<CatalogGroup> shop;

  const PromotionCatalog({this.menu = const [], this.shop = const []});

  factory PromotionCatalog.fromJson(Map<String, dynamic> json) => PromotionCatalog(
    menu: [for (final g in (json['menu'] as List<dynamic>? ?? const [])) CatalogGroup.fromJson(g as Map<String, dynamic>)],
    shop: [for (final g in (json['shop'] as List<dynamic>? ?? const [])) CatalogGroup.fromJson(g as Map<String, dynamic>)],
  );

  List<CatalogGroup> get groups => [...menu, ...shop];
}
