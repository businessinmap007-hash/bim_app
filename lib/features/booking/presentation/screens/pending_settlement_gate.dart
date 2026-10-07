import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../disputes/application/disputes_providers.dart';
import '../../../disputes/presentation/widgets/dispute_reason_picker.dart';
import '../../application/booking_providers.dart';
import '../../data/models/booking.dart';

/// A mandatory, un-skippable prompt for every booking whose deposit is
/// frozen and still awaiting THIS account's own settlement decision
/// (BookingApi.pendingSettlements) — shown right when the app opens or
/// resumes (see HomeShell), before the person can do anything else.
///
/// Deliberately has no back button, no swipe-to-dismiss, no "later" —
/// leaving it requires picking one of the three real outcomes: the deal
/// succeeded (release), it didn't (refund), or there's a disagreement
/// (open a dispute, which hands the decision to arbitration instead).
/// Working through the whole queue pops back to whatever screen was
/// underneath when the gate was pushed.
Future<void> showPendingSettlementGate(
  BuildContext context,
  List<Booking> pending,
) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _PendingSettlementGate(initial: pending),
    ),
  );
}

class _PendingSettlementGate extends ConsumerStatefulWidget {
  final List<Booking> initial;
  const _PendingSettlementGate({required this.initial});

  @override
  ConsumerState<_PendingSettlementGate> createState() =>
      _PendingSettlementGateState();
}

class _PendingSettlementGateState
    extends ConsumerState<_PendingSettlementGate> {
  final List<Booking> _queue = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _queue.addAll(widget.initial);
  }

  Booking get _current => _queue.first;

  void _advance() {
    setState(() => _queue.removeAt(0));
    if (_queue.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _act(Future<void> Function(int id) action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await action(_current.id);
      if (mounted) _advance();
    } catch (e) {
      if (mounted) {
        final message = e is ApiException
            ? e.message
            : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// A step that does not settle the booking: the prompt stays on it, with its new state.
  Future<void> _step(Future<Booking> Function() call) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final updated = await call();
      if (mounted) setState(() => _queue[0] = updated);
    } catch (e) {
      if (mounted) {
        final message = e is ApiException
            ? e.message
            : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// «اطلب اعتماد ديبوزتي كدفعة» — the customer asks (only where the business opted in).
  Future<void> _requestAsPayment() async {
    await _step(() async {
      await ref
          .read(myBookingsControllerProvider.notifier)
          .requestDepositAsPayment(_current.id);

      return ref.read(bookingApiProvider).show(_current.id);
    });
  }

  Future<void> _declineAsPayment() => _step(
    () => ref.read(bookingApiProvider).declineDepositAsPayment(_current.id),
  );

  /// Accepting settles the deposit: the booking leaves the queue.
  Future<void> _acceptAsPayment() => _act((id) async {
    await ref.read(bookingApiProvider).acceptDepositAsPayment(id);
  });

  Future<void> _agreeRelease() => _act(
    (id) =>
        ref.read(myBookingsControllerProvider.notifier).agreeReleaseDeposit(id),
  );

  Future<void> _agreeRefund() => _act(
    (id) =>
        ref.read(myBookingsControllerProvider.notifier).agreeRefundDeposit(id),
  );

  Future<void> _openDispute() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(disputesApiProvider)
          .openForBooking(
            _current.id,
            reasonCode: result.reasonCode,
            reasonText: result.reasonText,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.disputeOpened)));
        _advance();
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException
            ? e.message
            : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;
    // the last booking was just answered and the prompt is closing — nothing left to draw
    if (_queue.isEmpty) return const SizedBox.shrink();
    final booking = _current;
    final otherPartyName = isBusiness
        ? (booking.customerName ?? '')
        : (booking.businessName ?? '');

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            // scrolls on a short screen — the prompt grew with the deposit-as-payment choice
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pendingSettlementTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.pendingSettlementSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${booking.id}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.pendingSettlementQuestion(otherPartyName),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.price.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_busy)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      if (isBusiness && booking.depositAsPayment.requested) ...[
                        Text(
                          l10n.depositAsPaymentAsked,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _acceptAsPayment,
                          child: Text(l10n.depositAsPaymentAccept),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _declineAsPayment,
                          child: Text(l10n.depositAsPaymentDecline),
                        ),
                        const Divider(height: 28),
                      ],
                      if (!isBusiness) ...[
                        if (booking.depositAsPayment.requested)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              l10n.depositAsPaymentRequested,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        else if (booking.depositAsPayment.declined)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              l10n.depositAsPaymentDeclined,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        else if (booking.depositAsPayment.allowed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: OutlinedButton(
                              onPressed: _requestAsPayment,
                              child: Text(l10n.depositAsPaymentRequest),
                            ),
                          ),
                      ],
                      FilledButton(
                        onPressed: _agreeRelease,
                        child: Text(l10n.bookingsAgreeRelease),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _agreeRefund,
                        child: Text(l10n.bookingsAgreeRefund),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _openDispute,
                        child: Text(l10n.disputeOpenTitle),
                      ),
                    ],
                    if (_queue.length > 1) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.pendingSettlementRemaining(_queue.length - 1),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
