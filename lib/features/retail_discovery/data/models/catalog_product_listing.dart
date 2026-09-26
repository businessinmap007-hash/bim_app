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

/// One row of a product's spec table (brand, type, capacity…), already
/// localized and unit-formatted by the server.
class ProductSpec {
  final String name;
  final String value;
  const ProductSpec({required this.name, required this.value});

  static List<ProductSpec> listFrom(dynamic json) => (json as List<dynamic>? ?? [])
      .map(
        (e) =>
            ProductSpec(name: (e as Map<String, dynamic>)['name'] as String? ?? '', value: e['value'] as String? ?? ''),
      )
      .toList();
}

class RetailCategoryRef {
  final int? id;
  final String name;
  const RetailCategoryRef({this.id, required this.name});

  factory RetailCategoryRef.fromJson(Map<String, dynamic> json) =>
      RetailCategoryRef(id: (json['id'] as num?)?.toInt(), name: json['name'] as String? ?? '');
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

/// One row on the Categories screen's "Retail" service feed — a single
/// LISTING (business + product + price), not a bare business card or a
/// cross-seller product summary. See
/// Api\V2\RetailDiscoveryController::listings().
class RetailListingCard {
  final int listingId;
  final double price;
  final String currency;
  final int? stock;
  final int? minOrderQty;
  final int? maxOrderQty;
  final String? unit;
  final int productId;
  final String productName;
  final String? productNameEn;
  final String? productImage;
  final int businessId;
  final String businessName;
  final String? businessLogo;
  final int? businessCategoryId;
  final int? businessCategoryChildId;
  final bool isOpenNow;
  final String? conditionName;
  final String? paymentName;
  final String? description;

  const RetailListingCard({
    required this.listingId,
    required this.price,
    required this.currency,
    this.stock,
    this.minOrderQty,
    this.maxOrderQty,
    this.unit,
    required this.productId,
    required this.productName,
    this.productNameEn,
    this.productImage,
    required this.businessId,
    required this.businessName,
    this.businessLogo,
    this.businessCategoryId,
    this.businessCategoryChildId,
    required this.isOpenNow,
    this.conditionName,
    this.paymentName,
    this.description,
  });

