import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_orders_providers.dart';
import '../../data/models/placed_order.dart';

/// The business's incoming-order queue — Api\V2\OrderController's business*
/// endpoints. Dine-in/pickup/delivery menu orders only (never bookings,
/// which stay on the booking flow). Reached from Service settings.
class BusinessOrdersScreen extends ConsumerStatefulWidget {
  const BusinessOrdersScreen({super.key});

  @override
  ConsumerState<BusinessOrdersScreen> createState() => _BusinessOrdersScreenState();
}

class _BusinessOrdersScreenState extends ConsumerState<BusinessOrdersScreen> {
  final _scrollController = ScrollController();
  String? _status;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(businessOrdersControllerProvider.notifier).loadMore();
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
    final state = ref.watch(businessOrdersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessOrdersTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.businessOrdersFilterAll),
                  selected: _status == null,
                  onSelected: (_) {
                    setState(() => _status = null);
                    ref.read(businessOrdersControllerProvider.notifier).load();
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.businessOrdersFilterPending),
                  selected: _status == 'pending',
                  onSelected: (_) {
                    setState(() => _status = 'pending');
                    ref.read(businessOrdersControllerProvider.notifier).load(status: 'pending');
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.businessOrdersFilterCompleted),
                  selected: _status == 'completed',
                  onSelected: (_) {
                    setState(() => _status = 'completed');
                    ref.read(businessOrdersControllerProvider.notifier).load(status: 'completed');
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.businessOrdersFilterCancelled),
                  selected: _status == 'cancelled',
                  onSelected: (_) {
                    setState(() => _status = 'cancelled');
                    ref.read(businessOrdersControllerProvider.notifier).load(status: 'cancelled');
                  },
                ),
              ],
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
                          onPressed: () => ref.read(businessOrdersControllerProvider.notifier).load(status: _status),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.businessOrdersEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(businessOrdersControllerProvider.notifier).load(status: _status),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final order = state.items[index];
                        return _OrderTile(
                          order: order,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BusinessOrderDetailScreen(orderId: order.id)),
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

class _OrderTile extends StatelessWidget {
  final PlacedOrder order;
  final VoidCallback onTap;
  const _OrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text('#${order.id} · ${order.customerName ?? ''}'),
        subtitle: Text(
          [
            if (order.tableLabel != null) order.tableLabel!,
            l10n.businessOrdersItemsCount(order.itemsCount),
          ].join(' · '),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(order.finalTotal.toStringAsFixed(2)),
            const SizedBox(height: 4),
            _StatusBadge(order: order),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PlacedOrder order;
  const _StatusBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch ((order.status, order.prepStatus)) {
      ('cancelled', _) => (l10n.businessOrdersStatusCancelled, AppColors.error),
      ('completed', _) => (l10n.businessOrdersStatusCompleted, AppColors.success),
      (_, 'ready') => (l10n.businessOrdersStatusReady, AppColors.success),
      (_, 'preparing') => (l10n.businessOrdersStatusPreparing, AppColors.accentGold),
      (_, 'accepted') => (l10n.businessOrdersStatusAccepted, AppColors.accentGold),
      _ => (l10n.businessOrdersStatusPending, Theme.of(context).hintColor),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
    );
  }
}

class BusinessOrderDetailScreen extends ConsumerWidget {
  final int orderId;
  const BusinessOrderDetailScreen({super.key, required this.orderId});

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.businessOrdersRejectConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.businessOrdersReject)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(businessOrderDetailControllerProvider(orderId).notifier).reject();
      ref.read(businessOrdersControllerProvider.notifier).load();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _accept(BuildContext context, WidgetRef ref, PlacedOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    var acceptWithoutDeposit = false;
    if (order.needsExplicitDepositDecision) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.businessOrdersNoDepositWarning),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.businessOrdersAccept)),
          ],
        ),
      );
      if (confirmed != true) return;
      acceptWithoutDeposit = true;
    }
    try {
      await ref
          .read(businessOrderDetailControllerProvider(orderId).notifier)
          .accept(acceptWithoutDeposit: acceptWithoutDeposit);
      ref.read(businessOrdersControllerProvider.notifier).load();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _advance(BuildContext context, WidgetRef ref, bool toReady) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final notifier = ref.read(businessOrderDetailControllerProvider(orderId).notifier);
      if (toReady) {
        await notifier.markReady();
      } else {
        await notifier.markPreparing();
      }
      ref.read(businessOrdersControllerProvider.notifier).load();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessOrderDetailControllerProvider(orderId));
    final order = state.order;

    return Scaffold(
      appBar: AppBar(title: Text('#$orderId')),
      body: state.isLoading && order == null
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(order.customerName ?? '', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    _StatusBadge(order: order),
                  ],
                ),
                if (order.customerPhone != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(order.customerPhone!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                if (order.tableLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(order.tableLabel!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text(l10n.businessOrdersItemsSection, style: Theme.of(context).textTheme.titleSmall),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text('${item.qty}×'),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.name)),
                        Text(item.totalPrice.toStringAsFixed(2)),
                      ],
                    ),
                  ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.businessOrdersTotal, style: Theme.of(context).textTheme.titleSmall),
                    Text(order.finalTotal.toStringAsFixed(2), style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l10n.businessOrdersNotes, style: Theme.of(context).textTheme.titleSmall),
                  Text(order.notes!),
                ],
                if (order.depositRequired) ...[
                  const SizedBox(height: 12),
                  Text(
                    order.depositCovered ? l10n.businessOrdersDepositCovered : l10n.businessOrdersDepositUncovered,
                    style: TextStyle(color: order.depositCovered ? AppColors.success : AppColors.error),
                  ),
                ],
                const SizedBox(height: 24),
                if (state.isBusy)
                  const Center(child: CircularProgressIndicator())
                else if (order.status == 'pending' && order.prepStatus == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _reject(context, ref),
                          child: Text(l10n.businessOrdersReject),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _accept(context, ref, order),
                          child: Text(l10n.businessOrdersAccept),
                        ),
                      ),
                    ],
                  ),
                ] else if (order.prepStatus == 'accepted')
                  FilledButton(
                    onPressed: () => _advance(context, ref, false),
                    child: Text(l10n.businessOrdersMarkPreparing),
                  )
                else if (order.prepStatus == 'preparing')
                  FilledButton(
                    onPressed: () => _advance(context, ref, true),
                    child: Text(l10n.businessOrdersMarkReady),
                  ),
              ],
            ),
    );
  }
}
