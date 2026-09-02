/// Mirrors `DisputeSettlementResource` — one "I paid you off-app" proposal.
/// The platform never touches this money; it only records the three
/// statements (propose, accept, receipt) that end the dispute.
class DisputeSettlementProposal {
  final int id;
  final String status;
  final double amount;
  final String? method;
  final String? note;
  final String payerSide;
  final String payeeSide;
  final bool proposedByMe;
  final DateTime? acceptedAt;
  final DateTime? receivedAt;
  final DateTime? createdAt;

  const DisputeSettlementProposal({
    required this.id,
    required this.status,
    required this.amount,
    this.method,
    this.note,
    required this.payerSide,
    required this.payeeSide,
    this.proposedByMe = false,
    this.acceptedAt,
    this.receivedAt,
    this.createdAt,
  });

  bool get isPending => status == 'proposed';

  factory DisputeSettlementProposal.fromJson(Map<String, dynamic> json) {
    final proposedBy = json['proposed_by'] as Map<String, dynamic>? ?? const {};
    return DisputeSettlementProposal(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'proposed',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String?,
      note: json['note'] as String?,
      payerSide: json['payer_side'] as String? ?? 'client',
      payeeSide: json['payee_side'] as String? ?? 'business',
      proposedByMe: proposedBy['is_me'] as bool? ?? false,
      acceptedAt: json['accepted_at'] != null ? DateTime.tryParse(json['accepted_at'] as String) : null,
      receivedAt: json['received_at'] != null ? DateTime.tryParse(json['received_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}
