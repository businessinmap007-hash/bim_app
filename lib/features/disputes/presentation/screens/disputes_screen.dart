import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/disputes_providers.dart';
import '../../data/models/dispute.dart';
import 'dispute_detail_screen.dart';
import 'dispute_obligations_screen.dart';

class DisputesScreen extends ConsumerStatefulWidget {
  const DisputesScreen({super.key});

  @override
  ConsumerState<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends ConsumerState<DisputesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(myDisputesControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myDisputesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.disputesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: l10n.disputeObligationsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DisputeObligationsScreen()),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(myDisputesControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.disputesEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myDisputesControllerProvider.notifier).load(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final dispute = state.items[index];
                  return _DisputeTile(
                    dispute: dispute,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DisputeDetailScreen(disputeId: dispute.id)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _DisputeTile extends StatelessWidget {
  final Dispute dispute;
  final VoidCallback onTap;
  const _DisputeTile({required this.dispute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.gavel_outlined)),
        title: Text(dispute.counterparty?.name ?? '#${dispute.id}'),
        subtitle: Text(
          '${dispute.isOpener ? l10n.disputeRoleOpener : l10n.disputeRoleRespondent}\n'
          '${disputeStatusLabel(dispute.status, l10n)}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String disputeStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'open' => l10n.disputeStatusOpen,
  'mutual_resolution' => l10n.disputeStatusMutualResolution,
  'under_review' => l10n.disputeStatusUnderReview,
  'resolved' => l10n.disputeStatusResolved,
  'closed' => l10n.disputeStatusClosed,
  'cancelled' => l10n.disputeStatusCancelled,
  'expired' => l10n.disputeStatusExpired,
  _ => status,
};
