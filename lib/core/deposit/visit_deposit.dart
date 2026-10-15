/// «عربون الجدية» of one health visit — a clinic appointment, a lab/radiology order or a hospital procedure.
///
/// Mirrors the `deposit` key every such visit carries (VisitDepositService::stateFor): what the business's terms
/// ask of it while it is still ahead (`quoted`), and where the deposit stands once secured. The deposit is never
/// confiscated and never stops an account — only an opened dispute does.
class VisitDeposit {
  static const quoted = 'quoted';
  static const held = 'held';
  static const pending = 'pending';
  static const received = 'received';
  static const waived = 'waived';
  static const released = 'released';
  static const refunded = 'refunded';
  static const voided = 'void';
  static const disputed = 'disputed';
  static const resolved = 'resolved';

  /// `wallet` (frozen in the wallets) or `external` (paid to the business outside the platform).
  final String mode;
  final String status;

  /// The patient's deposit, and what the business freezes against it (wallet mode only).
  final double amount;
  final double counterAmount;

  /// How much of each side's share stands on its guarantee coverage instead of its wallet.
  final double guaranteeAmount;
  final double businessGuaranteeAmount;

  /// `cash` or `transfer` — an external deposit the business confirmed.
  final String? method;
  final int? disputeId;

  const VisitDeposit({
    required this.mode,
    required this.status,
    required this.amount,
    this.counterAmount = 0,
    this.guaranteeAmount = 0,
    this.businessGuaranteeAmount = 0,
    this.method,
    this.disputeId,
  });

  bool get isExternal => mode == 'external';

  /// Nothing to show: a deposit of a visit that did not happen and never moved.
  bool get isHidden => status == voided;

  static VisitDeposit? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final amount = (json['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return null;

    return VisitDeposit(
      mode: json['mode'] as String? ?? 'wallet',
      status: json['status'] as String? ?? quoted,
      amount: amount,
      counterAmount: (json['counter_amount'] as num?)?.toDouble() ?? 0,
      guaranteeAmount: (json['guarantee_amount'] as num?)?.toDouble() ?? 0,
      businessGuaranteeAmount: (json['business_guarantee_amount'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String?,
      disputeId: (json['dispute_id'] as num?)?.toInt(),
    );
  }
}

/// The three kinds of visit that may carry a deposit, with the path pieces the API names them by.
enum VisitKind {
  clinicAppointment('clinic-appointment', 'clinic-appointments'),
  investigationOrder('investigation-order', 'investigation-orders'),
  procedureRequest('procedure-request', 'procedure-requests'),

  /// a menu / retail order: the cover of the whole order, frozen when the business accepts
  order('order', 'orders'),

  /// a seat / cargo reservation on a carrier's leg
  tripReservation('trip-reservation', 'schedules/reservations');

  /// the `{kind}` of the shared dispute door
  final String slug;

  /// the business-side path segment the answers live under
  final String businessPath;

  const VisitKind(this.slug, this.businessPath);
}
