import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/offers_providers.dart';
import '../../data/models/offer_comparison_row.dart';

/// Api\V2\OfferComparisonController — every active offer for one specific
/// item, across sellers, sorted by price/value/ranking. Reached from a
/// specific item's own screen (e.g. the menu "add to cart" sheet), never
/// browsed on its own — it has nothing to show without an offerable_type +
/// offerable_id.
class OfferComparisonScreen extends ConsumerStatefulWidget {
  final String offerableType;
  final int offerableId;
  final String itemTitle;
  final int quantity;

  const OfferComparisonScreen({
    super.key,
    required this.offerableType,
    required this.offerableId,
    required this.itemTitle,
    this.quantity = 1,
  });

  @override
  ConsumerState<OfferComparisonScreen> createState() => _OfferComparisonScreenState();
}

class _OfferComparisonScreenState extends ConsumerState<OfferComparisonScreen> {
  String _sort = 'lowest_price';

  String _sortLabel(AppLocalizations l10n, String sort) => switch (sort) {
    'highest_price' => l10n.offerCompareSortHighest,
    'best_value' => l10n.offerCompareSortBestValue,
    'ranking' => l10n.offerCompareSortRanking,
    _ => l10n.offerCompareSortLowest,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final params = (
      offerableType: widget.offerableType,
      offerableId: widget.offerableId,
      quantity: widget.quantity,
      sort: _sort,
    );
    final async = ref.watch(offerComparisonProvider(params));

    return Scaffold(
      appBar: AppBar(title: Text(widget.itemTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.offerCompareTitle, style: Theme.of(context).textTheme.titleMedium),
                ),
                DropdownButton<String>(
                  value: _sort,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final s in const ['lowest_price', 'highest_price', 'best_value', 'ranking'])
                      DropdownMenuItem(value: s, child: Text(_sortLabel(l10n, s))),
                  ],
                  onChanged: (v) => setState(() => _sort = v ?? 'lowest_price'),
                ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.commonSomethingWentWrong),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(offerComparisonProvider(params)),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (result) {
                if (result.offers.isEmpty) {
                  return Center(child: Text(l10n.offerCompareEmpty));
                }
                final bestId = result.lowestPrice?.id;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: result.offers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final row = result.offers[index];
                    return _OfferRow(row: row, isBest: row.id == bestId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final OfferComparisonRow row;
  final bool isBest;

  const _OfferRow({required this.row, required this.isBest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final business = row.sellerBusiness ?? row.ownerBusiness;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: business == null
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: business.id)),
              ),
        leading: CircleAvatar(
          backgroundImage: business?.logo != null ? NetworkImage(business!.logo!) : null,
          child: business?.logo == null ? const Icon(Icons.storefront_outlined) : null,
        ),
        title: Text(business?.name ?? '—'),
        subtitle: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            if (isBest)
              _Badge(label: l10n.offerCompareBestPrice, color: AppColors.accentGold),
            if (row.isFeatured) _Badge(label: '★', color: Theme.of(context).colorScheme.primary),
            if (row.isRefundable) _Badge(label: l10n.offerCompareRefundable, color: Theme.of(context).colorScheme.secondary),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (row.hasDiscount)
              Text(
                '${row.basePrice.toStringAsFixed(0)} ${row.currency}',
                style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12),
              ),
            Text(
              '${row.finalPrice.toStringAsFixed(0)} ${row.currency}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
