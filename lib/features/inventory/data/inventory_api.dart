import 'dart:math';

import '../../../core/network/api_client.dart';
import 'inventory_models.dart';

/// How the inventory calls reach the server. On the phone it is [DirectInventoryTransport]: straight to the API. The
/// desktop app swaps in a transport that keeps working with no internet — reads from its local copy or the main
/// computer on the office network, writes queued and replayed later (every write carries its own `uuid`, so the server
/// books a replayed one only once).
abstract class InventoryTransport {
  Future<dynamic> get(String path, {Map<String, dynamic>? query});

  /// Returns the server's `data`, or null when the write was queued on this computer for later.
  Future<dynamic> send(String method, String path, {Map<String, dynamic>? body, bool queueable = false});
}

class DirectInventoryTransport implements InventoryTransport {
  final ApiClient _client;

  const DirectInventoryTransport(this._client);

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) => _client.get(path, query: query);

  @override
  Future<dynamic> send(String method, String path, {Map<String, dynamic>? body, bool queueable = false}) {
    switch (method) {
      case 'PATCH':
        return _client.patch(path, data: body);
      case 'PUT':
        return _client.put(path, data: body);
      case 'DELETE':
        return _client.delete(path, data: body);
      default:
        return _client.post(path, data: body);
    }
  }
}

/// Everything the inventory suite asks the server (backend routes under /business/inventory).
class InventoryApi {
  final InventoryTransport _t;

  const InventoryApi(this._t);

  /// A random v4 uuid — the key that makes a replayed write book once.
  static String newUuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Map<String, dynamic> _map(dynamic v) => (v as Map<String, dynamic>?) ?? const {};
  List<Map<String, dynamic>> _rows(dynamic v, String key) => ((_map(v)[key] as List<dynamic>?) ?? const []).cast<Map<String, dynamic>>();

  // ── settings & subscription ──
  Future<InvSettings> settings() async => InvSettings.fromJson(_map(await _t.get('/business/inventory/settings')));

  Future<InvSettings> updateSettings({bool? enabled, List<String>? features, double? poApprovalThreshold, bool clearThreshold = false}) async =>
      InvSettings.fromJson(_map(await _t.send('PATCH', '/business/inventory/settings', body: {
        'enabled': ?enabled,
        'features': ?features,
        if (poApprovalThreshold != null || clearThreshold) 'po_approval_threshold': poApprovalThreshold,
      })));

  Future<InvSettings> renew() async => InvSettings.fromJson(_map(await _t.send('POST', '/business/inventory/subscription/renew')));

  // ── dashboard & coverage ──
  Future<InvDashboard> dashboard() async => InvDashboard.fromJson(_map(await _t.get('/business/inventory/dashboard')));

  Future<List<InvCoverage>> coverage() async => _rows(await _t.get('/business/inventory/coverage'), 'items').map(InvCoverage.fromJson).toList();

