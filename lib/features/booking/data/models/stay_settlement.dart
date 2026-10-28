/// «التسوية» of a non-refundable stay: what is frozen from each side (guarantee first, wallet for the rest), who confirmed «تمت
/// التسوية», the payments the guest recorded with their proof, and whether a judge may be asked yet.
class StaySettlement {
  /// `secured` (frozen, the stay stands) · `open` (cancelled — waiting for both sides) · `settled` · `arbitration`
  final String status;
  final double percent;
  final double amount;
  final ({double guarantee, double wallet})? clientHold;
  final ({double guarantee, double wallet})? businessHold;

  /// `client` or `business`
  final String? cancelledBy;
  final DateTime? openedAt;
  final DateTime? clientConfirmedAt;
  final DateTime? businessConfirmedAt;

  /// who pressed «تمت التسوية» for the hotel — its owner or a staff member, by name
  final String? businessConfirmedBy;

  /// the side of whoever reads it: `client` or `business`
  final String mySide;
  final DateTime? arbitrationFrom;
  final bool canRequestArbitration;
  final int? disputeId;
  final List<StaySettlementPayment> payments;

  /// «التسوية من محفظة التطبيق»: one side proposes (the guest offers, the hotel asks) up to [collectable]; the other accepts
  final ({String by, double amount})? walletOffer;
  final double collectable;
  final double? collected;

  /// `mutual` · `payment_received` · `wallet_collection` · `stay_started`
  final String? settledBy;

  const StaySettlement({
    required this.status,
    this.percent = 0,
    this.amount = 0,
    this.clientHold,
    this.businessHold,
    this.cancelledBy,
    this.openedAt,
    this.clientConfirmedAt,
    this.businessConfirmedAt,
    this.businessConfirmedBy,
    this.mySide = 'client',
    this.arbitrationFrom,
    this.canRequestArbitration = false,
    this.disputeId,
    this.payments = const [],
    this.walletOffer,
    this.collectable = 0,
    this.collected,
    this.settledBy,
  });

  bool get isOpen => status == 'open';
  bool get isClient => mySide == 'client';
  DateTime? get myConfirmedAt => isClient ? clientConfirmedAt : businessConfirmedAt;
  DateTime? get theirConfirmedAt => isClient ? businessConfirmedAt : clientConfirmedAt;
  bool get hasWaitingPayment => payments.any((p) => p.status == 'recorded');

  static ({double guarantee, double wallet})? _hold(Object? json) => json is Map<String, dynamic>
      ? (guarantee: (json['guarantee'] as num?)?.toDouble() ?? 0, wallet: (json['wallet'] as num?)?.toDouble() ?? 0)
      : null;

  static DateTime? _at(Object? v) => v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

  static StaySettlement? fromJsonOrNull(Object? json) => json is Map<String, dynamic> && json['status'] is String
      ? StaySettlement(
          status: json['status'] as String,
          percent: (json['percent'] as num?)?.toDouble() ?? 0,
          amount: (json['amount'] as num?)?.toDouble() ?? 0,
          clientHold: _hold(json['client_hold']),
          businessHold: _hold(json['business_hold']),
          cancelledBy: json['cancelled_by'] as String?,
          openedAt: _at(json['opened_at']),
          clientConfirmedAt: _at(json['client_confirmed_at']),
          businessConfirmedAt: _at(json['business_confirmed_at']),
          businessConfirmedBy: json['business_confirmed_by'] as String?,
          mySide: json['my_side'] as String? ?? 'client',
          arbitrationFrom: _at(json['arbitration_from']),
          canRequestArbitration: json['can_request_arbitration'] == true,
          disputeId: (json['dispute_id'] as num?)?.toInt(),
          payments: [for (final p in json['payments'] as List<dynamic>? ?? const []) StaySettlementPayment.fromJson(p as Map<String, dynamic>)],
          walletOffer: json['wallet_offer'] is Map<String, dynamic>
              ? (
                  by: (json['wallet_offer'] as Map<String, dynamic>)['by'] as String? ?? 'client',
                  amount: ((json['wallet_offer'] as Map<String, dynamic>)['amount'] as num?)?.toDouble() ?? 0,
                )
              : null,
          collectable: (json['collectable'] as num?)?.toDouble() ?? 0,
          collected: (json['collected'] as num?)?.toDouble(),
          settledBy: json['settled_by'] as String?,
        )
      : null;
}

class StaySettlementPayment {
  final int id;
  final double amount;

  /// `cash` or `transfer`
  final String method;
  final String? reference;
  final String? proofUrl;

  /// `recorded` (waiting for the hotel) · `received` · `refused`
  final String status;
  final String? answerNote;
  final DateTime? recordedAt;

  const StaySettlementPayment({
    required this.id,
    required this.amount,
    required this.method,
    this.reference,
    this.proofUrl,
    required this.status,
    this.answerNote,
    this.recordedAt,
  });

  factory StaySettlementPayment.fromJson(Map<String, dynamic> json) => StaySettlementPayment(
    id: (json['id'] as num).toInt(),
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    method: json['method'] as String? ?? 'cash',
    reference: json['reference'] as String?,
    proofUrl: json['proof_url'] as String?,
    status: json['status'] as String? ?? 'recorded',
    answerNote: json['answer_note'] as String?,
    recordedAt: json['recorded_at'] is String ? DateTime.tryParse(json['recorded_at'] as String) : null,
  );
}

/// One row of «تسويات بانتظارك».
class OpenStaySettlement {
  final int bookingId;
  final String? counterpart;

  /// the hotel a staff member settles for — null for the guest and the hotel's owner
  final String? forBusiness;
  final StaySettlement settlement;

  const OpenStaySettlement({required this.bookingId, this.counterpart, this.forBusiness, required this.settlement});
}
