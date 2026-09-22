/// One color/size choice inside a [RetailVariantGroup] — points at one of
/// the business's own retail listings (its own price/stock/sku).
class RetailVariantOption {
  final int id;
  final int listingId;
  final String label;
  final String labelAr;
  final String? labelEn;
  final double? price;
  final int? stock;
  final bool isActive;
  final String? productName;

  const RetailVariantOption({
    required this.id,
    required this.listingId,
    required this.label,
    required this.labelAr,
    this.labelEn,
    this.price,
    this.stock,
    required this.isActive,
    this.productName,
  });

  factory RetailVariantOption.fromJson(Map<String, dynamic> json) => RetailVariantOption(
    id: json['id'] as int,
    listingId: (json['listing_id'] as num).toInt(),
    label: json['label'] as String? ?? '',
    labelAr: json['label_ar'] as String? ?? '',
    labelEn: json['label_en'] as String?,
    price: (json['price'] as num?)?.toDouble(),
    stock: (json['stock'] as num?)?.toInt(),
    isActive: json['is_active'] as bool? ?? true,
    productName: json['product_name'] as String?,
  );
}

/// Several of a business's own listings shown to the customer as ONE
/// product with a variant picker — see Api\V2\BusinessRetailVariantGroupController.
class RetailVariantGroup {
  final int id;
  final String nameAr;
  final String? nameEn;
  final bool isActive;
  final int sortOrder;
  final List<RetailVariantOption> options;

  const RetailVariantGroup({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.isActive,
    required this.sortOrder,
    this.options = const [],
  });

  factory RetailVariantGroup.fromJson(Map<String, dynamic> json) => RetailVariantGroup(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => RetailVariantOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
