/// A business's own Fawry merchant sub-account status — see
/// Api\V2\MerchantAccountController::status /
/// MerchantAccountRequestService::statusFor. Provisioning itself is
/// admin-only; this app only shows status and lets the business apply.
class MerchantAccountStatus {
  final bool hasAccount;
  final bool routingEnabled;
  final bool pendingRequest;
  final String? requestStatus;

  const MerchantAccountStatus({
    required this.hasAccount,
    required this.routingEnabled,
    required this.pendingRequest,
    this.requestStatus,
  });

  factory MerchantAccountStatus.fromJson(Map<String, dynamic> json) => MerchantAccountStatus(
    hasAccount: json['has_account'] as bool,
    routingEnabled: json['routing_enabled'] as bool,
    pendingRequest: json['pending_request'] as bool,
    requestStatus: json['request_status'] as String?,
  );
}
