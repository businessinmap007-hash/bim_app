/// One fixed component of a [MenuBundle] — an existing menu item + how many
/// of it the bundle contains. Mirrors `BusinessMenuBundleController::payload()`.
class MenuBundleComponent {
  final int menuItemId;
  final String name;
  final double unitPrice;
  final int qty;

  const MenuBundleComponent({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.qty,
  });

  factory MenuBundleComponent.fromJson(Map<String, dynamic> json) => MenuBundleComponent(
    menuItemId: json['menu_item_id'] as int,
    name: json['name'] as String? ?? '',
    unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
    qty: (json['qty'] as num?)?.toInt() ?? 1,
  );
}

/// A business's own named combo — "وجبة العيلة" — a fixed set of its menu
/// items sold under one name and one price. See
/// Api\V2\BusinessMenuBundleController.
class MenuBundle {
  static const pricingFixed = 'fixed';
  static const pricingDiscountPercent = 'discount_percent';
  static const pricingDiscountFixed = 'discount_fixed';

  final int id;
  final String nameAr;
  final String? nameEn;
  final String pricingMode;
  final double? fixedPrice;
  final double? discountValue;
  final double componentsSubtotal;
  final double price;
  final bool isActive;
  final int sortOrder;
  final List<MenuBundleComponent> items;

  const MenuBundle({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.pricingMode,
    this.fixedPrice,
    this.discountValue,
    required this.componentsSubtotal,
    required this.price,
    required this.isActive,
    required this.sortOrder,
    this.items = const [],
  });

  factory MenuBundle.fromJson(Map<String, dynamic> json) => MenuBundle(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
    pricingMode: json['pricing_mode'] as String? ?? pricingFixed,
    fixedPrice: (json['fixed_price'] as num?)?.toDouble(),
    discountValue: (json['discount_value'] as num?)?.toDouble(),
    componentsSubtotal: (json['components_subtotal'] as num?)?.toDouble() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    sortOrder: json['sort_order'] as int? ?? 0,
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => MenuBundleComponent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
