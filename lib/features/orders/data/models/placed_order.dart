import '../../../../core/env/env.dart';

/// One line on a placed order — mirrors `OrderItemResource`.
class OrderLineItem {
  final int id;
  final String name;
  final int qty;
  final double price;
  final double totalPrice;
  final List<String> addonNames;

  const OrderLineItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    required this.totalPrice,
    required this.addonNames,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    final addons = json['addons'] as List<dynamic>? ?? const [];
    return OrderLineItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      addonNames: addons
          .whereType<Map<String, dynamic>>()
          .map((a) => a['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }
}

/// Mirrors `OrderResource` — used for the customer's order history list and
/// detail AND the business's incoming-order queue and detail (list
/// responses omit `items`, matching `whenLoaded('items')` on the backend;
/// `customer`/`table_label` are only ever loaded for the business side).
class PlacedOrder {
  final int id;
  final String status;
  final String? prepStatus;
  final String fulfillmentType;
  final double finalTotal;
  final double deliveryFee;
  final double discount;
  final int? businessId;
  final String? businessName;
  final String? businessLogoUrl;
  final int itemsCount;
  final List<OrderLineItem> items;
  final String? address;
  final String? notes;
  final DateTime? createdAt;
  final String? customerName;
  final String? customerPhone;
  final String? tableLabel;
  final bool depositRequired;
  final double? depositAmount;
  final bool depositCovered;
  final bool depositAcceptedWithoutCover;

  const PlacedOrder({
    required this.id,
    required this.status,
    this.prepStatus,
    required this.fulfillmentType,
    required this.finalTotal,
    required this.deliveryFee,
    required this.discount,
    this.businessId,
    this.businessName,
    this.businessLogoUrl,
    required this.itemsCount,
    required this.items,
    this.address,
    this.notes,
    this.createdAt,
    this.customerName,
    this.customerPhone,
    this.tableLabel,
    this.depositRequired = false,
    this.depositAmount,
    this.depositCovered = false,
    this.depositAcceptedWithoutCover = false,
  });

  /// Mirrors `OrderController::cancelPendingOrder` — pending and not yet
  /// accepted by the business (prep_status still null).
  bool get isCancellable => status == 'pending' && prepStatus == null;

  /// Mirrors `OrderController::businessAccept`'s own gate: an order with no
  /// deposit/guarantee cover needs the business to explicitly accept the
  /// risk (`accept_without_deposit=true`) rather than being silently taken.
  bool get needsExplicitDepositDecision => depositRequired && !depositCovered;

  factory PlacedOrder.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final totals = json['totals'] as Map<String, dynamic>? ?? const {};
    final deposit = json['deposit'] as Map<String, dynamic>? ?? const {};
    final items = json['items'] as List<dynamic>? ?? const [];
    return PlacedOrder(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      prepStatus: json['prep_status'] as String?,
      fulfillmentType: json['fulfillment_type'] as String? ?? 'delivery',
      finalTotal: (totals['final_total'] as num?)?.toDouble() ?? 0,
      deliveryFee: (totals['delivery_fee'] as num?)?.toDouble() ?? 0,
      discount: (totals['discount'] as num?)?.toDouble() ?? 0,
      businessId: business?['id'] as int?,
      businessName: business?['name'] as String?,
      businessLogoUrl: Env.assetUrl(business?['logo'] as String?),
      itemsCount: (json['items_count'] as num?)?.toInt() ?? items.length,
      items: items
          .whereType<Map<String, dynamic>>()
          .map(OrderLineItem.fromJson)
          .toList(),
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      customerName: customer?['name'] as String?,
      customerPhone: customer?['phone'] as String?,
      tableLabel: json['table_label'] as String?,
      depositRequired: deposit['required'] as bool? ?? false,
      depositAmount: (deposit['amount'] as num?)?.toDouble(),
      depositCovered: deposit['covered'] as bool? ?? false,
      depositAcceptedWithoutCover: deposit['accepted_without_cover'] as bool? ?? false,
    );
  }
}
