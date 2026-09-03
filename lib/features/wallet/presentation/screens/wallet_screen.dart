import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/wallet_providers.dart';
import '../../data/models/wallet_transaction.dart';

/// Balance + ledger, read-only — see WalletApi's doc comment for why
/// deposit/withdraw/transfer/PIN aren't wired up here.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The summary/transactions providers aren't autoDispose, so a balance
    // fetched on an earlier visit would otherwise sit stale forever —
    // opening this screen always re-fetches, not just the first time.
    Future.microtask(_refresh);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(walletTransactionsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(walletSummaryProvider);
    await ref.read(walletTransactionsControllerProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(walletSummaryProvider);
    final txState = ref.watch(walletTransactionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walletTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.commonRefresh,
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          children: [
            summaryAsync.when(
              data: (summary) => Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.walletAvailableBalance,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.availableBalance.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (summary.lockedBalance > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.walletLockedBalance}: ${summary.lockedBalance.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Text(l10n.commonSomethingWentWrong),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(walletSummaryProvider),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(l10n.walletTransactionsTitle, style: Theme.of(context).textTheme.titleSmall),
            ),
            if (txState.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (txState.error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: OutlinedButton(
                    onPressed: () => ref.read(walletTransactionsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ),
              )
            else if (txState.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text(l10n.walletTransactionsEmpty)),
              )
            else ...[
              for (final tx in txState.items) _TransactionTile(tx: tx),
              if (txState.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = tx.isCredit ? AppColors.success : AppColors.error;
    final sign = tx.isCredit ? '+' : '-';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: color,
        ),
      ),
      title: Text(
        tx.note?.isNotEmpty == true ? tx.note! : tx.type,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: tx.createdAt != null ? Text(_formatDate(tx.createdAt!)) : null,
      trailing: Text(
        '$sign${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
