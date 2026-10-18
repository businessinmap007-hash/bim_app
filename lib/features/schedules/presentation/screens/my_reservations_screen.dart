import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/deposit/visit_deposit.dart';
import '../../../../core/deposit/widgets/visit_deposit_card.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../disputes/application/disputes_providers.dart';
import '../../../disputes/presentation/screens/dispute_detail_screen.dart';
import '../../../disputes/presentation/widgets/dispute_reason_picker.dart';
import '../../application/schedules_providers.dart';
import '../../data/models/trip_reservation.dart';
import '../widgets/trip_leg_summary.dart';

class MyReservationsScreen extends ConsumerStatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  ConsumerState<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends ConsumerState<MyReservationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myReservationsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cancel(TripReservation reservation) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.tripReservationCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.tripReservationCancel)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(myReservationsControllerProvider.notifier).cancel(reservation.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tripReservationCancelled)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _reportProblem(TripReservation reservation) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    try {
      final dispute = await ref
          .read(disputesApiProvider)
          .openForTrip(reservation.id, reasonCode: result.reasonCode, reasonText: result.reasonText);
      if (mounted) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myReservationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myReservationsTitle)),
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
                    onPressed: () => ref.read(myReservationsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.myReservationsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myReservationsControllerProvider.notifier).load(),
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
                  final reservation = state.items[index];
                  return _ReservationTile(
                    reservation: reservation,
                    onCancel: () => _cancel(reservation),
                    onReportProblem: () => _reportProblem(reservation),
                  );
                },
              ),
            ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final TripReservation reservation;
  final VoidCallback onCancel;
  final VoidCallback onReportProblem;
  const _ReservationTile({required this.reservation, required this.onCancel, required this.onReportProblem});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 12),
                  child: Icon(reservation.leg?.mode == 'limousine' ? Icons.local_taxi_outlined : Icons.local_shipping_outlined),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // where and when first: that is what the customer looks for in this list
                      if (reservation.leg != null) TripLegSummary(leg: reservation.leg!),
                      if ((reservation.businessName ?? '').isNotEmpty)
                        Text(l10n.tripReservationWithCarrier(reservation.businessName!), style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        '${reservation.units} · ${(reservation.totalPrice ?? 0).toStringAsFixed(0)} ${reservation.currency} · ${_statusLabel(reservation.status, l10n)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reservation.status != 'blocked')
                    IconButton(
                      tooltip: l10n.disputeOpenTitle,
                      icon: const Icon(Icons.report_gmailerrorred_outlined),
                      onPressed: onReportProblem,
                    ),
                  if (reservation.isCancellable) TextButton(onPressed: onCancel, child: Text(l10n.tripReservationCancel)),
                ],
              ),
            ),
          ),
          // attendance: the customer confirms first, the carrier after him
          if (reservation.status == 'confirmed')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Consumer(
                builder: (context, ref, _) => reservation.clientConfirmed
                    ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          reservation.carrierConfirmed ? l10n.tripAttendanceBothConfirmed : l10n.tripAttendanceWaitingCarrier,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    : Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FilledButton.icon(
                          onPressed: () async {
                            try {
                              await ref.read(schedulesApiProvider).confirmAttendance(reservation.id);
                              await ref.read(myReservationsControllerProvider.notifier).load();
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
                              }
                            }
                          },
                          icon: const Icon(Icons.how_to_reg_outlined),
                          label: Text(l10n.tripAttendanceConfirmAsClient),
                        ),
                      ),
              ),
            ),
          // «عربون الجدية»: quoted, frozen when the carrier confirms, returned after the trip
          if (reservation.deposit != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Consumer(
                builder: (context, ref, _) => VisitDepositCard(
                  deposit: reservation.deposit!,
                  kind: VisitKind.tripReservation,
                  subjectId: reservation.id,
                  forBusiness: false,
                  visitEnded: reservation.status == 'no_show',
                  onChanged: () => ref.read(myReservationsControllerProvider.notifier).load(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'pending' => l10n.tripStatusPending,
  'confirmed' => l10n.tripStatusConfirmed,
  'completed' => l10n.tripStatusCompleted,
  'cancelled' => l10n.tripStatusCancelled,
  'blocked' => l10n.tripStatusBlocked,
  'no_show' => l10n.tripStatusNoShow,
  _ => status,
};
