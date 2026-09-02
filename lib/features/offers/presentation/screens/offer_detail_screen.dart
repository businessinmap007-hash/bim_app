import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/offers_providers.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  final int offerId;
  const OfferDetailScreen({super.key, required this.offerId});

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  bool _following = false;
  bool _busy = false;

  Future<void> _follow(int businessId) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(offersApiProvider).followBusiness(businessId);
      if (mounted) {
        setState(() {
          _following = true;
          _busy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.offerFollowed)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final async = ref.watch(offerDetailProvider(widget.offerId));

    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(offerDetailProvider(widget.offerId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (offer) {
        final seller = offer.sellingBusiness;
        return Scaffold(
          appBar: AppBar(title: Text(offer.title(languageCode))),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (seller != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: seller.logoUrl != null ? NetworkImage(seller.logoUrl!) : null,
                    child: seller.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                  ),
                  title: Text(seller.name),
                ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (offer.basePrice != null && offer.basePrice! > offer.finalPrice) ...[
                    Text(
                      '${offer.basePrice} ${offer.currency}',
                      style: const TextStyle(decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${offer.finalPrice} ${offer.currency}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (offer.discountValue != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        offer.discountType == 'percent'
                            ? '-${offer.discountValue}%'
                            : '-${offer.discountValue} ${offer.currency}',
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              if (offer.availableQuantity != null) ...[
                const SizedBox(height: 8),
                Text('${l10n.offerAvailableQuantityLabel}: ${offer.availableQuantity}'),
              ],
              if (offer.endsAt != null) ...[
                const SizedBox(height: 4),
                Text('${l10n.offerEndsAtLabel}: ${_formatDate(offer.endsAt!)}'),
              ],
              const SizedBox(height: 24),
              if (seller != null)
                FilledButton.icon(
                  onPressed: _busy || _following ? null : () => _follow(seller.id),
                  icon: Icon(_following ? Icons.notifications_active : Icons.notifications_none),
                  label: Text(_following ? l10n.offerFollowed : l10n.offerFollowBusiness),
                ),
            ],
          ),
        );
      },
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
