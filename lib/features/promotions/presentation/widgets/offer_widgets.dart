import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/promotions_providers.dart';
import '../../data/models/promotion.dart';

String _num(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// «خصم ٢٠٪» / «اشترِ ٣ وادفع ثمن الأغلى» — what a rule says, in words.
String promotionSummary(AppLocalizations l10n, String kind, double Function(String) param) {
  switch (kind) {
    case PromotionKind.percent:
      return l10n.promoPercent(_num(param('value')));
    case PromotionKind.amount:
      return l10n.promoAmount(_num(param('value')));
    case PromotionKind.nForPriceOf:
      final n = param('n').round();
      final pay = param('pay').round();
      return pay <= 1 ? l10n.promoBuyNPayTop(n) : l10n.promoBuyGetFree(pay, n - pay);
    case PromotionKind.spendPercent:
      return l10n.promoSpend(_num(param('min_total')), _num(param('value')));
  }
  return '';
}

/// The price of an item with its offer: the list price struck and the price after it, or — for a rule that cannot price one piece
/// («اشترِ ٣…») — the usual price and a small chip saying the offer.
class PriceWithOffer extends StatelessWidget {
  final String label;
  final ItemOffer? offer;
  final TextStyle? style;

  const PriceWithOffer({super.key, required this.label, this.offer, this.style});

  @override
  Widget build(BuildContext context) {
    final o = offer;

    if (o == null) return Text(label, style: style);

    final l10n = AppLocalizations.of(context)!;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(promotionSummary(l10n, o.kind, o.param), style: const TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w700)),
    );

    final after = o.priceAfter;

    return Wrap(
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (after != null) ...[
          Text(_num(after), style: style),
          Text(label, style: style?.copyWith(decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w400, color: Theme.of(context).hintColor)),
        ] else
          Text(label, style: style),
        chip,
      ],
    );
  }
}

/// One promotion as a customer reads it: the rule, what it covers, until when, and a few covered items with their new price.
class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PromotionCard({super.key, required this.promotion, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = promotion;
    final covers = p.targets.any((t) => t.type == PromotionTargetType.all)
        ? l10n.promoCoversAll
        : l10n.promoCovers(p.targets.map((t) => t.name).where((n) => n.isNotEmpty).take(3).join('، '));

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(p.title ?? promotionSummary(l10n, p.kind, p.param), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                  ?trailing,
                ],
              ),
              if (p.title != null) Text(promotionSummary(l10n, p.kind, p.param), style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(covers, style: theme.textTheme.bodySmall),
              Wrap(
                spacing: 12,
                children: [
                  if (p.forNewCustomers) Text(l10n.promoFirstOrder, style: theme.textTheme.bodySmall),
                  if (p.endsAt != null) Text(l10n.promoEndsOn(LocalFormat.date(context).format(p.endsAt!)), style: theme.textTheme.bodySmall),
                  if (p.remainingUses != null) Text(l10n.promoUsesLeft(p.remainingUses!), style: theme.textTheme.bodySmall),
                ],
              ),
              if (p.items.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final i in p.items.take(4))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(i.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (i.priceAfter != null) ...[
                          Text(_num(i.price), style: TextStyle(decoration: TextDecoration.lineThrough, color: theme.hintColor)),
                          const SizedBox(width: 6),
                          Text(_num(i.priceAfter!), style: const TextStyle(fontWeight: FontWeight.w800)),
                        ] else
                          Text(_num(i.price)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// «العروض» tab of a business page: what is running now.
class BusinessPromotionsTab extends ConsumerWidget {
  final int businessId;

  const BusinessPromotionsTab({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(businessPromotionsProvider(businessId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(businessPromotionsProvider(businessId)), child: Text(l10n.commonRetry))),
      data: (list) => list.isEmpty
          ? Center(child: Text(l10n.promoNoneRunning))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => PromotionCard(promotion: list[i]),
            ),
    );
  }
}
