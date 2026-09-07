import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/schedules_providers.dart';
import '../../data/models/trip_reservation.dart';

const _statuses = <String?>[null, 'pending', 'confirmed', 'completed', 'cancelled'];

/// Api\V2\TripReservationController — reservations customers made on this
/// carrier's own published trip legs: confirm, complete (also records the
/// trust rating for both parties, per the backend's own message), or reject.
class IncomingReservationsScreen extends ConsumerWidget {
  const IncomingReservationsScreen({super.key});

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  String _statusLabel(AppLocalizations l10n, String? status) => switch (status) {
    null => l10n.tripReservationStatusAll,
    'pending' => l10n.tripReservationStatusPending,
    'confirmed' => l10n.tripReservationStatusConfirmed,
    'completed' => l10n.tripReservationStatusCompleted,
    'cancelled' => l10n.tripReservationStatusCancelled,
    _ => status,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(incomingReservationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.incomingReservationsTitle)),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: MouseWheelHorizontalScroll(
              builder: (context, controller) => ListView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  for (final status in _statuses)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_statusLabel(l10n, status)),
                        selected: state.status == status,
                        onSelected: (_) =>
                            ref.read(incomingReservationsControllerProvider.notifier).setStatus(status),
                      ),
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
                          onPressed: () => ref.read(incomingReservationsControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.incomingReservationsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(incomingReservationsControllerProvider.notifier).load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _ReservationCard(
                        reservation: state.items[index],
                        onAct: (fn) => _act(context, ref, fn),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends ConsumerWidget {
  final TripReservation reservation;
  final void Function(Future<void> Function()) onAct;
  const _ReservationCard({required this.reservation, required this.onAct});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final r = reservation;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.clientId != null ? l10n.tripReservationClient(r.clientId!) : '#${r.id}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(l10n.tripReservationUnitsCount(r.units)),
            if (r.totalPrice != null) Text('${r.totalPrice!.toStringAsFixed(2)} ${r.currency}'),
            if (r.notes != null && r.notes!.isNotEmpty) Text(r.notes!),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (r.status == 'pending')
                  OutlinedButton(
                    onPressed: () =>
                        onAct(() => ref.read(incomingReservationsControllerProvider.notifier).confirm(r.id)),
                    child: Text(l10n.tripReservationConfirmAction),
                  ),
                if (r.status == 'confirmed')
                  OutlinedButton(
                    onPressed: () =>
                        onAct(() => ref.read(incomingReservationsControllerProvider.notifier).complete(r.id)),
                    child: Text(l10n.tripReservationCompleteAction),
                  ),
                if (r.status == 'pending' || r.status == 'confirmed')
                  OutlinedButton(
                    onPressed: () =>
                        onAct(() => ref.read(incomingReservationsControllerProvider.notifier).reject(r.id)),
                    child: Text(l10n.tripReservationRejectAction),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
