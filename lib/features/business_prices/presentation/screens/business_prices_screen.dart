import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_prices_providers.dart';
import '../../data/models/price_options.dart';
import '../../data/models/price_row.dart';
import 'price_form_screen.dart';

/// Api\V2\BusinessServicePriceController — a business's own price per
/// (service, item type, line) it actually offers.
class BusinessPricesScreen extends ConsumerStatefulWidget {
  const BusinessPricesScreen({super.key});

  @override
  ConsumerState<BusinessPricesScreen> createState() => _BusinessPricesScreenState();
}

class _BusinessPricesScreenState extends ConsumerState<BusinessPricesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(businessPricesControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PriceFormScreen()),
    );
    if (created == true) {
      ref.read(businessPricesControllerProvider.notifier).load();
    }
  }

  Future<void> _openEdit(PriceRow row) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PriceFormScreen(existing: row)),
    );
    if (updated == true) {
      ref.read(businessPricesControllerProvider.notifier).load();
    }
  }

  Future<void> _delete(PriceRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.businessPriceDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(businessPricesControllerProvider.notifier).delete(row.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessPricesControllerProvider);
    final optionsAsync = ref.watch(priceOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessPricesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.businessPricesAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(l10n.businessPricesSubtitle, style: Theme.of(context).textTheme.bodySmall),
          ),
          optionsAsync.when(
            data: (options) => _ServiceFilterBar(
              services: options.services,
              selectedId: state.serviceId,
              onChanged: (id) => ref.read(businessPricesControllerProvider.notifier).setServiceFilter(id),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(businessPricesControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.businessPricesEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(businessPricesControllerProvider.notifier).load(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final row = state.items[index];
                        return _PriceCard(
                          row: row,
                          onTap: () => _openEdit(row),
                          onDelete: () => _delete(row),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ServiceFilterBar extends StatelessWidget {
  final List<PriceServiceOption> services;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _ServiceFilterBar({required this.services, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(l10n.businessPricesFilterAll),
              selected: selectedId == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final service in services)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(service.name ?? service.key ?? '#${service.id}'),
                selected: selectedId == service.id,
                onSelected: (_) => onChanged(service.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final PriceRow row;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PriceCard({required this.row, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtitleParts = <String>[
      row.bookableItemType,
      if (row.label != null && row.label!.isNotEmpty) row.label!,
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text(row.service.name ?? row.service.key ?? '#${row.service.id}'),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${row.price.toStringAsFixed(2)} ${row.currency}', style: Theme.of(context).textTheme.titleSmall),
                if (row.discountEnabled && row.discountPercent > 0)
                  Text('-${row.discountPercent}%', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                if (!row.isActive)
                  Text(l10n.priceFieldActive, style: TextStyle(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough)),
              ],
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
