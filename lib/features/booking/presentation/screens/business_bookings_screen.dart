import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_bookings_providers.dart';
import '../../data/models/booking.dart';

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'pending' => l10n.bookingStatusPending,
  'accepted' => l10n.bookingStatusAccepted,
  'rejected' => l10n.bookingStatusRejected,
  'cancelled' => l10n.bookingStatusCancelled,
  'in_progress' => l10n.bookingStatusInProgress,
  'completed' => l10n.bookingStatusCompleted,
  _ => status,
};

Color _statusColor(String status) => switch (status) {
  'accepted' || 'completed' => AppColors.success,
  'rejected' || 'cancelled' => AppColors.error,
  'in_progress' => AppColors.accentGold,
  _ => AppColors.warning,
};

/// The business's incoming-booking queue — Api\V2\BookingController's
/// scope=business. Reached from Service settings, mirrors
/// BusinessOrdersScreen's own shape (filter chips + list + detail screen).
class BusinessBookingsScreen extends ConsumerStatefulWidget {
  const BusinessBookingsScreen({super.key});

  @override
  ConsumerState<BusinessBookingsScreen> createState() => _BusinessBookingsScreenState();
}

class _BusinessBookingsScreenState extends ConsumerState<BusinessBookingsScreen> {
  final _scrollController = ScrollController();
  String? _status;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(businessBookingsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setStatus(String? status) {
    setState(() => _status = status);
    ref.read(businessBookingsControllerProvider.notifier).load(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessBookingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessBookingsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.businessBookingsFilterAll),
                  selected: _status == null,
                  onSelected: (_) => _setStatus(null),
                ),
                ChoiceChip(
                  label: Text(l10n.businessBookingsFilterPending),
                  selected: _status == 'pending',
                  onSelected: (_) => _setStatus('pending'),
                ),
                ChoiceChip(
                  label: Text(l10n.businessBookingsFilterAccepted),
                  selected: _status == 'accepted',
                  onSelected: (_) => _setStatus('accepted'),
                ),
                ChoiceChip(
                  label: Text(l10n.businessBookingsFilterInProgress),
                  selected: _status == 'in_progress',
                  onSelected: (_) => _setStatus('in_progress'),
                ),
                ChoiceChip(
                  label: Text(l10n.businessBookingsFilterCompleted),
                  selected: _status == 'completed',
                  onSelected: (_) => _setStatus('completed'),
                ),
                ChoiceChip(
                  label: Text(l10n.businessBookingsFilterCancelled),
                  selected: _status == 'cancelled',
                  onSelected: (_) => _setStatus('cancelled'),
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
                          onPressed: () => ref.read(businessBookingsControllerProvider.notifier).load(status: _status),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.businessBookingsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(businessBookingsControllerProvider.notifier).load(status: _status),
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
                        final booking = state.items[index];
                        return _BookingTile(
                          booking: booking,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BusinessBookingDetailScreen(bookingId: booking.id)),
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

class _BookingTile extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  const _BookingTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final subtitleParts = <String>[
      if (booking.customerName != null) booking.customerName!,
      if (booking.bookableLabel != null) booking.bookableLabel!,
      if (booking.startsAt != null) booking.startsAt!.toLocal().toString().split('.').first,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text('#${booking.id} · ${booking.serviceName(locale)}'),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(booking.price.toStringAsFixed(2)),
            const SizedBox(height: 4),
            Chip(
              label: Text(_statusLabel(booking.status, l10n), style: const TextStyle(fontSize: 11)),
              backgroundColor: _statusColor(booking.status).withValues(alpha: 0.12),
              labelStyle: TextStyle(color: _statusColor(booking.status)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessBookingDetailScreen extends ConsumerWidget {
  final int bookingId;
  const BusinessBookingDetailScreen({super.key, required this.bookingId});

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.businessBookingsRejectConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.businessBookingsReject)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(context, ref, () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).reject());
  }

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
      ref.read(businessBookingsControllerProvider.notifier).load();
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
    final locale = Localizations.localeOf(context).languageCode;
    final state = ref.watch(businessBookingDetailControllerProvider(bookingId));
    final booking = state.booking;

    return Scaffold(
      appBar: AppBar(title: Text('#$bookingId')),
      body: state.isLoading && booking == null
          ? const Center(child: CircularProgressIndicator())
          : booking == null
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(booking.serviceName(locale), style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Chip(
                      label: Text(_statusLabel(booking.status, l10n)),
                      backgroundColor: _statusColor(booking.status).withValues(alpha: 0.12),
                      labelStyle: TextStyle(color: _statusColor(booking.status)),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (booking.customerName != null)
                  _DetailRow(label: l10n.businessBookingsCustomer, value: booking.customerName!),
                if (booking.customerPhone != null)
                  _DetailRow(label: l10n.businessBookingsCustomer, value: booking.customerPhone!),
                if (booking.bookableLabel != null)
                  _DetailRow(label: l10n.businessBookingsUnit, value: booking.bookableLabel!),
                if (booking.startsAt != null)
                  _DetailRow(label: l10n.businessBookingsDateTime, value: booking.startsAt!.toLocal().toString().split('.').first),
                _DetailRow(label: l10n.businessBookingsQuantity, value: booking.quantity.toString()),
                if (booking.partySize != null)
                  _DetailRow(label: l10n.businessBookingsPartySize, value: booking.partySize.toString()),
                if (booking.notes != null && booking.notes!.isNotEmpty)
                  _DetailRow(label: l10n.businessBookingsNotes, value: booking.notes!),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.businessBookingsPrice, style: Theme.of(context).textTheme.titleSmall),
                    Text(booking.price.toStringAsFixed(2), style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.isBusy)
                  const Center(child: CircularProgressIndicator())
                else if (booking.status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _reject(context, ref),
                          child: Text(l10n.businessBookingsReject),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _run(
                            context,
                            ref,
                            () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).accept(),
                          ),
                          child: Text(l10n.businessBookingsAccept),
                        ),
                      ),
                    ],
                  ),
                ] else if (booking.status == 'accepted') ...[
                  OutlinedButton(
                    onPressed: () => _run(
                      context,
                      ref,
                      () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).businessConfirm(),
                    ),
                    child: Text(l10n.businessBookingsConfirm),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _run(
                      context,
                      ref,
                      () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).start(),
                    ),
                    child: Text(l10n.businessBookingsStart),
                  ),
                ] else if (booking.status == 'in_progress')
                  FilledButton(
                    onPressed: () => _run(
                      context,
                      ref,
                      () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).complete(),
                    ),
                    child: Text(l10n.businessBookingsComplete),
                  ),
                if (!state.isBusy &&
                    booking.deposit != null &&
                    (booking.deposit!.isFrozen || booking.deposit!.isReleased || booking.deposit!.isRefunded)) ...[
                  const Divider(height: 32),
                  Text(l10n.bookingsDepositSettlement, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (booking.deposit!.isReleased)
                    Text(l10n.bookingsDepositReleased)
                  else if (booking.deposit!.isRefunded)
                    Text(l10n.bookingsDepositRefunded)
                  else ...[
                    if (booking.deposit!.releaseAgreedBusiness)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l10n.bookingsWaitingOtherPartyRelease, style: Theme.of(context).textTheme.bodySmall),
                      )
                    else if (booking.deposit!.refundAgreedBusiness)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l10n.bookingsWaitingOtherPartyRefund, style: Theme.of(context).textTheme.bodySmall),
                      ),
                    FilledButton(
                      onPressed: () => _run(
                        context,
                        ref,
                        () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).agreeReleaseDeposit(),
                      ),
                      child: Text(l10n.bookingsAgreeRelease),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _run(
                        context,
                        ref,
                        () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).agreeRefundDeposit(),
                      ),
                      child: Text(l10n.bookingsAgreeRefund),
                    ),
                  ],
                ],
              ],
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
