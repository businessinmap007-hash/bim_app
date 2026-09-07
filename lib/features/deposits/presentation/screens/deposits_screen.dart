import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/deposits_providers.dart';
import '../../data/models/deposit.dart';

const _statuses = ['frozen', 'in_progress', 'released', 'refunded', 'split'];

/// The signed-in account's own escrow deposits — see them and what happened
/// to each. Read-only: release/refund/split are BookingDepositService's and
/// DisputeService's own actions, never triggered from here.
class DepositsScreen extends ConsumerStatefulWidget {
  const DepositsScreen({super.key});

  @override
  ConsumerState<DepositsScreen> createState() => _DepositsScreenState();
}

class _DepositsScreenState extends ConsumerState<DepositsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(depositsControllerProvider.notifier).loadMore();
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
    final state = ref.watch(depositsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.depositsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              height: 40,
              child: MouseWheelHorizontalScroll(
                builder: (context, controller) => ListView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(l10n.depositsAllStatuses),
                        selected: state.status == null,
                        onSelected: (_) => ref.read(depositsControllerProvider.notifier).filterByStatus(null),
                      ),
                    ),
                    for (final s in _statuses)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_statusLabel(s, l10n)),
                          selected: state.status == s,
                          onSelected: (_) => ref.read(depositsControllerProvider.notifier).filterByStatus(s),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(depositsControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.depositsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(depositsControllerProvider.notifier).load(),
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
                        final deposit = state.items[index];
                        return _DepositTile(
                          deposit: deposit,
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => _DepositDetailSheet(deposit: deposit),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DepositTile extends StatelessWidget {
  final Deposit deposit;
  final VoidCallback onTap;
  const _DepositTile({required this.deposit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.lock_outline),
        title: Text(deposit.myRole == 'client' ? l10n.depositRoleClient : l10n.depositRoleBusiness),
        subtitle: Text(_statusLabel(deposit.status, l10n)),
        trailing: Text(
          deposit.myAmount.toStringAsFixed(2),
          style: TextStyle(color: _statusColor(deposit.status), fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _DepositDetailSheet extends StatelessWidget {
  final Deposit deposit;
  const _DepositDetailSheet({required this.deposit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deposit.myRole == 'client' ? l10n.depositRoleClient : l10n.depositRoleBusiness,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    deposit.myAmount.toStringAsFixed(2),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: _statusColor(deposit.status)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(_statusLabel(deposit.status, l10n), style: TextStyle(color: _statusColor(deposit.status))),
              const SizedBox(height: 12),
              _Row(label: l10n.depositTotalAmount, value: deposit.totalAmount.toStringAsFixed(2)),
              _Row(
                label: l10n.depositClientShare,
                value: '${deposit.clientAmount.toStringAsFixed(2)} (${deposit.clientPercent}%)',
              ),
              _Row(
                label: l10n.depositBusinessShare,
                value: '${deposit.businessAmount.toStringAsFixed(2)} (${deposit.businessPercent}%)',
              ),
              if (deposit.counterpartyName != null)
                _Row(label: l10n.depositCounterparty, value: deposit.counterpartyName!),
              if (deposit.bookingId != null)
                _Row(label: l10n.depositBookingLabel, value: '#${deposit.bookingId}'),
              if (deposit.createdAt != null)
                _Row(label: l10n.depositCreatedAt, value: _formatDate(deposit.createdAt!)),
              if (deposit.releasedAt != null)
                _Row(label: l10n.depositReleasedAt, value: _formatDate(deposit.releasedAt!)),
              if (deposit.refundedAt != null)
                _Row(label: l10n.depositRefundedAt, value: _formatDate(deposit.refundedAt!)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'frozen' => l10n.depositStatusFrozen,
  'in_progress' => l10n.depositStatusInProgress,
  'released' => l10n.depositStatusReleased,
  'refunded' => l10n.depositStatusRefunded,
  'split' => l10n.depositStatusSplit,
  _ => status,
};

Color _statusColor(String status) => switch (status) {
  'released' => AppColors.success,
  'refunded' || 'split' => AppColors.warning,
  _ => AppColors.warning,
};
