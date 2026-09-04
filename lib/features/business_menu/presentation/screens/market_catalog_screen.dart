import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/market_catalog_providers.dart';
import '../../data/models/market_catalog_group.dart';
import 'market_catalog_group_screen.dart';

/// «تعبئة الرفوف» — bulk pricing for a ready-goods merchant (supermarket,
/// greengrocer, butcher...): every sellable row is already named from the
/// platform's own option vocabulary, so pricing 8,000 products means walking
/// a handful of sections instead of creating each item from scratch one at a
/// time. Mirrors the web business panel's /business/menu/market-catalog.
class MarketCatalogScreen extends ConsumerWidget {
  const MarketCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(marketCatalogControllerProvider);

    final forbidden = state.hasError && state.error is ApiException && (state.error as ApiException).isForbidden;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketCatalogTitle)),
      body: forbidden
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.marketCatalogNotApplicable, textAlign: TextAlign.center),
              ),
            )
          : AsyncValueView<MarketCatalog>(
        value: state,
        onRetry: () => ref.read(marketCatalogControllerProvider.notifier).load(),
        builder: (context, catalog) {
          if (catalog.groups.isEmpty) {
            return Center(child: Text(l10n.marketCatalogEmpty));
          }

          final languageCode = Localizations.localeOf(context).languageCode;

          return RefreshIndicator(
            onRefresh: () => ref.read(marketCatalogControllerProvider.notifier).load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: catalog.groups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final group = catalog.groups[index];
                final complete = group.total > 0 && group.filled == group.total;

                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(group.name(languageCode), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.marketCatalogFilledOf(group.filled, group.total)),
                    trailing: Icon(
                      complete ? Icons.check_circle : Icons.chevron_left,
                      color: complete ? Colors.green : null,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MarketCatalogGroupScreen(groupId: group.groupId)),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
