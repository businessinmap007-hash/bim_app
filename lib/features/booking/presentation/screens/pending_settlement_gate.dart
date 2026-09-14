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
Future<void> showPendingSettlementGate(BuildContext context, List<Booking> pending) {
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
  ConsumerState<_PendingSettlementGate> createState() => _PendingSettlementGateState();
}

class _PendingSettlementGateState extends ConsumerState<_PendingSettlementGate> {
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
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _agreeRelease() =>
      _act((id) => ref.read(myBookingsControllerProvider.notifier).agreeReleaseDeposit(id));

  Future<void> _agreeRefund() =>
      _act((id) => ref.read(myBookingsControllerProvider.notifier).agreeRefundDeposit(id));

  Future<void> _openDispute() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(disputesApiProvider)
          .openForBooking(_current.id, reasonCode: result.reasonCode, reasonText: result.reasonText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.disputeOpened)));
        _advance();
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
    final authState = ref.watch(authControllerProvider);
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;
    final booking = _current;
    final otherPartyName = isBusiness ? (booking.customerName ?? '') : (booking.businessName ?? '');

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.fact_check_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
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
                        Text('#${booking.id}', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(
                          l10n.pendingSettlementQuestion(otherPartyName),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(booking.price.toStringAsFixed(0), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_busy)
                  const Center(child: CircularProgressIndicator())
                else ...[
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
    );
  }
}
