/// An escrow deposit the caller is a party to — see Api\V2\DepositController
/// / DepositResource. Read-only: release/refund/split all happen elsewhere
/// (BookingDepositService, DisputeService), never through this app directly.
class Deposit {
  final int id;
  final String status;
  final String myRole;
  final double totalAmount;
  final double clientAmount;
  final double businessAmount;
  final int clientPercent;
  final int businessPercent;
  final double myAmount;
  final int? counterpartyId;
  final String? counterpartyName;
  final int? bookingId;
  final String? targetType;
  final int? targetId;
  final DateTime? releasedAt;
  final DateTime? refundedAt;
  final DateTime? createdAt;

  const Deposit({
    required this.id,
    required this.status,
    required this.myRole,
    required this.totalAmount,
    required this.clientAmount,
    required this.businessAmount,
    required this.clientPercent,
    required this.businessPercent,
    required this.myAmount,
    this.counterpartyId,
    this.counterpartyName,
    this.bookingId,
    this.targetType,
    this.targetId,
    this.releasedAt,
    this.refundedAt,
    this.createdAt,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    final counterparty = json['counterparty'] as Map<String, dynamic>?;
    return Deposit(
      id: json['id'] as int,
      status: json['status'] as String,
      myRole: json['my_role'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      clientAmount: (json['client_amount'] as num).toDouble(),
      businessAmount: (json['business_amount'] as num).toDouble(),
      clientPercent: json['client_percent'] as int,
      businessPercent: json['business_percent'] as int,
      myAmount: (json['my_amount'] as num).toDouble(),
      counterpartyId: counterparty?['id'] as int?,
      counterpartyName: counterparty?['name'] as String?,
      bookingId: json['booking_id'] as int?,
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as int?,
      releasedAt: json['released_at'] != null ? DateTime.parse(json['released_at'] as String) : null,
      refundedAt: json['refunded_at'] != null ? DateTime.parse(json['refunded_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }
}
