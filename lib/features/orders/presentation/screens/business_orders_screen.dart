import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../delivery/application/delivery_providers.dart';
import '../../../delivery/presentation/screens/assign_driver_screen.dart';
import '../../../delivery/presentation/screens/token_qr_screen.dart';
import '../../application/business_orders_providers.dart';
import '../../data/models/placed_order.dart';
import '../widgets/order_tracker_timeline.dart';

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

  /// A specific line turned out unavailable — applies whatever the customer
  /// chose at checkout (Order.out_of_stock_policy). Never guesses: with no
  /// stated policy, points the business at the order chat instead.
  Future<void> _markItemUnavailable(BuildContext context, WidgetRef ref, PlacedOrder order, OrderLineItem item) async {
    final l10n = AppLocalizations.of(context)!;

    if (order.outOfStockPolicy == null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.businessOrdersItemUnavailableTitle),
          content: Text(l10n.businessOrdersItemUnavailableNoPolicy),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonOk))],
        ),
      );
      return;
    }

    String? note;
    if (order.outOfStockPolicy == 'substitute') {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.businessOrdersItemUnavailableTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.businessOrdersItemUnavailableSubstituteNoteLabel,
              hintText: l10n.businessOrdersItemUnavailableSubstituteNoteHint,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.businessOrdersItemUnavailable)),
          ],
        ),
      );
      if (confirmed != true || controller.text.trim().isEmpty) return;
      note = controller.text.trim();
    } else {
      final message = order.outOfStockPolicy == 'cancel'
          ? l10n.businessOrdersItemUnavailableCancelConfirm(order.id)
          : l10n.businessOrdersItemUnavailableRemoveConfirm;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.businessOrdersItemUnavailableTitle),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.businessOrdersItemUnavailable)),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      await ref.read(businessOrderDetailControllerProvider(orderId).notifier).markItemUnavailable(item.id, note: note);
      ref.read(businessOrdersControllerProvider.notifier).load();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.businessOrdersItemUnavailableDone)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  /// Pickup/dine-in only -- "the customer picked it up" / "the table was
  /// served". A delivery order completes through the QR handover instead
  /// (see AssignDriverScreen / the customer's own confirm-delivery scan).
  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(businessOrderDetailControllerProvider(orderId).notifier).complete();
      ref.read(businessOrdersControllerProvider.notifier).load();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _confirmPayment(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(businessOrderDetailControllerProvider(orderId).notifier).confirmPayment();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _advance(BuildContext context, WidgetRef ref, bool toReady, PlacedOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final notifier = ref.read(businessOrderDetailControllerProvider(orderId).notifier);
      if (toReady) {
        await notifier.markReady();
      } else {
        await notifier.markPreparing();
      }
      ref.read(businessOrdersControllerProvider.notifier).load();

      // A ready DELIVERY order needs someone to carry it — open the
      // assignment screen right away instead of leaving the merchant to
      // find it later. Pickup/dine-in orders need no driver at all.
      if (toReady && order.fulfillmentType == 'delivery' && context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AssignDriverScreen(orderId: orderId)),
        );
        // The pushed screen changed delivery_stage server-side without this
        // screen's own cached order ever hearing about it.
        if (context.mounted) ref.read(businessOrderDetailControllerProvider(orderId).notifier).load();
      }
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
      appBar: AppBar(
        title: Text('#$orderId'),
        actions: [
          // No push infra behind delivery_stage - a driver's pickup/delivery
          // scan on a different device never reaches this screen on its
          // own, see the timeline right below. Manual refresh, not a poll.
          IconButton(
            tooltip: l10n.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(businessOrderDetailControllerProvider(orderId).notifier).load(),
          ),
        ],
      ),
      body: state.isLoading && order == null
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : RefreshIndicator(
              onRefresh: () => ref.read(businessOrderDetailControllerProvider(orderId).notifier).load(),
              child: ListView(
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
                if (order.fulfillmentType == 'pickup' && order.pickupAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${l10n.cartPickupTimeLabel}: ${_formatPickupAt(context, order.pickupAt!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                const SizedBox(height: 16),
                OrderTrackerTimeline(order: order),
                const SizedBox(height: 8),
                Text(l10n.businessOrdersItemsSection, style: Theme.of(context).textTheme.titleSmall),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${item.qty}×'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.name,
                                style: item.isRemoved
                                    ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Theme.of(context).hintColor,
                                      )
                                    : null,
                              ),
                            ),
                            if (!item.isRemoved) Text(item.totalPrice.toStringAsFixed(2)),
                            if (item.resolution == null &&
                                order.status == 'pending' &&
                                order.prepStatus != 'ready' &&
                                !state.isBusy)
                              IconButton(
                                tooltip: l10n.businessOrdersItemUnavailable,
                                icon: const Icon(Icons.remove_shopping_cart_outlined, size: 20),
                                onPressed: () => _markItemUnavailable(context, ref, order, item),
                              ),
                          ],
                        ),
                        if (item.isRemoved)
                          Text(l10n.orderLineRemoved, style: TextStyle(color: AppColors.error, fontSize: 12))
                        else if (item.isSubstituted)
                          Text(
                            l10n.orderLineSubstituted(item.resolutionNote ?? ''),
                            style: TextStyle(color: AppColors.accentGold, fontSize: 12),
                          ),
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
                if (order.status != 'cancelled' && order.isCashPayment) ...[
                  const Divider(height: 24),
                  Text(l10n.paymentConfirmSectionTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.paymentConfirmCustomerStatusLabel, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        order.customerPaymentConfirmedAt != null
                            ? l10n.paymentConfirmStatusConfirmed
                            : l10n.paymentConfirmStatusPending,
                        style: TextStyle(
                          fontSize: 12,
                          color: order.customerPaymentConfirmedAt != null ? AppColors.success : Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  if (order.fulfillmentType == 'delivery')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.paymentConfirmDriverStatusLabel, style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          order.driverPaymentConfirmedAt != null
                              ? l10n.paymentConfirmStatusConfirmed
                              : l10n.paymentConfirmStatusPending,
                          style: TextStyle(
                            fontSize: 12,
                            color: order.driverPaymentConfirmedAt != null ? AppColors.success : Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (order.merchantPaymentConfirmedAt != null)
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(l10n.paymentConfirmMerchantConfirmed, style: TextStyle(color: AppColors.success)),
                      ],
                    )
                  else
                    OutlinedButton(
                      onPressed: state.isBusy ? null : () => _confirmPayment(context, ref),
                      child: Text(l10n.paymentConfirmMerchantButton),
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
                    onPressed: () => _advance(context, ref, false, order),
                    child: Text(l10n.businessOrdersMarkPreparing),
                  )
                else if (order.prepStatus == 'preparing')
                  FilledButton(
                    onPressed: () => _advance(context, ref, true, order),
                    child: Text(l10n.businessOrdersMarkReady),
                  )
                else if (order.status == 'pending' && order.prepStatus == 'ready' && order.fulfillmentType != 'delivery')
                  FilledButton(
                    onPressed: () => _complete(context, ref),
                    child: Text(
                      order.fulfillmentType == 'dine_in'
                          ? l10n.orderTrackerCompletedDineIn
                          : l10n.orderTrackerCompletedPickup,
                    ),
                  )
                // Ready, delivery, and still nobody assigned — the merchant
                // dismissed the auto-opened assignment screen (or it's an
                // order that was already ready before this build). Give
                // them a way back in rather than a one-shot-only prompt.
                else if (order.prepStatus == 'ready' &&
                    order.fulfillmentType == 'delivery' &&
                    order.deliveryStage == null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delivery_dining_outlined),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AssignDriverScreen(orderId: orderId)),
                      );
                      if (context.mounted) {
                        ref.read(businessOrderDetailControllerProvider(orderId).notifier).load();
                      }
                    },
                    label: Text(l10n.deliveryAssignDriverTitle),
                  )
                // Assigned but not yet picked up — issuePickupToken() is
                // idempotent while the order stays in this stage (returns
                // the SAME code), so re-showing it here is always safe: it
                // never invalidates a code the driver might still scan from
                // wherever they saw it the first time.
                else if (order.deliveryStage == 'assigned')
                  OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_2),
                    onPressed: () async {
                      final l10n = AppLocalizations.of(context)!;
                      try {
                        final token = await ref.read(deliveryApiProvider).issuePickupToken(orderId);
                        if (context.mounted) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TokenQrScreen(
                                title: l10n.deliveryPickupQrTitle,
                                subtitle: l10n.deliveryPickupQrHintGeneric,
                                token: token,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                        }
                      }
                    },
                    label: Text(l10n.deliveryShowPickupQrAgain),
                  ),
              ],
              ),
            ),
    );
  }
}

String _formatPickupAt(BuildContext context, DateTime pickupAt) {
  final l10n = MaterialLocalizations.of(context);
  return '${l10n.formatCompactDate(pickupAt)} · ${l10n.formatTimeOfDay(TimeOfDay.fromDateTime(pickupAt))}';
}
