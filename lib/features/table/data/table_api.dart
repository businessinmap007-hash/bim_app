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
