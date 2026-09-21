import '../../../core/network/api_client.dart';

class TableScanResult {
  final int orderId;
  final String shareToken;
  final String tableLabel;
  const TableScanResult({required this.orderId, required this.shareToken, required this.tableLabel});
}

class TableCallResult {
  final int callId;
  final String type;
  final String status;
  const TableCallResult({required this.callId, required this.type, required this.status});
}

/// One pending «waiter / bill / assistance» call on the business side.
class TableCall {
  final int id;
  final String type;
  final String tableLabel;
  final String? note;
  final DateTime? createdAt;

  const TableCall({required this.id, required this.type, required this.tableLabel, this.note, this.createdAt});

  factory TableCall.fromJson(Map<String, dynamic> json) => TableCall(
    id: (json['id'] as num).toInt(),
    type: json['type'] as String? ?? '',
    tableLabel: (json['table'] as Map<String, dynamic>?)?['label'] as String? ?? '',
    note: json['note'] as String?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}

/// /table/{token}/... — restaurant-table QR (BIM-13.3). See
/// Api\V2\TableController. The token is a plain string (no scanner package
/// exists in this app, and the backend never requires one) — a physical
/// table code the customer types in.
class TableApi {
  final ApiClient _client;
  const TableApi(this._client);

  /// Joins (or opens) the table's shared cart. First scanner is the host.
  Future<TableScanResult> scan(String token) async {
    final data = await _client.post('/table/$token/scan') as Map<String, dynamic>;
    final table = data['table'] as Map<String, dynamic>? ?? const {};
    return TableScanResult(
      orderId: (data['order_id'] as num).toInt(),
      shareToken: data['share_token'] as String? ?? '',
      tableLabel: table['label'] as String? ?? '',
    );
  }

  // ─────────────── Business side: the standing queue ───────────────

  /// GET /business/table-calls — pending calls, newest first.
  Future<List<TableCall>> pendingCalls() async {
    final data = await _client.get('/business/table-calls') as List<dynamic>;
    return data.map((e) => TableCall.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> resolveCall(int id) => _client.post('/business/table-calls/$id/resolve');

  /// Calls staff over — 'waiter' | 'bill' | 'assistance'. Idempotent: a
  /// still-pending call of the same type is reused, not duplicated.
  Future<TableCallResult> call(String token, String type, {String? note}) async {
    final data = await _client.post(
      '/table/$token/call',
      data: {'type': type, if (note != null && note.isNotEmpty) 'note': note},
    ) as Map<String, dynamic>;
    return TableCallResult(
      callId: (data['call_id'] as num).toInt(),
      type: data['type'] as String? ?? type,
      status: data['status'] as String? ?? '',
    );
  }
}
