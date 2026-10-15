/// A friend's co-guarantee of an operation — mirrors one `guarantor` of Api\V2\OperationGuarantorController.
///
/// The friend's guarantee coverage is FROZEN for the operation when he accepts and returned when it ends; it is never
/// charged. The same flow serves a booking, a health visit, an order and a trip reservation.
class Guarantor {
  static const invited = 'invited';
  static const accepted = 'accepted';
  static const declined = 'declined';
  static const cancelled = 'cancelled';
  static const released = 'released';

  final int id;
  final String status;
  final double coveredAmount;
  final int? guarantorId;
  final String? guarantorName;

  /// Only on a request read by the friend himself.
  final String? requesterName;
  final double availableCoverage;

  const Guarantor({
    required this.id,
    required this.status,
    this.coveredAmount = 0,
    this.guarantorId,
    this.guarantorName,
    this.requesterName,
    this.availableCoverage = 0,
  });

  bool get isInvited => status == invited;

  factory Guarantor.fromJson(Map<String, dynamic> json) {
    final who = json['guarantor'] as Map<String, dynamic>?;
    final requester = json['requester'] as Map<String, dynamic>?;

    return Guarantor(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? invited,
      coveredAmount: (json['covered_amount'] as num?)?.toDouble() ?? 0,
      guarantorId: (who?['id'] as num?)?.toInt(),
      guarantorName: who?['name'] as String?,
      requesterName: requester?['name'] as String?,
      availableCoverage: (json['available_coverage'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// What an operation still lacks after the customer's own guarantee, his friends' and his wallet.
class GuarantorNeed {
  final double deposit;
  final double combinedCoverage;
  final double needed;

  const GuarantorNeed({required this.deposit, required this.combinedCoverage, required this.needed});

  static GuarantorNeed? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;

    return GuarantorNeed(
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
      combinedCoverage: (json['combined_coverage'] as num?)?.toDouble() ?? 0,
      needed: (json['needed'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// The friends of one operation and what is still missing.
class GuarantorList {
  final List<Guarantor> items;
  final GuarantorNeed? need;

  const GuarantorList({this.items = const [], this.need});
}
