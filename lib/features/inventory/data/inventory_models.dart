// The inventory suite's shapes (backend: App\Services\Inventory\InventoryPayload), shared by the desktop app and the
// owner's phone. Quantities are always in the item's BASE unit (علبة، جرام، مل، قطعة); bigger units are factors.

double _d(Object? v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);
double? _dn(Object? v) => v == null ? null : _d(v);
int _i(Object? v) => v == null ? 0 : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0);
int? _in(Object? v) => v == null ? null : _i(v);
List<Map<String, dynamic>> _list(Object? v) => (v as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

/// A number without trailing zeros: 12.5 → «12.5», 30.0 → «30».
String invNum(num v) {
  final s = v.toStringAsFixed(3);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

class InvFeature {
  final String key;
  final String label;
  final bool on;
  final bool optional;

  const InvFeature({required this.key, required this.label, required this.on, required this.optional});

  factory InvFeature.fromJson(Map<String, dynamic> j) =>
      InvFeature(key: j['key'] as String, label: j['label'] as String? ?? j['key'] as String, on: j['on'] == true, optional: j['optional'] == true);
}

class InvSubscription {
  final String status; // none | active | grace | read_only
  final double price;
  final DateTime? paidUntil;
  final DateTime? graceUntil;
  final bool writable;

  const InvSubscription({required this.status, required this.price, this.paidUntil, this.graceUntil, required this.writable});

  factory InvSubscription.fromJson(Map<String, dynamic>? j) => InvSubscription(
        status: j?['status'] as String? ?? 'none',
        price: _d(j?['price']),
        paidUntil: DateTime.tryParse(j?['paid_until'] as String? ?? '')?.toLocal(),
        graceUntil: DateTime.tryParse(j?['grace_until'] as String? ?? '')?.toLocal(),
        writable: j?['writable'] == true,
      );
}

class InvSettings {
  final bool available;
  final bool enabled;
  final List<InvFeature> features;
  final double? poApprovalThreshold;
  final InvSubscription subscription;
  final bool isOwner;

  /// null for the owner (everything); a staff member's granted capabilities otherwise
  final List<String>? capabilities;

  const InvSettings({
    required this.available,
    required this.enabled,
    required this.features,
    required this.poApprovalThreshold,
    required this.subscription,
    required this.isOwner,
    required this.capabilities,
  });

  bool has(String feature) => features.any((f) => f.key == feature && f.on);

  /// The owner may do everything; staff only what they were given.
  bool can(String capability) => isOwner || (capabilities?.contains(capability) ?? false);

  factory InvSettings.fromJson(Map<String, dynamic> j) => InvSettings(
        available: j['available'] == true,
        enabled: j['enabled'] == true,
        features: _list(j['features']).map(InvFeature.fromJson).toList(),
        poApprovalThreshold: _dn(j['po_approval_threshold']),
        subscription: InvSubscription.fromJson(j['subscription'] as Map<String, dynamic>?),
        isOwner: j['is_owner'] == true,
        capabilities: (j['capabilities'] as List<dynamic>?)?.cast<String>(),
      );
}

class InvUnit {
  final int? id;
  final String name;
  final double factor;
  final String? barcode;

  const InvUnit({this.id, required this.name, required this.factor, this.barcode});

  factory InvUnit.fromJson(Map<String, dynamic> j) =>
      InvUnit(id: _in(j['id']), name: j['name'] as String, factor: _d(j['factor']), barcode: j['barcode'] as String?);

  Map<String, dynamic> toJson() => {'name': name, 'factor': factor, if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode};
}

class InvItem {
  final int id;
  final String uuid;
  final String nameAr;
  final String? nameEn;
  final String? groupName;
  final String baseUnit;
  final String unitKind;
  final String? barcode;
  final double? reorderLevel;
  final double avgCost;
  final bool trackLots;
  final bool isActive;
  final List<InvUnit> units;
  final double onHand;
  final String onHandDisplay;
  final double value;
  final bool belowReorder;

  const InvItem({
    required this.id,
    required this.uuid,
    required this.nameAr,
    this.nameEn,
    this.groupName,
    required this.baseUnit,
    required this.unitKind,
    this.barcode,
    this.reorderLevel,
    required this.avgCost,
    required this.trackLots,
    required this.isActive,
    required this.units,
    required this.onHand,
    required this.onHandDisplay,
    required this.value,
    required this.belowReorder,
  });

  factory InvItem.fromJson(Map<String, dynamic> j) => InvItem(
        id: _i(j['id']),
        uuid: j['uuid'] as String? ?? '',
        nameAr: j['name_ar'] as String? ?? '',
        nameEn: j['name_en'] as String?,
        groupName: j['group_name'] as String?,
        baseUnit: j['base_unit'] as String? ?? '',
        unitKind: j['unit_kind'] as String? ?? 'count',
        barcode: j['barcode'] as String?,
        reorderLevel: _dn(j['reorder_level']),
        avgCost: _d(j['avg_cost']),
        trackLots: j['track_lots'] == true,
        isActive: j['is_active'] != false,
        units: _list(j['units']).map(InvUnit.fromJson).toList(),
        onHand: _d(j['on_hand']),
        onHandDisplay: j['on_hand_display'] as String? ?? '',
        value: _d(j['value']),
        belowReorder: j['below_reorder'] == true,
      );
}

class InvMove {
  final int id;
  final int itemId;
  final String? itemName;
  final double qty;
  final double unitCost;
  final String type;
  final String? reason;
  final String? referenceType;
  final int? referenceId;
  final DateTime? occurredAt;
  final double? balanceAfter;

  const InvMove({
    required this.id,
    required this.itemId,
    this.itemName,
    required this.qty,
    required this.unitCost,
    required this.type,
    this.reason,
    this.referenceType,
    this.referenceId,
    this.occurredAt,
    this.balanceAfter,
  });

  factory InvMove.fromJson(Map<String, dynamic> j) => InvMove(
        id: _i(j['id']),
        itemId: _i(j['item_id']),
        itemName: j['item_name'] as String?,
        qty: _d(j['qty']),
        unitCost: _d(j['unit_cost']),
        type: j['type'] as String? ?? '',
        reason: j['reason'] as String?,
        referenceType: j['reference_type'] as String?,
        referenceId: _in(j['reference_id']),
        occurredAt: DateTime.tryParse(j['occurred_at'] as String? ?? '')?.toLocal(),
        balanceAfter: _dn(j['balance_after']),
      );
}

class InvCoverage {
  final int itemId;
  final String name;
  final String baseUnit;
  final double onHand;
  final double usedToday;
  final double weekdayAverage;
  final double expectedRestOfToday;
  final double dailyAverage;
  final double? daysLeft;
  final bool belowReorder;

  /// no | tight | yes | empty | unknown
  final String verdict;

  const InvCoverage({
    required this.itemId,
    required this.name,
    required this.baseUnit,
    required this.onHand,
    required this.usedToday,
    required this.weekdayAverage,
    required this.expectedRestOfToday,
    required this.dailyAverage,
    required this.daysLeft,
    required this.belowReorder,
    required this.verdict,
  });

  factory InvCoverage.fromJson(Map<String, dynamic> j) => InvCoverage(
        itemId: _i(j['item_id']),
        name: j['name'] as String? ?? '',
        baseUnit: j['base_unit'] as String? ?? '',
        onHand: _d(j['on_hand']),
        usedToday: _d(j['used_today']),
        weekdayAverage: _d(j['weekday_average']),
        expectedRestOfToday: _d(j['expected_rest_of_today']),
        dailyAverage: _d(j['daily_average']),
        daysLeft: _dn(j['days_left']),
        belowReorder: j['below_reorder'] == true,
        verdict: j['verdict'] as String? ?? 'unknown',
      );
}

class InvSummary {
  final double stockValue;
  final int belowReorder;
  final int openPurchaseOrders;
  final double wasteThisMonth;

  const InvSummary({required this.stockValue, required this.belowReorder, required this.openPurchaseOrders, required this.wasteThisMonth});

  factory InvSummary.fromJson(Map<String, dynamic>? j) => InvSummary(
        stockValue: _d(j?['stock_value']),
        belowReorder: _i(j?['below_reorder']),
        openPurchaseOrders: _i(j?['open_purchase_orders']),
        wasteThisMonth: _d(j?['waste_this_month']),
      );
}

class InvDashboard {
  final InvSummary summary;
  final List<InvCoverage> low;
  final List<InvMove> recentMoves;

  const InvDashboard({required this.summary, required this.low, required this.recentMoves});

  factory InvDashboard.fromJson(Map<String, dynamic> j) => InvDashboard(
        summary: InvSummary.fromJson(j['summary'] as Map<String, dynamic>?),
        low: _list(j['low']).map(InvCoverage.fromJson).toList(),
        recentMoves: _list(j['recent_moves']).map(InvMove.fromJson).toList(),
      );
}

class InvSupplier {
  final int id;
  final String name;
  final String? phone;
  final int? linkedBusinessId;
  final String? linkedBusinessName;
  final bool onBim;
  final double? balance;

  const InvSupplier({required this.id, required this.name, this.phone, this.linkedBusinessId, this.linkedBusinessName, required this.onBim, this.balance});

  factory InvSupplier.fromJson(Map<String, dynamic> j) => InvSupplier(
        id: _i(j['id']),
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String?,
        linkedBusinessId: _in(j['linked_business_id']),
        linkedBusinessName: j['linked_business_name'] as String?,
        onBim: j['on_bim'] == true,
        balance: _dn(j['balance']),
      );
}

class InvPoLine {
  final int id;
  final int itemId;
  final String? itemName;
  final String unitName;
  final double unitFactor;
  final double qty;
  final double unitPrice;
  final double total;
  final double receivedQty;
  final double billedQty;

  const InvPoLine({
    required this.id,
    required this.itemId,
    this.itemName,
    required this.unitName,
    required this.unitFactor,
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.receivedQty,
    required this.billedQty,
  });

  double get remaining => (qty - receivedQty).clamp(0, double.infinity).toDouble();

  factory InvPoLine.fromJson(Map<String, dynamic> j) => InvPoLine(
        id: _i(j['id']),
        itemId: _i(j['item_id']),
        itemName: j['item_name'] as String?,
        unitName: j['unit_name'] as String? ?? '',
        unitFactor: _d(j['unit_factor']),
        qty: _d(j['qty']),
        unitPrice: _d(j['unit_price']),
        total: _d(j['total']),
        receivedQty: _d(j['received_qty']),
        billedQty: _d(j['billed_qty']),
      );
}

class InvPurchaseOrder {
  final int id;
  final int number;
  final String status;
  final InvSupplier? supplier;
  final String? buyerName;
  final double total;
  final DateTime? expectedOn;
  final String? notes;
  final String? rejectedReason;
  final DateTime? supplierConfirmedAt;
  final DateTime? createdAt;
  final List<InvPoLine> lines;

  const InvPurchaseOrder({
    required this.id,
    required this.number,
    required this.status,
    this.supplier,
    this.buyerName,
    required this.total,
    this.expectedOn,
    this.notes,
    this.rejectedReason,
    this.supplierConfirmedAt,
    this.createdAt,
    required this.lines,
  });

  factory InvPurchaseOrder.fromJson(Map<String, dynamic> j) => InvPurchaseOrder(
        id: _i(j['id']),
        number: _i(j['number']),
        status: j['status'] as String? ?? 'draft',
        supplier: j['supplier'] is Map<String, dynamic> ? InvSupplier.fromJson(j['supplier'] as Map<String, dynamic>) : null,
        buyerName: (j['buyer'] as Map<String, dynamic>?)?['name'] as String?,
        total: _d(j['total']),
        expectedOn: DateTime.tryParse(j['expected_on'] as String? ?? ''),
        notes: j['notes'] as String?,
        rejectedReason: j['rejected_reason'] as String?,
        supplierConfirmedAt: DateTime.tryParse(j['supplier_confirmed_at'] as String? ?? '')?.toLocal(),
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal(),
        lines: _list(j['lines']).map(InvPoLine.fromJson).toList(),
      );
}

class InvMatchLine {
  final int poLineId;
  final double ordered;
  final double received;
  final double billed;
  final double differenceValue;
  final List<String> issues;

  const InvMatchLine({required this.poLineId, required this.ordered, required this.received, required this.billed, required this.differenceValue, required this.issues});

  factory InvMatchLine.fromJson(Map<String, dynamic> j) => InvMatchLine(
        poLineId: _i(j['po_line_id']),
        ordered: _d(j['ordered']),
        received: _d(j['received']),
        billed: _d(j['billed']),
        differenceValue: _d(j['difference_value']),
        issues: (j['issues'] as List<dynamic>? ?? const []).cast<String>(),
      );
}

class InvPurchaseOrderDetail {
  final InvPurchaseOrder order;
  final bool matched;
  final List<InvMatchLine> match;
  final bool canApprove;

  const InvPurchaseOrderDetail({required this.order, required this.matched, required this.match, required this.canApprove});

  factory InvPurchaseOrderDetail.fromJson(Map<String, dynamic> j) {
    final match = j['match'] as Map<String, dynamic>? ?? const {};
    return InvPurchaseOrderDetail(
      order: InvPurchaseOrder.fromJson(j['purchase_order'] as Map<String, dynamic>),
      matched: match['matched'] != false,
      match: _list(match['lines']).map(InvMatchLine.fromJson).toList(),
      canApprove: j['can_approve'] == true,
    );
  }
}

class InvStocktakeLine {
  final int itemId;
  final String? itemName;
  final String? baseUnit;
  final int? lotId;
  final double? expectedQty;
  final double? countedQty;
  final double? difference;
  final double? differenceValue;
  final String? reason;

  const InvStocktakeLine({
    required this.itemId,
    this.itemName,
    this.baseUnit,
    this.lotId,
    this.expectedQty,
    this.countedQty,
    this.difference,
    this.differenceValue,
    this.reason,
  });

  factory InvStocktakeLine.fromJson(Map<String, dynamic> j) => InvStocktakeLine(
        itemId: _i(j['item_id']),
        itemName: j['item_name'] as String?,
        baseUnit: j['base_unit'] as String?,
        lotId: _in(j['lot_id']),
        expectedQty: _dn(j['expected_qty']),
        countedQty: _dn(j['counted_qty']),
        difference: _dn(j['difference']),
        differenceValue: _dn(j['difference_value']),
        reason: j['reason'] as String?,
      );
}

class InvStocktake {
  final int id;
  final String? title;
  final String status; // counting | review | applied | cancelled
  final bool blind;
  final DateTime? startedAt;
  final double? netDifferenceValue;
  final List<InvStocktakeLine> lines;

  const InvStocktake({required this.id, this.title, required this.status, required this.blind, this.startedAt, this.netDifferenceValue, required this.lines});

  factory InvStocktake.fromJson(Map<String, dynamic> j) => InvStocktake(
        id: _i(j['id']),
        title: j['title'] as String?,
        status: j['status'] as String? ?? 'counting',
        blind: j['blind'] == true,
        startedAt: DateTime.tryParse(j['started_at'] as String? ?? '')?.toLocal(),
        netDifferenceValue: _dn(j['net_difference_value']),
        lines: _list(j['lines']).map(InvStocktakeLine.fromJson).toList(),
      );
}

class InvPosChoice {
  final int id;
  final String name;
  final double price;

  const InvPosChoice({required this.id, required this.name, required this.price});

  factory InvPosChoice.fromJson(Map<String, dynamic> j) => InvPosChoice(id: _i(j['id']), name: j['name'] as String? ?? '', price: _d(j['price']));
}

class InvPosProduct {
  final String ownerType; // menu_item | retail_listing
  final int ownerId;
  final String name;
  final double price;
  final int? available;
  final List<String> barcodes;
  final List<InvPosChoice> variants;
  final List<InvPosChoice> extras;

  const InvPosProduct({
    required this.ownerType,
    required this.ownerId,
    required this.name,
    required this.price,
    this.available,
    required this.barcodes,
    required this.variants,
    required this.extras,
  });

  factory InvPosProduct.fromJson(Map<String, dynamic> j) => InvPosProduct(
        ownerType: j['owner_type'] as String,
        ownerId: _i(j['owner_id']),
        name: j['name'] as String? ?? '',
        price: _d(j['price']),
        available: _in(j['available']),
        barcodes: (j['barcodes'] as List<dynamic>? ?? const []).cast<String>(),
        variants: _list(j['variants']).map(InvPosChoice.fromJson).toList(),
        extras: _list(j['extras']).map(InvPosChoice.fromJson).toList(),
      );
}

class InvRecipeLine {
  final int itemId;
  final double qty;
  final double wastePct;

  const InvRecipeLine({required this.itemId, required this.qty, this.wastePct = 0});

  factory InvRecipeLine.fromJson(Map<String, dynamic> j) => InvRecipeLine(itemId: _i(j['item_id']), qty: _d(j['qty']), wastePct: _d(j['waste_pct']));

  Map<String, dynamic> toJson() => {'item_id': itemId, 'qty': qty, 'waste_pct': wastePct};
}

class InvLinkOwner {
  final String ownerType;
  final int ownerId;
  final String name;
  final double price;
  final String link; // none | direct | recipe
  final double cost;
  final List<InvRecipeLine> lines;
  final List<InvLinkOwner> variants;
  final List<InvLinkOwner> extras;

  const InvLinkOwner({
    required this.ownerType,
    required this.ownerId,
    required this.name,
    required this.price,
    required this.link,
    required this.cost,
    required this.lines,
    required this.variants,
    required this.extras,
  });

  factory InvLinkOwner.fromJson(Map<String, dynamic> j) => InvLinkOwner(
        ownerType: j['owner_type'] as String,
        ownerId: _i(j['owner_id']),
        name: j['name'] as String? ?? '',
        price: _d(j['price']),
        link: j['link'] as String? ?? 'none',
        cost: _d(j['cost']),
        lines: _list(j['lines']).map(InvRecipeLine.fromJson).toList(),
        variants: _list(j['variants']).map(InvLinkOwner.fromJson).toList(),
        extras: _list(j['extras']).map(InvLinkOwner.fromJson).toList(),
      );
}

class InvDevice {
  final int id;
  final String uuid;
  final String name;
  final String role;
  final List<String>? screens;
  final bool isHub;
  final DateTime? lastSeenAt;

  const InvDevice({required this.id, required this.uuid, required this.name, required this.role, this.screens, required this.isHub, this.lastSeenAt});

  factory InvDevice.fromJson(Map<String, dynamic> j) => InvDevice(
        id: _i(j['id']),
        uuid: j['uuid'] as String? ?? '',
        name: j['name'] as String? ?? '',
        role: j['role'] as String? ?? 'main',
        screens: (j['screens'] as List<dynamic>?)?.cast<String>(),
        isHub: j['is_hub'] == true,
        lastSeenAt: DateTime.tryParse(j['last_seen_at'] as String? ?? '')?.toLocal(),
      );
}

class InvWarehouse {
  final int id;
  final String name;
  final bool isDefault;

  const InvWarehouse({required this.id, required this.name, required this.isDefault});

  factory InvWarehouse.fromJson(Map<String, dynamic> j) => InvWarehouse(id: _i(j['id']), name: j['name'] as String? ?? '', isDefault: j['is_default'] == true);
}
