import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business_menu/application/business_menu_providers.dart';
import '../../../business_menu/data/models/menu_item.dart';
import '../../application/service_requests_providers.dart';
import '../../data/service_requests_api.dart';
import '../widgets/requests_availability_switch.dart';
import 'service_request_detail_screen.dart' show RequestSummaryCard;
import '../widgets/request_photos_row.dart';

/// The business side: the open requests this account may answer (its trade, its governorate), its own offer on each,
/// and the sheet to offer a price — see Api\V2\ServiceRequestController::incoming / offer / withdraw. A trade that
/// answers more than one kind (rides and cars) gets a switch between them.
class IncomingRequestsScreen extends ConsumerStatefulWidget {
  const IncomingRequestsScreen({super.key});

  @override
  ConsumerState<IncomingRequestsScreen> createState() =>
      _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState
    extends ConsumerState<IncomingRequestsScreen> {
  String? _kind;

  static String _label(AppLocalizations l10n, String kind) => switch (kind) {
    'car_wanted' => l10n.requestKindCar,
    'home_service' => l10n.requestKindHome,
    'work_quote' => l10n.requestKindQuote,
    _ => l10n.requestKindRide,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kinds =
        ref.watch(answerableRequestKindsProvider).valueOrNull ??
        const <String>[];
    final kind = _kind ?? (kinds.isNotEmpty ? kinds.first : 'ride');
    final async = ref.watch(incomingServiceRequestsProvider(kind));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestsAnswerTitle)),
      body: Column(
        children: [
          const RequestsAvailabilitySwitch(),
          if (kinds.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SegmentedButton<String>(
                segments: [
                  for (final k in kinds)
                    ButtonSegment(value: k, label: Text(_label(l10n, k))),
                ],
                selected: {kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
            ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e is ApiException
                          ? e.message
                          : l10n.commonSomethingWentWrong,
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(incomingServiceRequestsProvider(kind)),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () async =>
                    ref.refresh(incomingServiceRequestsProvider(kind).future),
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text(l10n.requestsIncomingEmpty)),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _IncomingCard(request: items[i]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingCard extends ConsumerWidget {
  final ServiceRequestModel request;

  const _IncomingCard({required this.request});

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(serviceRequestsApiProvider).withdraw(request.id);
      ref.invalidate(incomingServiceRequestsProvider(request.kind));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.requestOfferWithdrawn)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException ? e.message : l10n.commonSomethingWentWrong,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mine = request.myOffer;
    final live = mine != null && mine.isPending;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              RequestSummaryCard.title(request),
              style: theme.textTheme.titleMedium,
            ),
            if (request.requesterFirstName != null)
              Text(
                l10n.requestFrom(request.requesterFirstName!),
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            // when, how many, how far — and the job in the customer's own words: a quote cannot be given without it
            Text(
              RequestSummaryCard.parts(context, request).join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            if (request.details != null && request.details!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(request.details!),
            ],
            // the photos of the problem, so the quote fits the job
            if (request.photos.isNotEmpty) ...[
              const SizedBox(height: 6),
              RequestPhotosRow(urls: request.photos, size: 64),
              const SizedBox(height: 4),
            ],
            if (request.budget != null)
              Text(
                l10n.requestCustomerPrice(request.budget!.toStringAsFixed(0)),
              ),
            Text(
              l10n.requestOffersCount(request.offersCount),
              style: theme.textTheme.bodySmall,
            ),
            if (live) ...[
              const SizedBox(height: 6),
              Text(
                l10n.requestMyOffer(mine.price.toStringAsFixed(0)),
                style: theme.textTheme.titleSmall,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => _OfferSheet(request: request),
                    ),
                    child: Text(
                      live ? l10n.requestChangePrice : l10n.requestOfferSend,
                    ),
                  ),
                ),
                if (live) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _withdraw(context, ref),
                    child: Text(l10n.requestOfferWithdraw),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferSheet extends ConsumerStatefulWidget {
  final ServiceRequestModel request;

  const _OfferSheet({required this.request});

  @override
  ConsumerState<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends ConsumerState<_OfferSheet> {
  late final _price = TextEditingController(
    text: widget.request.myOffer?.price.toStringAsFixed(0) ?? '',
  );
  // a work quote's «eta» is the DAYS the job takes (sent as minutes); a ride's is the minutes to arrive
  late final _eta = TextEditingController(
    text: widget.request.myOffer?.etaMinutes == null
        ? ''
        : widget.request.isWorkQuote
        ? (widget.request.myOffer!.etaMinutes! / 1440).ceil().toString()
        : widget.request.myOffer!.etaMinutes.toString(),
  );
  late final _message = TextEditingController(
    text: widget.request.myOffer?.message ?? '',
  );
  bool _acceptBudget = false;
  bool _busy = false;
  String? _error;
  int? _itemId;
  List<BusinessMenuItem> _items = const [];

  @override
  void initState() {
    super.initState();
    if (widget.request.isCarWanted) _loadItems();
  }

  /// A dealer answers «أريد سيارة» with one of his own cars.
  Future<void> _loadItems() async {
    try {
      final page = await ref
          .read(businessMenuApiProvider)
          .items(isActive: true);
      if (mounted) setState(() => _items = page.items);
    } catch (_) {
      // the picker is optional: the offer can go without a particular car
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _eta.dispose();
    _message.dispose();
    super.dispose();
  }

  int? _etaMinutes() {
    final n = int.tryParse(_eta.text.trim());
    if (n == null) return null;
    return widget.request.isWorkQuote ? n * 1440 : n;
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(serviceRequestsApiProvider)
          .offer(
            widget.request.id,
            price: double.tryParse(_price.text.trim()),
            acceptsBudget: _acceptBudget,
            message: _message.text,
            etaMinutes: _etaMinutes(),
            menuItemId: _itemId,
          );
      ref.invalidate(incomingServiceRequestsProvider(widget.request.kind));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requestOfferSent)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budget = (widget.request.budget ?? 0).toStringAsFixed(0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              RequestSummaryCard.title(widget.request),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (widget.request.budget != null)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _acceptBudget,
                onChanged: (v) => setState(() => _acceptBudget = v ?? false),
                title: Text(l10n.requestOfferAcceptBudget(budget)),
              ),
            if (!_acceptBudget)
              TextField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.requestOfferPriceLabel,
                ),
              ),
            if (widget.request.isCarWanted && _items.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _itemId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.carOfferPickItem),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.carOfferNoItem),
                  ),
                  for (final i in _items)
                    DropdownMenuItem<int?>(
                      value: i.id,
                      child: Text(
                        '${i.nameAr} · ${i.basePrice.toStringAsFixed(0)}',
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _itemId = v),
              ),
            ],
            if (!widget.request.isCarWanted) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _eta,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: widget.request.isWorkQuote
                      ? l10n.workQuoteOfferDaysLabel
                      : l10n.requestOfferEtaLabel,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _message,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: l10n.requestOfferMessageLabel,
              ),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _send,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.requestOfferSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
