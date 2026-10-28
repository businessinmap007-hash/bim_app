import '../../../../core/assignment/assignment_providers.dart';
import '../../../../core/assignment/widgets/assignee_widgets.dart';
import 'package:flutter/material.dart';
import '../widgets/stay_details_card.dart';
import 'stay_settlement_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/guarantee_badge/widgets/account_name.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_providers.dart' show bookingApiProvider;
import '../../application/business_bookings_providers.dart';
import '../widgets/booking_money_card.dart';
import '../widgets/relationship_card.dart';
import '../../../projects/presentation/widgets/project_chat_card.dart';
import 'guest_booking_screen.dart';
import '../widgets/day_use_tag.dart';
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

/// The business's incoming-booking queue — GET /business/bookings. Reached
/// from Service settings (owner, [businessId] null) or from a delegated
/// staff member's "أعمالي" membership card ([businessId] set to the
/// business they act for) — mirrors BusinessOrdersScreen's own shape
/// (filter chips + list + detail screen).
class BusinessBookingsScreen extends ConsumerStatefulWidget {
  final int? businessId;
  const BusinessBookingsScreen({super.key, this.businessId});

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
      ref.read(businessBookingsControllerProvider(widget.businessId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setStatus(String? status) {
    setState(() => _status = status);
    ref.read(businessBookingsControllerProvider(widget.businessId).notifier).load(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessBookingsControllerProvider(widget.businessId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.businessBookingsTitle),
        actions: [
          // «جاء عميل بدون حجز»: book a customer who is standing there (an account, or a named guest)
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: l10n.guestBookingTitle,
            onPressed: () async {
              final booked = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const GuestBookingScreen()));
              if (booked == true && context.mounted) {
                ref.read(businessBookingsControllerProvider(widget.businessId).notifier).load(status: _status);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            // one line: the six chips never wrap onto a second row, the row scrolls sideways instead
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
                          onPressed: () =>
                              ref.read(businessBookingsControllerProvider(widget.businessId).notifier).load(status: _status),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.businessBookingsEmpty))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(businessBookingsControllerProvider(widget.businessId).notifier).load(status: _status),
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
                            MaterialPageRoute(
                              builder: (_) =>
                                  BusinessBookingDetailScreen(bookingId: booking.id, businessId: widget.businessId),
                            ),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitleParts.join(' · ')),
            if (booking.isGuest || (booking.previousDealings ?? 0) > 0)
              Wrap(
                spacing: 6,
                children: [
                  if (booking.isGuest)
                    Chip(label: Text(l10n.guestChip, style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact, side: BorderSide.none),
                  if ((booking.previousDealings ?? 0) > 0)
                    Chip(
                      avatar: const Icon(Icons.verified_outlined, size: 14),
                      label: Text(l10n.returningCustomerBadge(booking.previousDealings!), style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                ],
              ),
          ],
        ),
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
  final int? businessId;
  const BusinessBookingDetailScreen({super.key, required this.bookingId, this.businessId});

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
      ref.read(businessBookingsControllerProvider(businessId).notifier).load();
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
                  _DetailRow(label: l10n.businessBookingsCustomer, value: booking.customerName!, badgeUserId: booking.customerId),
                if (booking.customerPhone != null)
                  _DetailRow(label: l10n.businessBookingsCustomer, value: booking.customerPhone!),
                // a guest with no account is never counted; a returning customer wears his history
                if (booking.relationship != null) RelationshipCard(summary: booking.relationship!, forBusiness: true),
                if (booking.isGuest || (booking.previousDealings ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (booking.isGuest) Chip(label: Text(l10n.guestChip), visualDensity: VisualDensity.compact),
                        if ((booking.previousDealings ?? 0) > 0)
                          Chip(
                            avatar: const Icon(Icons.verified_outlined, size: 16),
                            label: Text(l10n.returningCustomerBadge(booking.previousDealings!)),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                if (booking.bookableLabel != null)
                  _DetailRow(label: l10n.businessBookingsUnit, value: booking.bookableLabel!),
                // the hotel's own room number — given when the stay starts, changeable by the hotel before and after
                if (booking.bookableItemType == 'booking_stay' && (booking.status == 'accepted' || booking.status == 'in_progress')) ...[
                  DayUseTag(booking: booking),
                  _RoomRow(booking: booking, bookingId: bookingId),
                ],
                // «نظام التعيين»: who is responsible — the same tile every business uses
                AssigneeTile(
                  current: booking.assignee,
                  businessId: businessId,
                  onAssign: (id) => ref.read(assignmentApiProvider).assignBooking(bookingId, id, businessId: businessId),
                  onChanged: () {
                    ref.read(businessBookingDetailControllerProvider(bookingId).notifier).load();
                    ref.read(businessBookingsControllerProvider(businessId).notifier).load();
                  },
                ),
                // «متابعة المشروع»: the project of this booking (or a button to start one), for the business
                ProjectChatCard(operationType: 'booking', operationId: bookingId),
                if (booking.startsAt != null)
                  _DetailRow(label: l10n.businessBookingsDateTime, value: booking.startsAt!.toLocal().toString().split('.').first),
                _DetailRow(label: l10n.businessBookingsQuantity, value: booking.quantity.toString()),
                if (booking.partySize != null)
                  _DetailRow(label: l10n.businessBookingsPartySize, value: booking.partySize.toString()),
                if (booking.notes != null && booking.notes!.isNotEmpty)
                  _DetailRow(label: l10n.businessBookingsNotes, value: booking.notes!),
                // «تفاصيل الإقامة»: the children and what each pays, the beds, the meal plan, the gala nights
                if (booking.stayDetails != null) StayDetailsCard(details: booking.stayDetails!),
                // «التسوية» of a non-refundable stay: the holds, both sides' confirmations, the guest's recorded payments
                if (booking.staySettlement != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.balance_outlined),
                    label: Text(booking.staySettlement!.isOpen ? l10n.settlementPlease : l10n.settlementOpenButton),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StaySettlementScreen(bookingId: booking.id))),
                  ),
                ],
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.businessBookingsPrice, style: Theme.of(context).textTheme.titleSmall),
                    Text(booking.price.toStringAsFixed(2), style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                // «العربون خارج المنصة»: the customer's account waits until the business says it arrived (or accepts without it)
                if (booking.externalDeposit.isPending) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          booking.externalDeposit.isPrepayment
                              ? l10n.prepaymentOwed(booking.externalDeposit.amount.toStringAsFixed(booking.externalDeposit.amount == booking.externalDeposit.amount.roundToDouble() ? 0 : 2))
                              : l10n.externalDepositOwed(booking.externalDeposit.amount.toStringAsFixed(booking.externalDeposit.amount == booking.externalDeposit.amount.roundToDouble() ? 0 : 2)),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.externalDeposit.isPrepayment ? l10n.prepaymentWaiting : l10n.externalDepositWaiting,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _run(context, ref, () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).confirmExternalDeposit('cash')),
                                child: Text(l10n.externalDepositCash),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () => _run(context, ref, () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).confirmExternalDeposit('transfer')),
                                child: Text(l10n.externalDepositTransfer),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () => _run(context, ref, () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).waiveExternalDeposit()),
                          child: Text(booking.externalDeposit.isPrepayment ? l10n.prepaymentWaive : l10n.externalDepositWaive),
                        ),
                      ],
                    ),
                  ),
                ] else if (booking.externalDeposit.isReceived || booking.externalDeposit.isWaived) ...[
                  const SizedBox(height: 12),
                  Text(
                    booking.externalDeposit.isPrepayment
                        ? (booking.externalDeposit.isWaived ? l10n.prepaymentWaived : l10n.prepaymentReceived)
                        : (booking.externalDeposit.isWaived ? l10n.externalDepositWaived : l10n.externalDepositReceived),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if ((booking.status == 'pending' || booking.status == 'accepted') && !booking.isGuest)
                  BookingMoneyCard(bookingId: bookingId),
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
                  // attendance is by BOTH, the customer first — it is what gives a booking its seriousness
                  Text(
                    booking.clientAttended ? l10n.bookingAttendanceCustomerDone : l10n.bookingAttendanceCustomerWaiting,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (booking.businessAttended)
                    Text(l10n.bookingAttendanceBusinessDone, style: Theme.of(context).textTheme.bodySmall)
                  else
                    OutlinedButton(
                      onPressed: booking.clientAttended
                          ? () => _run(
                              context,
                              ref,
                              () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).businessConfirm(),
                            )
                          : null,
                      child: Text(l10n.businessBookingsConfirm),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: booking.clientAttended && booking.businessAttended
                        ? () => _run(
                            context,
                            ref,
                            () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).start(),
                          )
                        : null,
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
                // a guest with no account has nobody to confirm the cash with: the section is for account customers
                if (!state.isBusy && !booking.isGuest && (booking.status == 'in_progress' || booking.status == 'completed')) ...[
                  const Divider(height: 32),
                  Text(l10n.paymentConfirmSectionTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.paymentConfirmCustomerStatusLabel, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        booking.clientPaymentConfirmedAt != null
                            ? l10n.paymentConfirmStatusConfirmed
                            : l10n.paymentConfirmStatusPending,
                        style: TextStyle(
                          fontSize: 12,
                          color: booking.clientPaymentConfirmedAt != null ? AppColors.success : Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (booking.businessPaymentConfirmedAt != null)
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(l10n.bookingPaymentBusinessConfirmed, style: TextStyle(color: AppColors.success)),
                      ],
                    )
                  else ...[
                    OutlinedButton(
                      onPressed: () => _run(
                        context,
                        ref,
                        () => ref
                            .read(businessBookingDetailControllerProvider(bookingId).notifier)
                            .confirmPayment(businessId: businessId),
                      ),
                      child: Text(l10n.bookingPaymentBusinessButton),
                    ),
                    if (booking.deposit != null && booking.deposit!.isFrozen)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.bookingPaymentDepositHint,
                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                        ),
                      ),
                  ],
                ],
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
                    // «قبول العربون»: the business may take the frozen deposit as a payment whether or not the customer asked
                    if (booking.depositAsPayment.requested || booking.depositAsPayment.allowed) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(booking.depositAsPayment.requested ? l10n.depositAsPaymentAsked : l10n.depositAsPaymentOffer),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: () => _run(context, ref, () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).acceptDepositAsPayment()),
                              child: Text(l10n.depositAsPaymentAccept),
                            ),
                            if (booking.depositAsPayment.requested) ...[
                              const SizedBox(height: 6),
                              OutlinedButton(
                                onPressed: () => _run(context, ref, () => ref.read(businessBookingDetailControllerProvider(bookingId).notifier).declineDepositAsPayment()),
                                child: Text(l10n.depositAsPaymentDecline),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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

  /// The account whose guarantee level shows beside the value (the customer's, on the customer row).
  final int? badgeUserId;
  const _DetailRow({required this.label, required this.value, this.badgeUserId});

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
          Expanded(child: badgeUserId == null ? Text(value) : AccountName(text: value, userId: badgeUserId, maxLines: 2)),
        ],
      ),
    );
  }
}

