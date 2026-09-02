/// Mirrors `WalletTransactionResource` — one ledger entry. `type` is a free
/// string set across many services (booking fees, order fees, deposits,
/// manual top-ups, ...) with no fixed enum on the backend, so this app shows
/// `note` (the human-readable line the backend already wrote) rather than
/// trying to localize every possible `type` value itself.
class WalletTransaction {
  final int id;
  final String status;
  final String direction; // 'in' | 'out'
  final String type;
  final double amount;
  final double balanceAfter;
  final String? note;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.status,
    required this.direction,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    this.createdAt,
  });

  bool get isCredit => direction == 'in';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    id: json['id'] as int,
    status: json['status'] as String? ?? '',
    direction: json['direction'] as String? ?? 'out',
    type: json['type'] as String? ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0,
    note: json['note'] as String?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
