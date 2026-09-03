import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../booking/application/booking_providers.dart';
import '../../../booking/data/models/booking.dart';
import '../../../cart/application/cart_controller.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../chat/presentation/screens/operation_chat_screen.dart';
import '../../../disputes/application/disputes_providers.dart';
import '../../../disputes/presentation/screens/dispute_detail_screen.dart';
import '../../../disputes/presentation/widgets/dispute_reason_picker.dart';
import '../../../projects/presentation/screens/project_progress_screen.dart';
import '../../../ratings/presentation/widgets/leave_review_sheet.dart';
import '../../application/orders_providers.dart';
import '../../data/models/placed_order.dart';

/// "My orders & bookings" — every placed order (menu/retail checkout) and
/// every booking request the customer has made, each with its own tab.
/// Reachable from AppDrawer; this is the only place either history is
/// visible in the app (checkout/booking creation only ever confirmed the
/// single one just made).
class OrdersAndBookingsScreen extends StatelessWidget {
  const OrdersAndBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.ordersBookingsTitle),
          bottom: TabBar(
            tabs: [Tab(text: l10n.ordersTab), Tab(text: l10n.bookingsTab)],
          ),
        ),
        body: const TabBarView(children: [_OrdersTab(), _BookingsTab()]),
      ),
    );
  }
}

// ─────────────────────────── Orders ───────────────────────────

class _OrdersTab extends ConsumerStatefulWidget {
  const _OrdersTab();

  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myOrdersControllerProvider.notifier).loadMore();
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
    final state = ref.watch(myOrdersControllerProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _ErrorRetry(
        onRetry: () => ref.read(myOrdersControllerProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return Center(child: Text(l10n.ordersEmpty));
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(myOrdersControllerProvider.notifier).load(),
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
          final order = state.items[index];
          return _OrderTile(order: order);
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final PlacedOrder order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _OrderDetailSheet(orderId: order.id),
        ),
        leading: CircleAvatar(
          backgroundImage: order.businessLogoUrl != null
              ? NetworkImage(order.businessLogoUrl!)
              : null,
          child: order.businessLogoUrl == null
              ? const Icon(Icons.storefront_outlined)
              : null,
        ),
        title: Text(order.businessName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${order.itemsCount} · ${order.finalTotal.toStringAsFixed(0)}',
        ),
        trailing: _StatusBadge(label: _orderStatusLabel(order.status, l10n), color: _orderStatusColor(order.status)),
      ),
    );
  }
}

class _OrderDetailSheet extends ConsumerStatefulWidget {
  final int orderId;
  const _OrderDetailSheet({required this.orderId});

  @override
  ConsumerState<_OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends ConsumerState<_OrderDetailSheet> {
  bool _busy = false;

  PlacedOrder? _orderFromState() {
    final items = ref.watch(myOrdersControllerProvider).items;
    for (final o in items) {
      if (o.id == widget.orderId) return o;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // List rows omit `items` (whenLoaded on the backend) — fetch the detail
    // once so this sheet can show the line breakdown.
    ref.read(myOrdersControllerProvider.notifier).loadDetail(widget.orderId);
  }

  Future<void> _cancel(PlacedOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.ordersCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.ordersCancel)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(myOrdersControllerProvider.notifier).cancel(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ordersCancelled)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leaveReview(PlacedOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    final submitted = await showLeaveReviewSheet(
      context,
      operationType: 'order',
      operationId: order.id,
    );
    if (submitted && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ratingsSubmitted)));
    }
  }

  Future<void> _reorder(PlacedOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final result = await ref.read(ordersApiProvider).reorder(order.id);
      await ref.read(cartControllerProvider.notifier).load();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.skipped.isEmpty ? l10n.ordersReordered : l10n.ordersReorderedWithSkipped),
            action: SnackBarAction(
              label: l10n.cartGoToCart,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reportProblem(PlacedOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final dispute = await ref
          .read(disputesApiProvider)
          .openForOrder(order.id, reasonCode: result.reasonCode, reasonText: result.reasonText);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.disputeOpened)));
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DisputeDetailScreen(disputeId: dispute.id)),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = _orderFromState();

    if (order == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(order.businessName ?? '', style: Theme.of(context).textTheme.titleMedium),
              ),
              IconButton(
                tooltip: l10n.chatOpenChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OperationChatScreen(
                      operationType: 'order',
                      operationId: order.id,
                      title: order.businessName ?? l10n.chatTitle,
                    ),
                  ),
                ),
              ),
              _StatusBadge(label: _orderStatusLabel(order.status, l10n), color: _orderStatusColor(order.status)),
            ],
          ),
          const SizedBox(height: 16),
          if (order.items.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${item.qty}× ${item.name}'),
                    ),
                    Text(item.totalPrice.toStringAsFixed(0)),
                  ],
                ),
              ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.cartFinalTotal, style: Theme.of(context).textTheme.titleSmall),
              Text(order.finalTotal.toStringAsFixed(0), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(order.notes!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 20),
          if (order.isCancellable)
            OutlinedButton(
              onPressed: _busy ? null : () => _cancel(order),
              child: Text(l10n.ordersCancel),
            ),
          if (order.status == 'completed') ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _leaveReview(order),
              child: Text(l10n.ratingsLeaveReview),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectProgressScreen(operationType: 'order', operationId: order.id),
              ),
            ),
            child: Text(l10n.projectViewProgress),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _busy ? null : () => _reorder(order),
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.ordersReorder),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : () => _reportProblem(order),
            child: Text(l10n.disputeOpenTitle),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Bookings ───────────────────────────

