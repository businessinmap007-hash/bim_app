import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/service_requests_providers.dart';
import '../../data/service_requests_api.dart';
import 'service_request_detail_screen.dart' show RequestSummaryCard;

/// The business side: the open requests this account may answer (its trade, its governorate), its own offer on each,
/// and the sheet to offer a price — see Api\V2\ServiceRequestController::incoming / offer / withdraw.
class IncomingRequestsScreen extends ConsumerWidget {
  const IncomingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(incomingServiceRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rideIncomingTitle)),
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
                    ref.invalidate(incomingServiceRequestsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(incomingServiceRequestsProvider.future),
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
                  itemBuilder: (context, i) => _IncomingCard(request: items[i]),
                ),
        ),
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
      ref.invalidate(incomingServiceRequestsProvider);
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
            Text(
              l10n.requestCustomerPrice(
                (request.budget ?? 0).toStringAsFixed(0),
              ),
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
  late final _eta = TextEditingController(
    text: widget.request.myOffer?.etaMinutes?.toString() ?? '',
  );
  late final _message = TextEditingController(
    text: widget.request.myOffer?.message ?? '',
  );
  bool _acceptBudget = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _price.dispose();
    _eta.dispose();
    _message.dispose();
    super.dispose();
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
            etaMinutes: int.tryParse(_eta.text.trim()),
          );
      ref.invalidate(incomingServiceRequestsProvider);
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
            const SizedBox(height: 12),
            TextField(
              controller: _eta,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.requestOfferEtaLabel),
            ),
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
