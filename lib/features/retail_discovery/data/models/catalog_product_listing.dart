import '../../../../core/env/env.dart';

class RetailFilterFacet {
  final int id;
  final String name;
  final int products;

  const RetailFilterFacet({required this.id, required this.name, required this.products});

  factory RetailFilterFacet.fromJson(Map<String, dynamic> json) => RetailFilterFacet(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    products: (json['products'] as num?)?.toInt() ?? 0,
  );
}

/// GET /discovery/retail/filters — the branches/categories/brands that
/// actually have active listings right now.
class RetailFilters {
  final List<RetailFilterFacet> branches;
  final List<RetailFilterFacet> categories;
  final List<RetailFilterFacet> brands;

  const RetailFilters({this.branches = const [], this.categories = const [], this.brands = const []});

  factory RetailFilters.fromJson(Map<String, dynamic> json) => RetailFilters(
    branches: (json['branches'] as List<dynamic>? ?? [])
        .map((e) => RetailFilterFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
    categories: (json['categories'] as List<dynamic>? ?? [])
        .map((e) => RetailFilterFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
    brands: (json['brands'] as List<dynamic>? ?? [])
        .map((e) => RetailFilterFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class RetailCategoryRef {
  final int? id;
  final String name;
  const RetailCategoryRef({this.id, required this.name});

  factory RetailCategoryRef.fromJson(Map<String, dynamic> json) => RetailCategoryRef(
    id: (json['id'] as num?)?.toInt(),
    name: json['name'] as String? ?? '',
  );
}

/// One row on the cross-business "shop products" list — a catalog master
/// with the price range and seller count across every business selling it.
/// See Api\V2\RetailDiscoveryController::products().
class CatalogProductSummary {
  final int id;
  final String name;
  final String? image;
  final String? barcode;
  final String package;
  final String brand;
  final RetailCategoryRef category;
  final double minPrice;
  final double maxPrice;
  final int businesses;

  const CatalogProductSummary({
    required this.id,
    required this.name,
    this.image,
    this.barcode,
    required this.package,
    required this.brand,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.businesses,
  });

  factory CatalogProductSummary.fromJson(Map<String, dynamic> json) => CatalogProductSummary(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    image: Env.assetUrl(json['image'] as String?),
    barcode: json['barcode'] as String?,
    package: json['package'] as String? ?? '',
    brand: json['brand'] as String? ?? '',
    category: RetailCategoryRef.fromJson(json['category'] as Map<String, dynamic>? ?? const {}),
    minPrice: (json['min_price'] as num?)?.toDouble() ?? 0,
    maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0,
    businesses: (json['businesses'] as num?)?.toInt() ?? 0,
  );
}

/// One seller's active listing of a product. See
/// Api\V2\RetailDiscoveryController::show().
class ProductOffer {
  final int listingId;
  final int businessId;
  final String businessName;
  final String? businessLogo;
  final double price;
  final String currency;
  final int? stock;
  final String? sku;

  const ProductOffer({
    required this.listingId,
    required this.businessId,
    required this.businessName,
    this.businessLogo,
    required this.price,
    required this.currency,
    this.stock,
    this.sku,
  });

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>? ?? const {};
    return ProductOffer(
      listingId: (json['listing_id'] as num).toInt(),
      businessId: (business['id'] as num?)?.toInt() ?? 0,
      businessName: business['name'] as String? ?? '',
      businessLogo: Env.assetUrl(business['logo'] as String?),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      stock: (json['stock'] as num?)?.toInt(),
      sku: json['sku'] as String?,
    );
  }
}

/// GET /discovery/retail/products/{id} — one product master with every
/// business that sells it, cheapest first.
class ProductDetail {
  final int id;
  final String name;
  final String? image;
  final String? barcode;
  final String package;
  final String brand;
  final RetailCategoryRef category;
  final List<ProductOffer> offers;

  const ProductDetail({
    required this.id,
    required this.name,
    this.image,
    this.barcode,
    required this.package,
    required this.brand,
    required this.category,
    this.offers = const [],
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>;
    return ProductDetail(
      id: (product['id'] as num).toInt(),
      name: product['name'] as String? ?? '',
      image: Env.assetUrl(product['image'] as String?),
      barcode: product['barcode'] as String?,
      package: product['package'] as String? ?? '',
      brand: product['brand'] as String? ?? '',
      category: RetailCategoryRef.fromJson(product['category'] as Map<String, dynamic>? ?? const {}),
      offers: (json['offers'] as List<dynamic>? ?? [])
          .map((e) => ProductOffer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
