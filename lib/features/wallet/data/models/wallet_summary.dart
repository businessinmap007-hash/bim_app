/// Mirrors `WalletController::show()` — the wallet is auto-provisioned
/// (`getOrCreateWallet`) on first read, so this never 404s for a signed-in
/// user; a brand-new wallet just comes back all zeros.
class WalletSummary {
  final double balance;
  final double lockedBalance;
  final double availableBalance;
  final double totalIn;
  final double totalOut;
  final String status;
  final DateTime? lastActivityAt;

  const WalletSummary({
    required this.balance,
    required this.lockedBalance,
    required this.availableBalance,
    required this.totalIn,
    required this.totalOut,
    required this.status,
    this.lastActivityAt,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
    balance: (json['balance'] as num?)?.toDouble() ?? 0,
    lockedBalance: (json['locked_balance'] as num?)?.toDouble() ?? 0,
    availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0,
    totalIn: (json['total_in'] as num?)?.toDouble() ?? 0,
    totalOut: (json['total_out'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'active',
    lastActivityAt: json['last_activity_at'] != null
        ? DateTime.tryParse(json['last_activity_at'] as String)
        : null,
  );
}
