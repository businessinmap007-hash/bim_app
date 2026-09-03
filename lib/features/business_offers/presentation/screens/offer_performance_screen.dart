import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_offers_providers.dart';

const _eventOrder = ['view', 'click', 'lead', 'conversion', 'share', 'save'];

IconData _eventIcon(String type) => switch (type) {
  'view' => Icons.visibility_outlined,
  'click' => Icons.touch_app_outlined,
  'lead' => Icons.phone_outlined,
  'conversion' => Icons.check_circle_outline,
  'share' => Icons.ios_share,
  'save' => Icons.bookmark_outline,
  _ => Icons.bar_chart_outlined,
};

String _eventLabel(AppLocalizations l10n, String type) => switch (type) {
  'view' => l10n.offerEventView,
  'click' => l10n.offerEventClick,
  'lead' => l10n.offerEventLead,
  'conversion' => l10n.offerEventConversion,
  'share' => l10n.offerEventShare,
  'save' => l10n.offerEventSave,
  _ => type,
};

/// Api\V2\OfferTrackingController::myPerformance — how a business's own
/// offers are doing: totals per event type, then a per-offer breakdown.
/// Offer titles are resolved from the already-loaded My Offers list
/// (businessOffersControllerProvider) rather than a second fetch; an offer
/// not currently in that list (deleted, or beyond its first page) falls
/// back to "#id".
class OfferPerformanceScreen extends ConsumerWidget {
  const OfferPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(offerPerformanceProvider);
    final offers = ref.watch(businessOffersControllerProvider).items;
    final titleById = {for (final o in offers) o.id: o.title(Localizations.localeOf(context).languageCode)};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offerPerformanceTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(offerPerformanceProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (performance) {
          if (performance.totals.isEmpty && performance.offerStats.isEmpty) {
            return Center(child: Text(l10n.offerPerformanceEmpty));
          }
          final totalsByType = {for (final t in performance.totals) t.eventType: t};
          final byOffer = performance.statsByOffer();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final type in _eventOrder)
                    if (totalsByType.containsKey(type))
                      _TotalCard(
                        icon: _eventIcon(type),
                        label: _eventLabel(l10n, type),
                        total: totalsByType[type]!.total,
                        valueTotal: totalsByType[type]!.valueTotal,
                      ),
                ],
              ),
              if (byOffer.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(l10n.offerPerformanceByOffer, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final entry in byOffer.entries)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleById[entry.key] ?? '#${entry.key}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              for (final stat in entry.value)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_eventIcon(stat.eventType), size: 15),
                                    const SizedBox(width: 4),
                                    Text('${_eventLabel(l10n, stat.eventType)}: ${stat.total}'),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int total;
  final double valueTotal;

  const _TotalCard({required this.icon, required this.label, required this.total, required this.valueTotal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text('$total', style: Theme.of(context).textTheme.headlineSmall),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              if (valueTotal > 0)
                Text(
                  valueTotal.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