  factory RetailListingCard.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? const {};
    final business = json['business'] as Map<String, dynamic>? ?? const {};
    return RetailListingCard(
      listingId: (json['listing_id'] as num).toInt(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      stock: (json['stock'] as num?)?.toInt(),
      minOrderQty: (json['min_order_qty'] as num?)?.toInt(),
      maxOrderQty: (json['max_order_qty'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      productId: (product['id'] as num?)?.toInt() ?? 0,
      productName: product['name'] as String? ?? '',
      productNameEn: product['name_en'] as String?,
      productImage: Env.assetUrl(product['image'] as String?),
      businessId: (business['id'] as num?)?.toInt() ?? 0,
      businessName: business['name'] as String? ?? '',
      businessLogo: Env.assetUrl(business['logo'] as String?),
      businessCategoryId: (business['category_id'] as num?)?.toInt(),
      businessCategoryChildId: (business['category_child_id'] as num?)?.toInt(),
      isOpenNow: business['is_open_now'] as bool? ?? true,
      conditionName: (json['condition'] as Map<String, dynamic>?)?['name'] as String?,
      paymentName: (json['payment'] as Map<String, dynamic>?)?['name'] as String?,
      description: json['description'] as String?,
    );
  }
}

/// GET /discovery/retail/business/{id} — one seller's whole retail shelf,
/// the storefront a [RetailListingCard] opens into.
class RetailStorefrontListing {
  final int listingId;
  final double price;
  final String currency;
  final int? stock;
  final int? minOrderQty;
  final int? maxOrderQty;
  final String? unit;
  final int productId;
  final String productName;
  final String? productNameEn;
  final String? productImage;
  final RetailFilterFacet? condition;
  final RetailFilterFacet? payment;
  final String? description;
  final List<ProductSpec> specs;

  const RetailStorefrontListing({
    required this.listingId,
    required this.price,
    required this.currency,
    this.stock,
    this.minOrderQty,
    this.maxOrderQty,
    this.unit,
    required this.productId,
    required this.productName,
    this.productNameEn,
    this.productImage,
    this.condition,
    this.payment,
    this.description,
    this.specs = const [],
  });

  static RetailFilterFacet? _facet(dynamic j) => j is Map<String, dynamic>
      ? RetailFilterFacet(id: (j['id'] as num).toInt(), name: j['name'] as String? ?? '', products: 0)
      : null;

  factory RetailStorefrontListing.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? const {};
    return RetailStorefrontListing(
      listingId: (json['listing_id'] as num).toInt(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      stock: (json['stock'] as num?)?.toInt(),
      minOrderQty: (json['min_order_qty'] as num?)?.toInt(),
      maxOrderQty: (json['max_order_qty'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      productId: (product['id'] as num?)?.toInt() ?? 0,
      productName: product['name'] as String? ?? '',
      productNameEn: product['name_en'] as String?,
      productImage: Env.assetUrl(product['image'] as String?),
      condition: _facet(json['condition']),
      payment: _facet(json['payment']),
      description: json['description'] as String?,
      specs: ProductSpec.listFrom(product['specs']),
    );
  }
}

/// One color/size choice inside a [RetailVariantGroupCard] — its own real
/// listing id, price and stock; picking it adds THAT listing to the cart
/// exactly like any other [RetailStorefrontListing].
class RetailVariantOptionCard {
  final int listingId;
  final String label;
  final double price;
  final String currency;
  final int? stock;
  final int? minOrderQty;
  final int? maxOrderQty;
  final String? unit;

  const RetailVariantOptionCard({
    required this.listingId,
    required this.label,
    required this.price,
    required this.currency,
    this.stock,
    this.minOrderQty,
    this.maxOrderQty,
    this.unit,
  });

  factory RetailVariantOptionCard.fromJson(Map<String, dynamic> json) => RetailVariantOptionCard(
    listingId: (json['listing_id'] as num).toInt(),
    label: json['label'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    stock: (json['stock'] as num?)?.toInt(),
    minOrderQty: (json['min_order_qty'] as num?)?.toInt(),
    maxOrderQty: (json['max_order_qty'] as num?)?.toInt(),
    unit: json['unit'] as String?,
  );

  /// The [_QuantitySheet]/add-to-cart flow only ever needs a
  /// [RetailStorefrontListing] shape — reuse it rather than a second sheet.
  RetailStorefrontListing toStorefrontListing(String productName, String? productImage) => RetailStorefrontListing(
    listingId: listingId,
    price: price,
    currency: currency,
    stock: stock,
    minOrderQty: minOrderQty,
    maxOrderQty: maxOrderQty,
    unit: unit,
    productId: 0,
    productName: '$productName · $label',
    productImage: productImage,
  );
}

/// One of a business's own product families — several listings (color/size)
/// under one card. See RetailDiscoveryController::business()'s variant_groups.
class RetailVariantGroupCard {
  final int groupId;
  final String name;
  final String? image;
  final double priceFrom;
  final List<RetailVariantOptionCard> options;

  const RetailVariantGroupCard({
    required this.groupId,
    required this.name,
    this.image,
    required this.priceFrom,
    this.options = const [],
  });

  factory RetailVariantGroupCard.fromJson(Map<String, dynamic> json) => RetailVariantGroupCard(
    groupId: (json['group_id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    image: Env.assetUrl(json['image'] as String?),
    priceFrom: (json['price_from'] as num?)?.toDouble() ?? 0,
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => RetailVariantOptionCard.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class RetailStorefront {
  final int businessId;
  final String businessName;
  final String? businessLogo;
  final List<RetailStorefrontListing> listings;
  final List<RetailVariantGroupCard> variantGroups;

  const RetailStorefront({
    required this.businessId,
    required this.businessName,
    this.businessLogo,
    this.listings = const [],
    this.variantGroups = const [],
  });

  factory RetailStorefront.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>? ?? const {};
    return RetailStorefront(
      businessId: (business['id'] as num?)?.toInt() ?? 0,
      businessName: business['name'] as String? ?? '',
      businessLogo: Env.assetUrl(business['logo'] as String?),
      listings: (json['listings'] as List<dynamic>? ?? [])
          .map((e) => RetailStorefrontListing.fromJson(e as Map<String, dynamic>))
          .toList(),
      variantGroups: (json['variant_groups'] as List<dynamic>? ?? [])
          .map((e) => RetailVariantGroupCard.fromJson(e as Map<String, dynamic>))
          .toList(),
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
