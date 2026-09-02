/// Mirrors `FineResource` — a platform fine as the fined user sees it. There
/// is no levy/decide/collect here (admin-only, on the backend) — just read
/// your own fines and contest one while its window is open.
class Fine {
  final int id;
  final double amount;
  final double frozenAmount;
  final double collectedAmount;
  final double shortfall;
  final String? reason;
  final String status;
  final bool isAppealable;
  final bool canAppeal;
  final DateTime? appealDeadlineAt;
  final bool hasPendingAppeal;
  final DateTime? createdAt;

  const Fine({
    required this.id,
    required this.amount,
    required this.frozenAmount,
    required this.collectedAmount,
    required this.shortfall,
    this.reason,
    required this.status,
    required this.isAppealable,
    required this.canAppeal,
    this.appealDeadlineAt,
    required this.hasPendingAppeal,
    this.createdAt,
  });

  bool get showAppealForm => canAppeal && !hasPendingAppeal;

  factory Fine.fromJson(Map<String, dynamic> json) => Fine(
    id: json['id'] as int,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    frozenAmount: (json['frozen_amount'] as num?)?.toDouble() ?? 0,
    collectedAmount: (json['collected_amount'] as num?)?.toDouble() ?? 0,
    shortfall: (json['shortfall'] as num?)?.toDouble() ?? 0,
    reason: json['reason'] as String?,
    status: json['status'] as String? ?? 'frozen',
    isAppealable: json['is_appealable'] as bool? ?? false,
    canAppeal: json['can_appeal'] as bool? ?? false,
    appealDeadlineAt: json['appeal_deadline_at'] != null
        ? DateTime.tryParse(json['appeal_deadline_at'] as String)
        : null,
    hasPendingAppeal: json['has_pending_appeal'] as bool? ?? false,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
