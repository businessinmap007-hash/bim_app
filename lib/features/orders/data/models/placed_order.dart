import '../../../../core/env/env.dart';

/// One line on a placed order — mirrors `OrderItemResource`.
class OrderLineItem {
  final int id;
  final String name;
  final int qty;
  final double price;
  final double totalPrice;
  final List<String> addonNames;

  /// Set once a business marks this line unavailable — 'substituted' (kept,
  /// [resolutionNote] says what it became) or 'removed' (dropped from the
  /// order's total). Null for the overwhelming majority of lines.
  final String? resolution;
  final String? resolutionNote;

  const OrderLineItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    required this.totalPrice,
    required this.addonNames,
    this.resolution,
    this.resolutionNote,
  });

  bool get isSubstituted => resolution == 'substituted';
  bool get isRemoved => resolution == 'removed';

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
      resolution: json['resolution'] as String?,
      resolutionNote: json['resolution_note'] as String?,
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
  final DateTime? pickupAt;
  final double finalTotal;
  final double deliveryFee;
  final double discount;
  final int? businessId;
  final String? businessName;
  final String? businessLogoUrl;
  final int itemsCount;
  final List<OrderLineItem> items;
  final String? address;
  // The connected delivery loop's own stage — assigned → picked_up →
  // delivered — null for pickup/dine-in orders and for delivery orders no
  // driver has been assigned to yet. See DeliveryDispatchService.
  final String? deliveryStage;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? notes;
  final String? outOfStockPolicy;
  final bool hasProject;
  final DateTime? createdAt;
  final String? customerName;
  final String? customerPhone;
  final String? tableLabel;
  final bool depositRequired;
  final double? depositAmount;
  final bool depositCovered;
  final bool depositAcceptedWithoutCover;
  final String? paymentMethod;
  // Three independent cash-payment attestations (OrderResource's own
  // payment_confirmations) - the customer confirms they paid, the merchant
  // confirms they received the order amount, and (delivery only) the driver
  // confirms they received the delivery fee. Never a chain.
  final DateTime? customerPaymentConfirmedAt;
  final DateTime? merchantPaymentConfirmedAt;
  final DateTime? driverPaymentConfirmedAt;
  final bool depositReleased;
  // Cash orders are held to the three-party confirmation: pickup/dine-in
  // completion waits on the merchant's confirmation, reviews on settlement.
  final bool paymentConfirmationRequired;
  final DateTime? paymentSettledAt;
  // The viewer's "I trust" ticks toward the other parties of the order, keyed
  // by 'customer' / 'business' / 'driver'. Null on list rows.
  final Map<String, ({bool trustedByMe, bool trustsMe})>? trust;

  const PlacedOrder({
    required this.id,
    required this.status,
    this.prepStatus,
    required this.fulfillmentType,
    this.pickupAt,
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
    this.outOfStockPolicy,
    this.hasProject = false,
    this.createdAt,
    this.customerName,
    this.customerPhone,
    this.tableLabel,
    this.depositRequired = false,
    this.depositAmount,
    this.depositCovered = false,
    this.depositAcceptedWithoutCover = false,
    this.deliveryStage,
    this.deliveryLat,
    this.deliveryLng,
    this.paymentMethod,
    this.customerPaymentConfirmedAt,
    this.merchantPaymentConfirmedAt,
    this.driverPaymentConfirmedAt,
    this.depositReleased = false,
    this.paymentConfirmationRequired = false,
    this.paymentSettledAt,
    this.trust,
  });

  /// Mirrors `OrderController::cancelPendingOrder` — pending and not yet
  /// accepted by the business (prep_status still null).
  bool get isCancellable => status == 'pending' && prepStatus == null;

  /// Mirrors `OrderController::businessAccept`'s own gate: an order with no
  /// deposit/guarantee cover needs the business to explicitly accept the
  /// risk (`accept_without_deposit=true`) rather than being silently taken.
  bool get needsExplicitDepositDecision => depositRequired && !depositCovered;

  /// Cash confirmation only applies while payment is actually cash — a
  /// future gateway payment_method (see CheckoutScreen's own note) tracks
  /// its own paid_at instead.
  bool get isCashPayment =>
      paymentMethod == null || paymentMethod == 'cash' || paymentMethod == 'cash_on_delivery';

  /// What the merchant is owed — everything except the delivery_fee leg,
  /// which whoever actually collects it confirms separately.
  double get orderAmount => finalTotal - deliveryFee;

  factory PlacedOrder.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final totals = json['totals'] as Map<String, dynamic>? ?? const {};
    final deposit = json['deposit'] as Map<String, dynamic>? ?? const {};
    final items = json['items'] as List<dynamic>? ?? const [];
    final deliveryCoordinates = json['delivery_coordinates'] as Map<String, dynamic>?;
    final paymentConfirmations = json['payment_confirmations'] as Map<String, dynamic>? ?? const {};
    return PlacedOrder(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      prepStatus: json['prep_status'] as String?,
      fulfillmentType: json['fulfillment_type'] as String? ?? 'delivery',
      pickupAt: json['pickup_at'] != null ? DateTime.tryParse(json['pickup_at'] as String) : null,
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
      outOfStockPolicy: json['out_of_stock_policy'] as String?,
      hasProject: json['has_project'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      customerName: customer?['name'] as String?,
      customerPhone: customer?['phone'] as String?,
      tableLabel: json['table_label'] as String?,
      depositRequired: deposit['required'] as bool? ?? false,
      depositAmount: (deposit['amount'] as num?)?.toDouble(),
      depositCovered: deposit['covered'] as bool? ?? false,
      depositAcceptedWithoutCover: deposit['accepted_without_cover'] as bool? ?? false,
      deliveryStage: json['delivery_stage'] as String?,
      deliveryLat: (deliveryCoordinates?['lat'] as num?)?.toDouble(),
      deliveryLng: (deliveryCoordinates?['lng'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String?,
      customerPaymentConfirmedAt: DateTime.tryParse(paymentConfirmations['customer_confirmed_at'] as String? ?? ''),
      merchantPaymentConfirmedAt: DateTime.tryParse(paymentConfirmations['merchant_confirmed_at'] as String? ?? ''),
      driverPaymentConfirmedAt: DateTime.tryParse(paymentConfirmations['driver_confirmed_at'] as String? ?? ''),
      depositReleased: deposit['released'] as bool? ?? false,
      paymentConfirmationRequired: json['payment_confirmation_required'] as bool? ?? false,
      paymentSettledAt: DateTime.tryParse(paymentConfirmations['settled_at'] as String? ?? ''),
      trust: (json['trust'] as Map<String, dynamic>?)?.map(
        (role, v) => MapEntry(role, (
          trustedByMe: (v as Map<String, dynamic>)['trusted_by_me'] as bool? ?? false,
          trustsMe: v['trusts_me'] as bool? ?? false,
        )),
      ),
    );
  }
}
