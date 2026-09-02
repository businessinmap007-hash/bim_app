import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/retail_listings_providers.dart';
import '../../data/models/catalog_product_summary.dart';
import '../../data/models/retail_listing.dart';

/// Api\V2\BusinessRetailListingController — a retail business's own priced
/// listings over the shared catalog master. Visibility/audience (wholesale
/// targeting) stay AdminV2-only; every listing created here is public, the
/// common case.
class RetailListingsScreen extends ConsumerStatefulWidget {
  const RetailListingsScreen({super.key});

  @override
  ConsumerState<RetailListingsScreen> createState() => _RetailListingsScreenState();
}

class _RetailListingsScreenState extends ConsumerState<RetailListingsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(retailListingsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddFlow() async {
    final l10n = AppLocalizations.of(context)!;
    final product = await showModalBottomSheet<CatalogProductSummary>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ProductPickerSheet(),
    );
    if (product == null || !mounted) return;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ListingFormSheet(product: product),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSave)));
    }
  }

  Future<void> _editListing(RetailListing listing) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ListingFormSheet(existing: listing),
    );
  }

  Future<void> _delete(RetailListing listing) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.retailListingDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(retailListingsControllerProvider.notifier).delete(listing.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(retailListingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.retailListingsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddFlow,
        icon: const Icon(Icons.add),
        label: Text(l10n.retailListingAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.retailListingsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () =>
                      ref.read(retailListingsControllerProvider.notifier).setQuery(_searchController.text),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => ref.read(retailListingsControllerProvider.notifier).setQuery(q),
            ),
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
                          onPressed: () => ref.read(retailListingsControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.retailListingsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(retailListingsControllerProvider.notifier).load(),
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
                        final listing = state.items[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () => _editListing(listing),
                            leading: CircleAvatar(
                              backgroundImage: listing.productImageUrl != null
                                  ? NetworkImage(listing.productImageUrl!)
                                  : null,
                              child: listing.productImageUrl == null
                                  ? const Icon(Icons.inventory_2_outlined)
                                  : null,
                            ),
                            title: Text(
                              listing.productName ?? '#${listing.productId}',
                              style: TextStyle(color: listing.isActive ? null : Theme.of(context).hintColor),
                            ),
                            subtitle: listing.stock != null ? Text('${listing.stock}') : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${listing.price.toStringAsFixed(2)} ${listing.currency}'),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delete(listing),
                                ),
                              ],
                            ),
                          ),
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

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _controller = TextEditingController();
  List<CatalogProductSummary> _results = const [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      final results = await ref.read(retailListingsApiProvider).lookup(q);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.retailListingPickTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.retailListingLookupHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _search(_controller.text),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : !_searched
                    ? const SizedBox.shrink()
                    : _results.isEmpty
                    ? Center(child: Text(l10n.retailListingLookupEmpty))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = _results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: product.imageUrl != null ? NetworkImage(product.imageUrl!) : null,
                              child: product.imageUrl == null ? const Icon(Icons.inventory_2_outlined) : null,
                            ),
                            title: Text(product.name),
                            subtitle: product.brand != null ? Text(product.brand!) : null,
                            onTap: () => Navigator.of(context).pop(product),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingFormSheet extends ConsumerStatefulWidget {
  final CatalogProductSummary? product;
  final RetailListing? existing;
  const _ListingFormSheet({this.product, this.existing});

  @override
  ConsumerState<_ListingFormSheet> createState() => _ListingFormSheetState();
}

class _ListingFormSheetState extends ConsumerState<_ListingFormSheet> {
  late final _priceController = TextEditingController(text: widget.existing?.price.toStringAsFixed(2) ?? '');
  late final _stockController = TextEditingController(text: widget.existing?.stock?.toString() ?? '');
  late final _skuController = TextEditingController(text: widget.existing?.sku ?? '');
  late bool _isActive = widget.existing?.isActive ?? true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price < 0) {
      setState(() => _error = l10n.retailPriceRequired);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final stock = int.tryParse(_stockController.text.trim());
      final sku = _skuController.text.trim();
      if (widget.existing == null) {
        await ref
            .read(retailListingsControllerProvider.notifier)
            .create(catalogProductId: widget.product!.id, price: price, stock: stock, sku: sku);
      } else {
        await ref
            .read(retailListingsControllerProvider.notifier)
            .update(widget.existing!.id, price: price, stock: stock, sku: sku, isActive: _isActive);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = widget.existing?.productName ?? widget.product?.name ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? name : l10n.retailListingEditTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (widget.existing != null) ...[
                const SizedBox(height: 4),
                Text(name, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.retailListingPriceHint),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.retailListingStockHint),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _skuController,
                decoration: InputDecoration(labelText: l10n.retailListingSkuHint),
              ),
              if (widget.existing != null) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.retailListingActiveLabel),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
