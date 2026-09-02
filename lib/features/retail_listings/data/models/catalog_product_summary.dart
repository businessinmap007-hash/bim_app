import '../../../../core/env/env.dart';

/// One row from GET /business/retail-listings/lookup — a shared catalog
/// master product this business hasn't listed yet. See
/// Api\V2\BusinessRetailListingController::lookup.
class CatalogProductSummary {
  final int id;
  final String name;
  final String? brand;
  final String? barcode;
  final String? imageUrl;

  const CatalogProductSummary({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    this.imageUrl,
  });

  factory CatalogProductSummary.fromJson(Map<String, dynamic> json) => CatalogProductSummary(
    id: json['id'] as int,
    name: json['name'] as String,
    brand: (json['brand'] as String?)?.trim().isEmpty ?? true ? null : json['brand'] as String,
    barcode: (json['barcode'] as String?)?.trim().isEmpty ?? true ? null : json['barcode'] as String,
    imageUrl: Env.assetUrl(json['image'] as String?),
  );
}
