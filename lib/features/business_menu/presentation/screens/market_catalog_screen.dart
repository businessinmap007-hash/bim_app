import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _editLowStockThreshold(BuildContext context, WidgetRef ref, int? current) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: current?.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.marketCatalogLowStockSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.marketCatalogLowStockSettingsHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.marketCatalogLowStockThreshold,
                hintText: l10n.marketCatalogLowStockNoAlert,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.marketCatalogSave)),
        ],
      ),
    );

    if (saved != true) return;

    final threshold = controller.text.trim().isEmpty ? null : int.tryParse(controller.text.trim());
    await ref.read(marketCatalogControllerProvider.notifier).updateLowStockThreshold(threshold);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.marketCatalogLowStockSaved)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(marketCatalogControllerProvider);

    final forbidden = state.hasError && state.error is ApiException && (state.error as ApiException).isForbidden;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketCatalogTitle),
        actions: forbidden
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: l10n.marketCatalogLowStockSettings,
                  onPressed: () => _editLowStockThreshold(context, ref, state.value?.lowStockThreshold),
                ),
              ],
      ),
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
