import '../../../../core/env/env.dart';

/// One line on a shared cart — mirrors SharedCartController::present()'s
/// `items[]`, which carries who added it (unlike a solo cart's items).
class SharedCartItem {
  final int id;
  final String kind;
  final int offeringId;
  final String name;
  final String? sizeName;
  final List<String> extraNames;
  final int addedByUserId;
  final String addedByName;
  final int qty;
  final double price;
  final double totalPrice;

  const SharedCartItem({
    required this.id,
    required this.kind,
    required this.offeringId,
    required this.name,
    this.sizeName,
    required this.extraNames,
    required this.addedByUserId,
    required this.addedByName,
    required this.qty,
    required this.price,
    required this.totalPrice,
  });

  factory SharedCartItem.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as Map<String, dynamic>? ?? const {};
    final addedBy = json['added_by'] as Map<String, dynamic>? ?? const {};
    return SharedCartItem(
      id: json['id'] as int,
      kind: json['kind'] as String? ?? 'menu',
      offeringId: json['offering_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      sizeName: options['size'] as String?,
      extraNames: (options['extras'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      addedByUserId: addedBy['id'] as int? ?? 0,
      addedByName: addedBy['name'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// One participant's own bill within the shared cart — cash on arrival, each
/// person pays only for what they added plus their own share of fees/tax.
class SharedCartParticipant {
  final int userId;
  final String name;
  final String role; // 'host' | 'member'
  final int itemsCount;
  final double itemsSubtotal;
  final double serviceFee;
  final double tax;
  final double total;

  const SharedCartParticipant({
    required this.userId,
    required this.name,
    required this.role,
    required this.itemsCount,
    required this.itemsSubtotal,
    required this.serviceFee,
    required this.tax,
    required this.total,
  });

  bool get isHost => role == 'host';

  factory SharedCartParticipant.fromJson(Map<String, dynamic> json) => SharedCartParticipant(
    userId: json['user_id'] as int,
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? 'member',
    itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
    itemsSubtotal: (json['items_subtotal'] as num?)?.toDouble() ?? 0,
    serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0,
    tax: (json['tax'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
  );
}

/// Mirrors `SharedCartController::present()` — the group cart a host shares
/// and friends join by token, each adding their own lines.
class SharedCart {
  final int id;
  final String status;
  final String? shareToken;
  final int? businessId;
  final String? businessName;
  final String? businessLogoUrl;
  final String fulfillmentType;
  final List<SharedCartParticipant> participants;
  final List<SharedCartItem> items;
  final double grandTotal;
  final bool viewerIsHost;

  const SharedCart({
    required this.id,
    required this.status,
    this.shareToken,
    this.businessId,
    this.businessName,
    this.businessLogoUrl,
    required this.fulfillmentType,
    required this.participants,
    required this.items,
    required this.grandTotal,
    required this.viewerIsHost,
  });

  factory SharedCart.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final totals = json['totals'] as Map<String, dynamic>? ?? const {};
    final viewer = json['viewer'] as Map<String, dynamic>?;
    return SharedCart(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'cart',
      shareToken: json['share_token'] as String?,
      businessId: business?['id'] as int?,
      businessName: business?['name'] as String?,
      businessLogoUrl: Env.assetUrl(business?['logo'] as String?),
      fulfillmentType: json['fulfillment_type'] as String? ?? 'dine_in',
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((e) => SharedCartParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SharedCartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      grandTotal: (totals['grand_total'] as num?)?.toDouble() ?? 0,
      viewerIsHost: viewer?['is_host'] as bool? ?? false,
    );
  }
}
