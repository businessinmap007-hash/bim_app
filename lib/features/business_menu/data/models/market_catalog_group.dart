/// «تعبئة الرفوف» — one row a merchant may price, pre-named from the
/// platform's own option vocabulary (see Api\V2\MenuMarketCatalogController).
class MarketCatalogRow {
  final int optionId;
  final String nameAr;
  final String nameEn;
  final MarketCatalogItem? item;

  const MarketCatalogRow({
    required this.optionId,
    required this.nameAr,
    required this.nameEn,
    required this.item,
  });

  String name(String languageCode) {
    final primary = languageCode == 'ar' ? nameAr : nameEn;
    return primary.isNotEmpty ? primary : (nameAr.isNotEmpty ? nameAr : nameEn);
  }

  factory MarketCatalogRow.fromJson(Map<String, dynamic> json) {
    return MarketCatalogRow(
      optionId: (json['option_id'] as num).toInt(),
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      item: json['item'] != null
          ? MarketCatalogItem.fromJson(json['item'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MarketCatalogItem {
  final int id;
  final double? basePrice;
  final double? supplyPrice;
  final String? saleUnit;
  final String? brandName;
  final int? availableQuantity;
  final bool isActive;

  const MarketCatalogItem({
    required this.id,
    required this.basePrice,
    required this.supplyPrice,
    required this.saleUnit,
    required this.brandName,
    required this.availableQuantity,
    required this.isActive,
  });

  factory MarketCatalogItem.fromJson(Map<String, dynamic> json) {
    return MarketCatalogItem(
      id: (json['id'] as num).toInt(),
      basePrice: (json['base_price'] as num?)?.toDouble(),
      supplyPrice: (json['supply_price'] as num?)?.toDouble(),
      saleUnit: json['sale_unit'] as String?,
      brandName: json['brand_name'] as String?,
      availableQuantity: (json['available_quantity'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class MarketCatalogGroup {
  final int groupId;
  final String nameAr;
  final String nameEn;
  final List<MarketCatalogRow> rows;
  final int filled;
  final int total;

  const MarketCatalogGroup({
    required this.groupId,
    required this.nameAr,
    required this.nameEn,
    required this.rows,
    required this.filled,
    required this.total,
  });

  String name(String languageCode) {
    final primary = languageCode == 'ar' ? nameAr : nameEn;
    return primary.isNotEmpty ? primary : (nameAr.isNotEmpty ? nameAr : nameEn);
  }

  factory MarketCatalogGroup.fromJson(Map<String, dynamic> json) {
    return MarketCatalogGroup(
      groupId: (json['group_id'] as num).toInt(),
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => MarketCatalogRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      filled: (json['filled'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class SaleUnitOption {
  final String code;
  final String label;
  const SaleUnitOption({required this.code, required this.label});

  factory SaleUnitOption.fromJson(Map<String, dynamic> json) {
    return SaleUnitOption(code: json['code'] as String, label: json['label'] as String);
  }
}

class MarketCatalog {
  final List<MarketCatalogGroup> groups;
  final List<SaleUnitOption> saleUnits;
  final double? defaultMarginPercent;

  const MarketCatalog({
    required this.groups,
    required this.saleUnits,
    required this.defaultMarginPercent,
  });

  factory MarketCatalog.fromJson(Map<String, dynamic> json) {
    return MarketCatalog(
      groups: (json['groups'] as List<dynamic>? ?? [])
          .map((e) => MarketCatalogGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      saleUnits: (json['sale_units'] as List<dynamic>? ?? [])
          .map((e) => SaleUnitOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultMarginPercent: (json['default_margin_percent'] as num?)?.toDouble(),
    );
  }
}
