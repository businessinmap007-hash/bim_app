/// `GET /bookings/{id}/financial-preview` — this party's OWN side of the money
/// for a booking (the server never sends the counterparty's wallet or checks).
class BookingFinancialPreview {
  final String side; // client | business
  final String status;
  final bool depositRequired;
  final bool depositFrozen;
  final double depositWalletRequired;
  final bool coveredByGuarantee;
  final double guaranteeApplied;
  final double feeRequired;
  final List<String> promotions;
  final double balance;
  final double requiredTotal;
  final bool ready;
  final bool counterpartReady;
  final List<String> messages;

  const BookingFinancialPreview({
    required this.side,
    required this.status,
    required this.depositRequired,
    required this.depositFrozen,
    required this.depositWalletRequired,
    required this.coveredByGuarantee,
    required this.guaranteeApplied,
    required this.feeRequired,
    this.promotions = const [],
    required this.balance,
    required this.requiredTotal,
    required this.ready,
    required this.counterpartReady,
    this.messages = const [],
  });

  /// Nothing is asked of this party — the card has nothing to say.
  bool get isEmpty => requiredTotal <= 0 && feeRequired <= 0 && !depositRequired;

  factory BookingFinancialPreview.fromJson(Map<String, dynamic> json) {
    final deposit = json['deposit'] as Map<String, dynamic>? ?? const {};
    final fees = json['fees'] as Map<String, dynamic>? ?? const {};
    final me = json['me'] as Map<String, dynamic>? ?? const {};
    double d(Object? v) => (v as num?)?.toDouble() ?? 0;
    return BookingFinancialPreview(
      side: json['side'] as String? ?? 'client',
      status: json['status'] as String? ?? '',
      depositRequired: deposit['required'] as bool? ?? false,
      depositFrozen: deposit['already_frozen'] as bool? ?? false,
      depositWalletRequired: d(deposit['my_wallet_required']),
      coveredByGuarantee: deposit['covered_by_guarantee'] as bool? ?? false,
      guaranteeApplied: d(deposit['guarantee_applied']),
      feeRequired: d(fees['my_required']),
      promotions: (fees['promotions'] as List<dynamic>? ?? [])
          .map((e) => (e as Map<String, dynamic>)['message'] as String? ?? '')
          .where((m) => m.isNotEmpty)
          .toList(),
      balance: d(me['balance']),
      requiredTotal: d(me['required_total']),
      ready: me['ready'] as bool? ?? false,
      counterpartReady: json['counterpart_ready'] as bool? ?? true,
      messages: (json['messages'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
    );
  }
}
