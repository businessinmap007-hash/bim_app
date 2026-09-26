import '../../../../core/env/env.dart';

/// One named entry in a restricted listing's audience — a business, a shop
/// type (category child), or a whole root category — resolved server-side
/// to a display name so the edit screen never has to look ids up itself.
class RetailAudienceEntry {
  final int id;
  final String name;
  const RetailAudienceEntry({required this.id, required this.name});

  factory RetailAudienceEntry.fromJson(Map<String, dynamic> json) =>
      RetailAudienceEntry(id: json['id'] as int, name: json['name'] as String? ?? '');
}

/// A business's own priced listing over the shared catalog master — see
/// Api\V2\BusinessRetailListingController / BusinessRetailListingResource.
///
/// `visibility` is `public` (the shelf — everyone) or `restricted` (a
/// wholesale price/quantity only its named audience may even see exists).
/// The audience is named three ways — specific businesses, a whole shop
/// type, or a whole root category — but this app's own listing form only
/// offers the first two; [audienceCategoryIds] is carried through
/// unedited on save so a root-category audience set some other way (the
/// admin panel, historically) is never silently dropped by an app save
/// that never mentions it.
/// One editable add-on row of a listing (warranty, installation…).
class ListingExtraDraft {
  int id;
  String name;
  String price;
  String group;
  bool single;
  ListingExtraDraft({this.id = 0, this.name = '', this.price = '', this.group = '', this.single = false});

  factory ListingExtraDraft.fromJson(Map<String, dynamic> j) => ListingExtraDraft(
    id: (j['id'] as num).toInt(),
    name: j['name_ar'] as String? ?? '',
    price: ((j['price'] as num?) ?? 0).toString(),
    group: j['group_name_ar'] as String? ?? '',
    single: j['selection_type'] == 'single',
  );

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'name_ar': name.trim(),
    'price': double.tryParse(price.trim()) ?? 0,
    'group_name_ar': group.trim(),
    'selection_type': single ? 'single' : 'multiple',
  };
}

/// A condition (جديد/مستعمل/…) or payment (كاش/تقسيط) choice on a priced row.
class RetailVariantOption {
  final int id;
  final String name;
  const RetailVariantOption({required this.id, required this.name});

  static RetailVariantOption? maybe(dynamic json) => json is Map<String, dynamic>
      ? RetailVariantOption(id: (json['id'] as num).toInt(), name: json['name'] as String? ?? '')
      : null;
}

class RetailListing {
  final int id;
  final double price;
  final String currency;
  final int? stock;
  final int? minOrderQty;
  final int? maxOrderQty;
  final String? unit;
  final String? sku;
  final bool isActive;
  final String visibility;
  final List<RetailAudienceEntry> audienceBusinesses;
  final List<RetailAudienceEntry> audienceChildren;
  final List<int> audienceCategoryIds;
  // Sits ABOVE visibility/audience — a geographic narrowing checked against
  // the VIEWER's own governorate, whoever they are. Empty means every
  // governorate; see RetailListingVisibility on the backend.
  final List<int> governorateIds;
  final List<RetailAudienceEntry> governorates;
  final int productId;
  final String? productName;
  final String? productNameEn;
  final String? productImageUrl;
  final String? productBarcode;
  final RetailVariantOption? condition;
  final RetailVariantOption? payment;
  final String? description;

  const RetailListing({
    required this.id,
    required this.price,
    required this.currency,
    this.stock,
    this.minOrderQty,
    this.maxOrderQty,
    this.unit,
    this.sku,
    required this.isActive,
    required this.visibility,
    this.audienceBusinesses = const [],
    this.audienceChildren = const [],
    this.audienceCategoryIds = const [],
    this.governorateIds = const [],
    this.governorates = const [],
    required this.productId,
    this.productName,
    this.productNameEn,
    this.productImageUrl,
    this.productBarcode,
    this.condition,
    this.payment,
    this.description,
  });

  bool get isRestricted => visibility == 'restricted';

  factory RetailListing.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final audience = json['audience'] as Map<String, dynamic>? ?? const {};
    final governorates = json['governorates'] as Map<String, dynamic>? ?? const {};
    return RetailListing(
      id: json['id'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      stock: json['stock'] as int?,
      minOrderQty: json['min_order_qty'] as int?,
      maxOrderQty: json['max_order_qty'] as int?,
      unit: json['unit'] as String?,
      sku: json['sku'] as String?,
      isActive: json['is_active'] as bool,
      visibility: json['visibility'] as String? ?? 'public',
      audienceBusinesses: (audience['businesses'] as List<dynamic>? ?? [])
          .map((e) => RetailAudienceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      audienceChildren: (audience['children'] as List<dynamic>? ?? [])
          .map((e) => RetailAudienceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      audienceCategoryIds: (audience['category_ids'] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList(),
      governorateIds: (governorates['ids'] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList(),
      governorates: (governorates['items'] as List<dynamic>? ?? [])
          .map((e) => RetailAudienceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      productId: product?['id'] as int? ?? 0,
      productName: product?['name'] as String?,
      productNameEn: product?['name_en'] as String?,
      productImageUrl: Env.assetUrl(product?['image'] as String?),
      productBarcode: product?['barcode'] as String?,
      condition: RetailVariantOption.maybe(json['condition']),
      payment: RetailVariantOption.maybe(json['payment']),
      description: json['description'] as String?,
    );
  }
}
