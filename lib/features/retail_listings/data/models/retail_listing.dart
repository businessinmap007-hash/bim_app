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
  final int productId;
  final String? productName;
  final String? productNameEn;
  final String? productImageUrl;
  final String? productBarcode;

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
    required this.productId,
    this.productName,
    this.productNameEn,
    this.productImageUrl,
    this.productBarcode,
  });

  bool get isRestricted => visibility == 'restricted';

  factory RetailListing.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final audience = json['audience'] as Map<String, dynamic>? ?? const {};
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
      audienceCategoryIds: (audience['category_ids'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      productId: product?['id'] as int? ?? 0,
      productName: product?['name'] as String?,
      productNameEn: product?['name_en'] as String?,
      productImageUrl: Env.assetUrl(product?['image'] as String?),
      productBarcode: product?['barcode'] as String?,
    );
  }
}
