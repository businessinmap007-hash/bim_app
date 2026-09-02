import '../../../../core/env/env.dart';

/// A business's own priced listing over the shared catalog master — see
/// Api\V2\BusinessRetailListingController / BusinessRetailListingResource.
/// `visibility`/`audience` (public vs. a named wholesale audience) are
/// read-only here: every listing this app creates defaults to public, the
/// common case; targeted/restricted listings stay AdminV2-only for now.
class RetailListing {
  final int id;
  final double price;
  final String currency;
  final int? stock;
  final String? sku;
  final bool isActive;
  final String visibility;
  final int productId;
  final String? productName;
  final String? productImageUrl;
  final String? productBarcode;

  const RetailListing({
    required this.id,
    required this.price,
    required this.currency,
    this.stock,
    this.sku,
    required this.isActive,
    required this.visibility,
    required this.productId,
    this.productName,
    this.productImageUrl,
    this.productBarcode,
  });

  factory RetailListing.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return RetailListing(
      id: json['id'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      stock: json['stock'] as int?,
      sku: json['sku'] as String?,
      isActive: json['is_active'] as bool,
      visibility: json['visibility'] as String? ?? 'public',
      productId: product?['id'] as int? ?? 0,
      productName: product?['name'] as String?,
      productImageUrl: Env.assetUrl(product?['image'] as String?),
      productBarcode: product?['barcode'] as String?,
    );
  }
}
