import '../../../../core/env/env.dart';

/// Mirrors `CartController::presentCart()` — one line already resolved to
/// what the customer picked, not what the item is called today (the label
/// is frozen at add-to-cart time).
class CartItem {
  final int id;
  final String kind; // 'retail' | 'menu'
  final int offeringId;
  final String name;
  final String? sizeName;
  final List<String> extraNames;
  final int qty;
  final double price;
  final double totalPrice;

  const CartItem({
    required this.id,
    required this.kind,
    required this.offeringId,
    required this.name,
    this.sizeName,
    required this.extraNames,
    required this.qty,
    required this.price,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as Map<String, dynamic>? ?? const {};
    return CartItem(
      id: json['id'] as int,
      kind: json['kind'] as String? ?? 'menu',
      offeringId: json['offering_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      sizeName: options['size'] as String?,
      extraNames: (options['extras'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      qty: json['qty'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CartBill {
  final double menuSubtotal;
  final double retailSubtotal;
  final double serviceFee;
  final bool serviceIncluded;
  final double tax;
  final bool taxIncluded;
  final double deliveryFee;
  final double discount;

  const CartBill({
    required this.menuSubtotal,
    required this.retailSubtotal,
    required this.serviceFee,
    required this.serviceIncluded,
    required this.tax,
    required this.taxIncluded,
    required this.deliveryFee,
    required this.discount,
  });

  factory CartBill.fromJson(Map<String, dynamic> json) => CartBill(
    menuSubtotal: (json['menu_subtotal'] as num?)?.toDouble() ?? 0,
    retailSubtotal: (json['retail_subtotal'] as num?)?.toDouble() ?? 0,
    serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0,
    serviceIncluded: json['service_included'] as bool? ?? false,
    tax: (json['tax'] as num?)?.toDouble() ?? 0,
    taxIncluded: json['tax_included'] as bool? ?? false,
    deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
    discount: (json['discount'] as num?)?.toDouble() ?? 0,
  );
}

class CartBusiness {
  final int id;
  final String name;
  final String? logoUrl;

  const CartBusiness({required this.id, required this.name, this.logoUrl});

  factory CartBusiness.fromJson(Map<String, dynamic> json) => CartBusiness(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    logoUrl: Env.assetUrl(json['logo'] as String?),
  );
}

/// One business's draft order — everything the cart/checkout screens need,
/// one shape for both a still-open cart and the order it becomes at
/// checkout (`CartController::presentCart` serializes both the same way).
class Cart {
  final int id;
  final String status;
  final CartBusiness? business;
  final String fulfillmentType;
  final List<CartItem> items;
  final int itemsCount;
  final CartBill bill;
  final double total;
  final double deliveryFee;
  final double discount;
  final double finalTotal;

  const Cart({
    required this.id,
    required this.status,
    this.business,
    required this.fulfillmentType,
    required this.items,
    required this.itemsCount,
    required this.bill,
    required this.total,
    required this.deliveryFee,
    required this.discount,
    required this.finalTotal,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json['id'] as int,
    status: json['status'] as String? ?? '',
    business: json['business'] != null ? CartBusiness.fromJson(json['business'] as Map<String, dynamic>) : null,
    fulfillmentType: json['fulfillment_type'] as String? ?? 'delivery',
    items: (json['items'] as List<dynamic>? ?? []).map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
    itemsCount: json['items_count'] as int? ?? 0,
    bill: CartBill.fromJson(json['bill'] as Map<String, dynamic>? ?? const {}),
    total: (json['total'] as num?)?.toDouble() ?? 0,
    deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
    discount: (json['discount'] as num?)?.toDouble() ?? 0,
    finalTotal: (json['final_total'] as num?)?.toDouble() ?? 0,
  );
}
