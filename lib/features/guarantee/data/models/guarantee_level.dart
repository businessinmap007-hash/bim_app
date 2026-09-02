double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());
double _numOr0(dynamic v) => _num(v) ?? 0;

/// A purchasable coverage tier — mirrors `GuaranteeController::levelPayload()`.
/// `requiredLockedAmount` is what activating this level locks from the
/// wallet; `activeCoverageAmount` is what it actually covers once usable.
class GuaranteeLevel {
  final int id;
  final String code;
  final String nameAr;
  final String? nameEn;
  final String displayName;
  final String targetType;
  final double requiredLockedAmount;
  final double pendingCoverageAmount;
  final double activeCoverageAmount;
  final int requiredCompletedOperations;
  final double requiredTrustScore;
  final int? maxLostDisputes;
  final int? maxLateCancellations;
  final int priority;
  final bool isActive;

  const GuaranteeLevel({
    required this.id,
    required this.code,
    required this.nameAr,
    this.nameEn,
    required this.displayName,
    required this.targetType,
    required this.requiredLockedAmount,
    required this.pendingCoverageAmount,
    required this.activeCoverageAmount,
    this.requiredCompletedOperations = 0,
    this.requiredTrustScore = 0,
    this.maxLostDisputes,
    this.maxLateCancellations,
    this.priority = 0,
    this.isActive = true,
  });

  factory GuaranteeLevel.fromJson(Map<String, dynamic> json) => GuaranteeLevel(
    id: json['id'] as int,
    code: json['code'] as String? ?? '',
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
    displayName: json['display_name'] as String? ?? json['name_ar'] as String? ?? '',
    targetType: json['target_type'] as String? ?? 'client',
    requiredLockedAmount: _numOr0(json['required_locked_amount']),
    pendingCoverageAmount: _numOr0(json['pending_coverage_amount']),
    activeCoverageAmount: _numOr0(json['active_coverage_amount']),
    requiredCompletedOperations: (json['required_completed_operations'] as num?)?.toInt() ?? 0,
    requiredTrustScore: _numOr0(json['required_trust_score']),
    maxLostDisputes: (json['max_lost_disputes'] as num?)?.toInt(),
    maxLateCancellations: (json['max_late_cancellations'] as num?)?.toInt(),
    priority: (json['priority'] as num?)?.toInt() ?? 0,
    isActive: json['is_active'] as bool? ?? true,
  );
}

/// The caller's own guarantee record for one target type — mirrors
/// `GuaranteeController::guaranteePayload()`.
class UserGuarantee {
  final int id;
  final String targetType;
  final String status;
  final bool isUsable;
  final GuaranteeLevel? purchasedLevel;
  final GuaranteeLevel? effectiveLevel;
  final double lockedAmount;
  final double currentCoverageAmount;
  final double usedCoverageAmount;
  final double availableCoverageAmount;
  final int completedOperationsCount;
  final int cancelledOperationsCount;
  final int lateCancellationsCount;
  final int disputesOpenedCount;
  final int disputesLostCount;
  final double trustScore;
  final DateTime? graceUntil;
  final DateTime? activatedAt;

  const UserGuarantee({
    required this.id,
    required this.targetType,
    required this.status,
    this.isUsable = false,
    this.purchasedLevel,
    this.effectiveLevel,
    this.lockedAmount = 0,
    this.currentCoverageAmount = 0,
    this.usedCoverageAmount = 0,
    this.availableCoverageAmount = 0,
    this.completedOperationsCount = 0,
    this.cancelledOperationsCount = 0,
    this.lateCancellationsCount = 0,
    this.disputesOpenedCount = 0,
    this.disputesLostCount = 0,
    this.trustScore = 0,
    this.graceUntil,
    this.activatedAt,
  });

  factory UserGuarantee.fromJson(Map<String, dynamic> json) => UserGuarantee(
    id: json['id'] as int,
    targetType: json['target_type'] as String? ?? 'client',
    status: json['status'] as String? ?? '',
    isUsable: json['is_usable'] as bool? ?? false,
    purchasedLevel: json['purchased_level'] != null
        ? GuaranteeLevel.fromJson(json['purchased_level'] as Map<String, dynamic>)
        : null,
    effectiveLevel: json['effective_level'] != null
        ? GuaranteeLevel.fromJson(json['effective_level'] as Map<String, dynamic>)
        : null,
    lockedAmount: _numOr0(json['locked_amount']),
    currentCoverageAmount: _numOr0(json['current_coverage_amount']),
    usedCoverageAmount: _numOr0(json['used_coverage_amount']),
    availableCoverageAmount: _numOr0(json['available_coverage_amount']),
    completedOperationsCount: (json['completed_operations_count'] as num?)?.toInt() ?? 0,
    cancelledOperationsCount: (json['cancelled_operations_count'] as num?)?.toInt() ?? 0,
    lateCancellationsCount: (json['late_cancellations_count'] as num?)?.toInt() ?? 0,
    disputesOpenedCount: (json['disputes_opened_count'] as num?)?.toInt() ?? 0,
    disputesLostCount: (json['disputes_lost_count'] as num?)?.toInt() ?? 0,
    trustScore: _numOr0(json['trust_score']),
    graceUntil: json['grace_until'] != null ? DateTime.tryParse(json['grace_until'] as String) : null,
    activatedAt: json['activated_at'] != null ? DateTime.tryParse(json['activated_at'] as String) : null,
  );
}

class GuaranteeTransaction {
  final int id;
  final String type;
  final double amount;
  final double coverageAmount;
  final double? balanceBefore;
  final double? balanceAfter;
  final String? reason;
  final DateTime? createdAt;

  const GuaranteeTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.coverageAmount,
    this.balanceBefore,
    this.balanceAfter,
    this.reason,
    this.createdAt,
  });

  factory GuaranteeTransaction.fromJson(Map<String, dynamic> json) => GuaranteeTransaction(
    id: json['id'] as int,
    type: json['type'] as String? ?? '',
    amount: _numOr0(json['amount']),
    coverageAmount: _numOr0(json['coverage_amount']),
    balanceBefore: _num(json['balance_before']),
    balanceAfter: _num(json['balance_after']),
    reason: json['reason'] as String?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
