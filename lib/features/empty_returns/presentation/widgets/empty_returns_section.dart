import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../schedules/application/schedules_providers.dart';
import '../../../schedules/presentation/screens/my_reservations_screen.dart';
import '../../../schedules/presentation/widgets/trip_leg_summary.dart'
    show routeArrow;
import '../../application/empty_returns_providers.dart';
import '../../data/empty_returns_api.dart';

/// «راجع فاضي» under the ride form: the limousine drivers going back on the very line the customer is asking for,
/// each at his own lower price for the whole car. Booking one is an ordinary trip reservation.
class EmptyReturnsSection extends ConsumerWidget {
  final int fromCityId;
  final int toCityId;

  const EmptyReturnsSection({
    super.key,
    required this.fromCityId,
    required this.toCityId,
  });

  Future<void> _book(
    BuildContext context,
    WidgetRef ref,
    EmptyReturnOffer offer,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final when = offer.departsAt == null
        ? ''
        : LocalFormat.dayDate(context).addClock().format(offer.departsAt!);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.emptyReturnBookTitle),
        content: Text(
          l10n.emptyReturnBookBody(
            offer.driverName ?? '',
            when,
            offer.price.toStringAsFixed(0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.emptyReturnBook),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(schedulesApiProvider).reserve(offer.id);
      ref.invalidate(
        emptyReturnsForLineProvider((from: fromCityId, to: toCityId)),
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.emptyReturnBooked)));
      navigator.push(
        MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.message : l10n.commonSomethingWentWrong,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final offers = ref.watch(
      emptyReturnsForLineProvider((from: fromCityId, to: toCityId)),
    );

    // nothing to show while loading, on an error, or when no driver is going back: the ride form stays as it was
    final list = offers.valueOrNull;
    if (list == null || list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.u_turn_left,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.emptyReturnSectionTitle,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.emptyReturnSectionHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          for (final offer in list)
            _OfferCard(offer: offer, onBook: () => _book(context, ref, offer)),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final EmptyReturnOffer offer;
  final VoidCallback onBook;

  const _OfferCard({required this.offer, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final when = offer.departsAt == null
        ? null
        : LocalFormat.dayDate(context).addClock().format(offer.departsAt!);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.driverName ?? '',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (offer.hasGuarantee)
                  Icon(
                    Icons.verified_user_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                if (offer.reviewCount > 0) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(offer.starsAverage.toStringAsFixed(1)),
                ],
              ],
            ),
            // the exact cities when they are not the ones asked for (the same governorate pair, other cities)
            if (!offer.exactMatch)
              Text(
                '${offer.originCity} ${routeArrow(context)} ${offer.destinationCity}',
                style: theme.textTheme.bodySmall,
              ),
            if (when != null)
              Text(
                l10n.emptyReturnDeparts(when),
                style: theme.textTheme.bodyMedium,
              ),
            Text(
              l10n.emptyReturnSeats('${offer.seats}'),
              style: theme.textTheme.bodySmall,
            ),
            if (offer.notes != null)
              Text(offer.notes!, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.emptyReturnPriceEgp(offer.price.toStringAsFixed(0)),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (offer.referencePrice != null)
                      Text(
                        l10n.emptyReturnUsualFare(
                          offer.referencePrice!.toStringAsFixed(0),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                if (offer.savingPercent != null &&
                    offer.savingPercent! > 0) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      l10n.emptyReturnSaving('${offer.savingPercent}'),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: onBook,
                  child: Text(l10n.emptyReturnBook),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
