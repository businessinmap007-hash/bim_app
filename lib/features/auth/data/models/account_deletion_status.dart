/// GET /account/deletion — see Api\V2\AccountDeletionController::eligibility.
class DeletionBlocker {
  final String code;
  final String message;
  const DeletionBlocker({required this.code, required this.message});

  factory DeletionBlocker.fromJson(Map<String, dynamic> json) =>
      DeletionBlocker(code: json['code'] as String, message: json['message'] as String);
}

class AccountDeletionStatus {
  final bool canDelete;
  final List<DeletionBlocker> blockers;
  final int graceDays;
  final bool pendingDeletion;

  const AccountDeletionStatus({
    required this.canDelete,
    required this.blockers,
    required this.graceDays,
    required this.pendingDeletion,
  });

  factory AccountDeletionStatus.fromJson(Map<String, dynamic> json) => AccountDeletionStatus(
    canDelete: json['can_delete'] as bool,
    blockers: (json['blockers'] as List<dynamic>? ?? [])
        .map((e) => DeletionBlocker.fromJson(e as Map<String, dynamic>))
        .toList(),
    graceDays: json['grace_days'] as int,
    pendingDeletion: json['pending_deletion'] as bool,
  );
}