class _BookingsTab extends ConsumerStatefulWidget {
  const _BookingsTab();

  @override
  ConsumerState<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends ConsumerState<_BookingsTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myBookingsControllerProvider.notifier).loadMore();
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
    final state = ref.watch(myBookingsControllerProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _ErrorRetry(
        onRetry: () => ref.read(myBookingsControllerProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return Center(child: Text(l10n.bookingsEmpty));
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(myBookingsControllerProvider.notifier).load(),
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
          final booking = state.items[index];
          return _BookingTile(booking: booking);
        },
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (_) => _BookingDetailSheet(booking: booking),
        ),
        leading: CircleAvatar(
          backgroundImage: booking.businessLogoUrl != null
              ? NetworkImage(booking.businessLogoUrl!)
              : null,
          child: booking.businessLogoUrl == null
              ? const Icon(Icons.event_available_outlined)
              : null,
        ),
        title: Text(booking.businessName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${booking.serviceName(languageCode)} · ${booking.price.toStringAsFixed(0)}'),
        trailing: _StatusBadge(
          label: _bookingStatusLabel(booking.status, l10n),
          color: _bookingStatusColor(booking.status),
        ),
      ),
    );
  }
}

class _BookingDetailSheet extends ConsumerStatefulWidget {
  final Booking booking;
  const _BookingDetailSheet({required this.booking});

  @override
  ConsumerState<_BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends ConsumerState<_BookingDetailSheet> {
  bool _busy = false;

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.bookingsCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.bookingsCancel)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(myBookingsControllerProvider.notifier).cancel(widget.booking.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingsCancelled)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leaveReview() async {
    final l10n = AppLocalizations.of(context)!;
    final submitted = await showLeaveReviewSheet(
      context,
      operationType: 'booking',
      operationId: widget.booking.id,
    );
    if (submitted && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ratingsSubmitted)));
    }
  }

  Future<void> _reportProblem() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final dispute = await ref
          .read(disputesApiProvider)
          .openForBooking(widget.booking.id, reasonCode: result.reasonCode, reasonText: result.reasonText);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.disputeOpened)));
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DisputeDetailScreen(disputeId: dispute.id)),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final booking = widget.booking;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(booking.businessName ?? '', style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: l10n.chatOpenChat,
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OperationChatScreen(
                        operationType: 'booking',
                        operationId: booking.id,
                        title: booking.businessName ?? l10n.chatTitle,
                      ),
                    ),
                  ),
                ),
                _StatusBadge(
                  label: _bookingStatusLabel(booking.status, l10n),
                  color: _bookingStatusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(booking.serviceName(languageCode), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (booking.startsAt != null)
              Text(_formatRange(booking.startsAt!, booking.endsAt))
            else if (booking.date != null)
              Text('${booking.date!}'.split(' ').first + (booking.time != null ? ' ${booking.time}' : '')),
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(booking.notes!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.cartFinalTotal, style: Theme.of(context).textTheme.titleSmall),
                Text(booking.price.toStringAsFixed(0), style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 20),
            if (booking.isCancellable)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _busy ? null : _cancel,
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.bookingsCancel),
                ),
              ),
            if (booking.status == 'completed')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _busy ? null : _leaveReview,
                  child: Text(l10n.ratingsLeaveReview),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProjectProgressScreen(operationType: 'booking', operationId: booking.id),
                  ),
                ),
                child: Text(l10n.projectViewProgress),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : _reportProblem,
                child: Text(l10n.disputeOpenTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRange(DateTime start, DateTime? end) {
  final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  if (end == null) return startStr;
  final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  return '$startStr → $endStr';
}

// ─────────────────────────── Shared ───────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.commonSomethingWentWrong),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}

String _orderStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'pending' => l10n.orderStatusPending,
  'completed' => l10n.orderStatusCompleted,
  'cancelled' => l10n.orderStatusCancelled,
  _ => status,
};

Color _orderStatusColor(String status) => switch (status) {
  'completed' => AppColors.success,
  'cancelled' => AppColors.error,
  _ => AppColors.warning,
};

String _bookingStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'pending' => l10n.bookingStatusPending,
  'accepted' => l10n.bookingStatusAccepted,
  'rejected' => l10n.bookingStatusRejected,
  'cancelled' => l10n.bookingStatusCancelled,
  'in_progress' => l10n.bookingStatusInProgress,
  'completed' => l10n.bookingStatusCompleted,
  _ => status,
};

Color _bookingStatusColor(String status) => switch (status) {
  'accepted' || 'completed' => AppColors.success,
  'rejected' || 'cancelled' => AppColors.error,
  'in_progress' => AppColors.accentGold,
  _ => AppColors.warning,
};