/// «الغرفة» — the number the hotel gives this stay, and a way to put it in another free room.
class _RoomRow extends ConsumerWidget {
  final Booking booking;
  final int bookingId;
  const _RoomRow({required this.booking, required this.bookingId});

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(bookingApiProvider);
    final messenger = ScaffoldMessenger.of(context);
    final rooms = await api.stayRooms(bookingId);
    if (!context.mounted) return;

    if (!rooms.usesRooms) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.bookingRoomNone)));
      return;
    }

    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: rooms.free.isEmpty
            ? Padding(padding: const EdgeInsets.all(24), child: Text(l10n.bookingRoomNoFree))
            : ListView(
                shrinkWrap: true,
                children: [
                  // the guest ticked a view at booking: say so, and mark the rooms that have it
                  if (rooms.requested.isNotEmpty)
                    ListTile(dense: true, leading: const Icon(Icons.star_outline), title: Text(l10n.bookingRoomRequested(rooms.requested.join('، ')))),
                  for (final room in rooms.free)
                    ListTile(
                      leading: Icon(room.id == rooms.room?.id ? Icons.check_circle : Icons.meeting_room_outlined),
                      title: Text(room.number),
                      subtitle: rooms.requested.isEmpty ? null : Text(room.matches ? l10n.bookingRoomMatches : l10n.bookingRoomNoMatch),
                      onTap: () => Navigator.of(sheet).pop(room.id),
                    ),
                ],
              ),
      ),
    );
    if (picked == null) return;

    try {
      await api.assignRoom(bookingId, picked);
      ref.invalidate(businessBookingDetailControllerProvider(bookingId));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(l10n.bookingRoom, style: TextStyle(color: Theme.of(context).hintColor))),
          Expanded(child: Text(booking.room?.number ?? l10n.bookingRoomOnStart)),
          TextButton(onPressed: () => _choose(context, ref), child: Text(booking.room == null ? l10n.bookingRoomAssign : l10n.bookingRoomChange)),
        ],
      ),
    );
  }
}