  // ── items & moves ──
  Future<({List<InvItem> items, List<String> groups})> items({String? search, String? group, bool below = false, String? barcode}) async {
    final data = await _t.get('/business/inventory/items', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      'group': ?group,
      if (below) 'below': true,
      if (barcode != null && barcode.isNotEmpty) 'barcode': barcode,
    });
    return (
      items: _rows(data, 'items').map(InvItem.fromJson).toList(),
      groups: ((_map(data)['groups'] as List<dynamic>?) ?? const []).cast<String>(),
    );
  }

  Future<({InvItem item, List<InvMove> moves, InvCoverage? coverage})> item(int id) async {
    final data = _map(await _t.get('/business/inventory/items/$id'));
    return (
      item: InvItem.fromJson(data['item'] as Map<String, dynamic>),
      moves: _rows(data, 'moves').map(InvMove.fromJson).toList(),
      coverage: data['coverage'] is Map<String, dynamic> ? InvCoverage.fromJson(data['coverage'] as Map<String, dynamic>) : null,
    );
  }

  Future<List<InvMove>> itemMoves(int id, {int page = 1}) async =>
      _rows(await _t.get('/business/inventory/items/$id/moves', query: {'page': page, 'per_page': 100}), 'moves').map(InvMove.fromJson).toList();

  Future<InvItem?> createItem(Map<String, dynamic> body) async {
    final data = await _t.send('POST', '/business/inventory/items', body: {'uuid': newUuid(), ...body}, queueable: true);
    return data == null ? null : InvItem.fromJson(_map(data)['item'] as Map<String, dynamic>);
  }

  Future<InvItem> updateItem(int id, Map<String, dynamic> body) async =>
      InvItem.fromJson(_map(await _t.send('PATCH', '/business/inventory/items/$id', body: body))['item'] as Map<String, dynamic>);

  /// kind: opening | waste | transfer — null when queued on this computer
  Future<dynamic> move(Map<String, dynamic> body) =>
      _t.send('POST', '/business/inventory/moves', body: {'uuid': newUuid(), ...body}, queueable: true);

  Future<dynamic> reverseMove(int id, {String? reason}) =>
      _t.send('POST', '/business/inventory/moves/$id/reverse', body: {'uuid': newUuid(), 'reason': ?reason});

  Future<List<InvWarehouse>> warehouses() async => _rows(await _t.get('/business/inventory/warehouses'), 'warehouses').map(InvWarehouse.fromJson).toList();

  Future<dynamic> createWarehouse(String name) => _t.send('POST', '/business/inventory/warehouses', body: {'uuid': newUuid(), 'name': name}, queueable: true);

  // ── links & recipes ──
  Future<({List<InvLinkOwner> menu, List<InvLinkOwner> retail})> links() async {
    final data = await _t.get('/business/inventory/links');
    return (menu: _rows(data, 'menu').map(InvLinkOwner.fromJson).toList(), retail: _rows(data, 'retail').map(InvLinkOwner.fromJson).toList());
  }

  Future<dynamic> saveRecipe(String ownerType, int ownerId, List<InvRecipeLine> lines) => _t.send('PUT', '/business/inventory/recipes',
      body: {'owner_type': ownerType, 'owner_id': ownerId, 'lines': lines.map((l) => l.toJson()).toList()});

  // ── devices & sync ──
  Future<List<InvDevice>> devices() async => _rows(await _t.get('/business/inventory/devices'), 'devices').map(InvDevice.fromJson).toList();

  Future<dynamic> registerDevice({required String uuid, required String name, required String role, List<String>? screens, bool isHub = false}) =>
      _t.send('POST', '/business/inventory/devices', body: {'uuid': uuid, 'name': name, 'role': role, 'screens': ?screens, 'is_hub': isHub});

  Future<dynamic> updateDevice(int id, Map<String, dynamic> body) => _t.send('PATCH', '/business/inventory/devices/$id', body: body);

  Future<dynamic> revokeDevice(int id) => _t.send('DELETE', '/business/inventory/devices/$id');

  Future<dynamic> deviceSeen(String uuid) => _t.send('POST', '/business/inventory/devices/$uuid/seen');

  Future<Map<String, dynamic>> changes({int afterMove = 0, String? since}) async =>
      _map(await _t.get('/business/inventory/changes', query: {'after_move': afterMove, 'since': ?since}));

  // ── stocktake ──
  Future<List<InvStocktake>> stocktakes() async => _rows(await _t.get('/business/inventory/stocktakes'), 'stocktakes').map(InvStocktake.fromJson).toList();

  Future<InvStocktake?> startStocktake({String? title, String? groupName, bool blind = true}) async {
    final data = await _t.send('POST', '/business/inventory/stocktakes',
        body: {'uuid': newUuid(), 'title': ?title, 'group_name': ?groupName, 'blind': blind}, queueable: true);
    return data == null ? null : InvStocktake.fromJson(_map(data)['stocktake'] as Map<String, dynamic>);
  }

  Future<InvStocktake> stocktake(int id) async => InvStocktake.fromJson(_map(await _t.get('/business/inventory/stocktakes/$id'))['stocktake'] as Map<String, dynamic>);

  Future<InvStocktake?> countLines(int id, List<Map<String, dynamic>> lines) async {
    final data = await _t.send('POST', '/business/inventory/stocktakes/$id/count', body: {'lines': lines}, queueable: true);
    return data == null ? null : InvStocktake.fromJson(_map(data)['stocktake'] as Map<String, dynamic>);
  }

  Future<InvStocktake> stocktakeAction(int id, String action) async =>
      InvStocktake.fromJson(_map(await _t.send('POST', '/business/inventory/stocktakes/$id/$action'))['stocktake'] as Map<String, dynamic>);

  // ── purchases ──
  Future<List<InvSupplier>> suppliers() async => _rows(await _t.get('/business/inventory/suppliers'), 'suppliers').map(InvSupplier.fromJson).toList();

  /// A business on BIM to buy from — by name, trade or city in one box, or [myCity] only.
  Future<List<InvSupplierCandidate>> supplierCandidates({String? q, bool myCity = false}) async =>
      _rows(await _t.get('/business/inventory/supplier-candidates', query: {if (q != null && q.trim().isNotEmpty) 'q': q.trim(), if (myCity) 'my_city': 1}), 'businesses')
          .map(InvSupplierCandidate.fromJson)
          .toList();

  Future<dynamic> createSupplier({required String name, String? phone, int? linkedBusinessId}) => _t.send('POST', '/business/inventory/suppliers',
      body: {'uuid': newUuid(), 'name': name, 'phone': ?phone, 'linked_business_id': ?linkedBusinessId}, queueable: true);

  Future<List<InvPurchaseOrder>> purchaseOrders({String? status}) async =>
      _rows(await _t.get('/business/inventory/purchase-orders', query: {'status': ?status}), 'purchase_orders').map(InvPurchaseOrder.fromJson).toList();

  Future<InvPurchaseOrderDetail> purchaseOrder(int id) async => InvPurchaseOrderDetail.fromJson(_map(await _t.get('/business/inventory/purchase-orders/$id')));

  Future<dynamic> createPurchaseOrder({required int supplierId, required List<Map<String, dynamic>> lines, bool submit = false, String? notes, String? expectedOn}) =>
      _t.send('POST', '/business/inventory/purchase-orders', body: {
        'uuid': newUuid(),
        'supplier_id': supplierId,
        'lines': lines,
        'submit': submit,
        'notes': ?notes,
        'expected_on': ?expectedOn,
      }, queueable: true);

  Future<dynamic> purchaseOrderAction(int id, String action, {String? reason}) =>
      _t.send('POST', '/business/inventory/purchase-orders/$id/$action', body: {'reason': ?reason});

  Future<dynamic> receive({int? purchaseOrderId, required List<Map<String, dynamic>> lines, String? notes, String? deviceUuid}) =>
      _t.send('POST', '/business/inventory/receipts', body: {
        'uuid': newUuid(),
        'purchase_order_id': ?purchaseOrderId,
        'lines': lines,
        'notes': ?notes,
        'device_uuid': ?deviceUuid,
      }, queueable: true);

  Future<dynamic> recordBill({required int supplierId, int? purchaseOrderId, String? number, required List<Map<String, dynamic>> lines}) =>
      _t.send('POST', '/business/inventory/supplier-bills', body: {
        'uuid': newUuid(),
        'supplier_id': supplierId,
        'purchase_order_id': ?purchaseOrderId,
        'number': ?number,
        'lines': lines,
      }, queueable: true);

  Future<dynamic> recordPayment({required int supplierId, required double amount, required String method, String? note}) =>
      _t.send('POST', '/business/inventory/supplier-payments',
          body: {'uuid': newUuid(), 'supplier_id': supplierId, 'amount': amount, 'method': method, 'note': ?note}, queueable: true);

  Future<List<InvPurchaseOrder>> incomingPurchaseOrders() async =>
      _rows(await _t.get('/business/incoming-purchase-orders'), 'purchase_orders').map(InvPurchaseOrder.fromJson).toList();

  Future<dynamic> confirmIncoming(int id) => _t.send('POST', '/business/incoming-purchase-orders/$id/confirm');

  // ── cashier ──
  Future<List<InvPosProduct>> posCatalog() async => _rows(await _t.get('/business/inventory/pos/catalog'), 'products').map(InvPosProduct.fromJson).toList();

  Future<Map<String, dynamic>?> openShift({double openingCash = 0, String? deviceUuid}) async {
    final data = await _t.send('POST', '/business/inventory/pos/shifts',
        body: {'uuid': newUuid(), 'opening_cash': openingCash, 'device_uuid': ?deviceUuid, 'opened_at': DateTime.now().toIso8601String()}, queueable: true);
    return data == null ? null : _map(data)['shift'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> closeShift(int id, double countedCash) async =>
      _map(await _t.send('POST', '/business/inventory/pos/shifts/$id/close', body: {'counted_cash': countedCash}));

  /// null when queued on this computer (no connection) — the sale is kept and sent later
  Future<Map<String, dynamic>?> sell({
    int? shiftId,
    required double paid,
    required List<Map<String, dynamic>> lines,
    String? deviceUuid,
    int? customerId,
    double onAccount = 0,
    bool creditOverride = false,
  }) async {
    final data = await _t.send('POST', '/business/inventory/pos/sales', body: {
      'uuid': newUuid(),
      'shift_id': ?shiftId,
      'paid': paid,
      'customer_id': ?customerId,
      if (onAccount > 0) 'on_account': onAccount,
      if (creditOverride) 'credit_override': true,
      'lines': lines,
      'device_uuid': ?deviceUuid,
      'sold_at': DateTime.now().toIso8601String(),
      // a sale on a customer's account waits for the server's limit check — never queued blind
    }, queueable: onAccount <= 0);
    return data == null ? null : _map(data);
  }

  Future<dynamic> returnSale(int id) => _t.send('POST', '/business/inventory/pos/sales/$id/return');
}
