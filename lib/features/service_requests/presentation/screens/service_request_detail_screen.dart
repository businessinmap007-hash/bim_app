import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/presentation/screens/orders_and_bookings_screen.dart'
    show openBookingDetailSheet;
import '../../application/service_requests_providers.dart';
import '../../data/service_requests_api.dart';

/// One of my requests: the offers on it from the cheapest, accept one (it becomes a booking), change the price I ask
/// for, or cancel — see Api\V2\ServiceRequestController.
class ServiceRequestDetailScreen extends ConsumerStatefulWidget {
  final int requestId;

  const ServiceRequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<ServiceRequestDetailScreen> createState() =>
      _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState
    extends ConsumerState<ServiceRequestDetailScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(serviceRequestProvider(widget.requestId));
      ref.invalidate(myServiceRequestsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.message : l10n.commonSomethingWentWrong,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept(ServiceRequestModel request, RequestOffer offer) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(serviceRequestsApiProvider);
    await _run(() async {
      await api.accept(request.id, offer.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.requestBookingMade)));
      }
    });
  }

  Future<void> _changePrice(ServiceRequestModel request) async {
    final price = await showDialog<double>(
      context: context,
      builder: (_) => _PriceDialog(initial: request.budget),
    );
    if (price == null) return;
    final api = ref.read(serviceRequestsApiProvider);
    await _run(() => api.setPrice(request.id, price));
  }

  Future<void> _cancel(ServiceRequestModel request) async {
    final l10n = AppLocalizations.of(context)!;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.requestCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.requestCancel),
          ),
        ],
      ),
    );
    if (yes != true) return;
    final api = ref.read(serviceRequestsApiProvider);
    await _run(() async {
      await api.cancel(request.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.requestCancelled)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(serviceRequestProvider(widget.requestId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rideAllRequestsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e is ApiException ? e.message : l10n.commonSomethingWentWrong,
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(serviceRequestProvider(widget.requestId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (request) => RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(serviceRequestProvider(widget.requestId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RequestSummaryCard(request: request),
              const SizedBox(height: 12),
              if (request.isOpen) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.requestYourPrice(
                          (request.budget ?? 0).toStringAsFixed(0),
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : () => _changePrice(request),
                      child: Text(l10n.requestChangePrice),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (request.status == 'accepted' && request.bookingId != null)
                FilledButton(
                  onPressed: () =>
                      openBookingDetailSheet(context, ref, request.bookingId!),
                  child: Text(l10n.requestOpenBooking),
                ),
              const SizedBox(height: 12),
              Text(
                l10n.requestOffersCount(
                  request.offers
                      .where((o) => o.isPending || o.isAccepted)
                      .length,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (request.offers.isEmpty)
                Text(
                  l10n.requestNoOffers,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                for (final offer in request.offers.where(
                  (o) => o.isPending || o.isAccepted,
                ))
                  _OfferCard(
                    offer: offer,
                    canAccept: request.isOpen && offer.isPending && !_busy,
                    acceptLabel: request.isCarWanted
                        ? l10n.carWantedAcceptViewing
                        : l10n.requestOfferAccept,
                    onAccept: () => _accept(request, offer),
                  ),
              if (request.isOpen) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _busy ? null : () => _cancel(request),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(l10n.requestCancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The ride in one card: the two cities, when, how many and how far — shared by the customer's detail and list.
class RequestSummaryCard extends StatelessWidget {
  final ServiceRequestModel request;

  const RequestSummaryCard({super.key, required this.request});

  static String title(ServiceRequestModel r) {
    if (r.isCarWanted || r.isHomeService) return r.title;
    final from = r.origin?.city ?? '';
    final to = r.destination?.city ?? '';
    return from.isEmpty || to.isEmpty ? r.title : '$from ← $to';
  }

  static String statusLabel(AppLocalizations l10n, String status) =>
      switch (status) {
        'open' => l10n.requestStatusOpen,
        'accepted' => l10n.requestStatusAccepted,
        'cancelled' => l10n.requestStatusCancelled,
        _ => l10n.requestStatusExpired,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final parts = request.isHomeService
        ? <String>[
            request.startsAt == null
                ? l10n.homeServiceAnyTime
                : LocalFormat.dayDate(context).addClock().format(request.startsAt!),
            if (request.budget != null)
              l10n.homeServiceBudgetIs(request.budget!.toStringAsFixed(0)),
          ]
        : request.isCarWanted
        ? <String>[
            request.isRentalWanted ? l10n.carDealRent : l10n.carDealBuy,
            if (request.days != null) l10n.carRentDaysCount(request.days!),
            if (request.budget != null)
              l10n.carMaxPriceIs(request.budget!.toStringAsFixed(0)),
            if (request.startsAt != null)
              LocalFormat.dayDate(context).addClock().format(request.startsAt!),
          ]
        : <String>[
            request.startsAt == null
                ? l10n.rideWhenNow
                : LocalFormat.dayDate(
                    context,
                  ).addClock().format(request.startsAt!),
            l10n.requestPassengersCount(request.passengers),
            if (request.distanceKm != null)
              l10n.rideDistanceKm(request.distanceKm!.toStringAsFixed(0)),
          ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title(request),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(statusLabel(l10n, request.status))),
              ],
            ),
            Text(parts.join(' · '), style: theme.textTheme.bodySmall),
            if (request.details != null && request.details!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(request.details!),
            ],
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final RequestOffer offer;
  final bool canAccept;
  final String acceptLabel;
  final VoidCallback onAccept;

  const _OfferCard({
    required this.offer,
    required this.canAccept,
    required this.acceptLabel,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notes = <String>[
      if (offer.etaMinutes != null) l10n.requestOfferEta(offer.etaMinutes!),
      if (offer.message != null && offer.message!.isNotEmpty) offer.message!,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.businessName ?? '',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${offer.price.toStringAsFixed(0)} ${l10n.pharmacyCurrencyLabel}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            if (offer.itemName != null)
              Text(
                l10n.carOfferItem(offer.itemName!),
                style: theme.textTheme.bodyMedium,
              ),
            if (notes.isNotEmpty)
              Text(notes.join(' · '), style: theme.textTheme.bodySmall),
            if (offer.acceptsBudget) ...[
              const SizedBox(height: 4),
              Text(
                l10n.requestOfferAcceptsYourPrice,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (canAccept) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAccept,
                  child: Text(acceptLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceDialog extends StatefulWidget {
  final double? initial;

  const _PriceDialog({this.initial});

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial?.toStringAsFixed(0) ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.requestChangePrice),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.ridePriceLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, double.tryParse(_controller.text.trim())),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
