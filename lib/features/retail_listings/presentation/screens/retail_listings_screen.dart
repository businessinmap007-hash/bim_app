import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/produce_emoji.dart';
import '../../../../shared/utils/retail_quantity_format.dart';
import '../../../../shared/widgets/business_picker_sheet.dart';
import '../../../business_groups/data/models/business_group.dart';
import '../../../business_groups/presentation/widgets/business_group_picker_sheet.dart';
import '../../../categories/presentation/widgets/category_picker_field.dart';
import '../../../discovery/data/models/business_summary.dart';
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

class _RetailListingsScreenState extends ConsumerState<RetailListingsScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late final _tabController = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));

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
    _tabController.dispose();
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

  Future<void> _editVisibility(RetailListing listing) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _VisibilityEditSheet(existing: listing),
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
      appBar: AppBar(
        title: Text(l10n.retailListingsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.retailListingsProductsTab),
            Tab(text: l10n.retailListingsVisibilityTab),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddFlow,
              icon: const Icon(Icons.add),
              label: Text(l10n.retailListingAdd),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
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
                                      ? Text(produceEmoji(listing.productNameEn), style: const TextStyle(fontSize: 18))
                                      : null,
                                ),
                                title: Text(
                                  listing.productName ?? '#${listing.productId}',
                                  style: TextStyle(color: listing.isActive ? null : Theme.of(context).hintColor),
                                ),
                                subtitle: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (listing.stock != null)
                                      Text(
                                        l10n.retailListingAvailableQtyBadge(
                                          formatRetailQty(listing.stock!, listing.unit),
                                        ),
                                      ),
                                    if (listing.minOrderQty != null) ...[
                                      if (listing.stock != null) const SizedBox(width: 6),
                                      Text(
                                        l10n.retailListingMinOrderQtyBadge(
                                          formatRetailQty(listing.minOrderQty!, listing.unit),
                                        ),
                                        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                                      ),
                                    ],
                                    if (listing.isRestricted) ...[
                                      if (listing.stock != null) const SizedBox(width: 6),
                                      Icon(Icons.lock_outline, size: 14, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 2),
                                      Text(
                                        l10n.retailListingRestrictedBadge,
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                                      ),
                                    ],
                                  ],
                                ),
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
          _VisibilityTab(state: state, onTap: _editVisibility),
        ],
      ),
    );
  }
}

/// The second "My Products" tab: who sees what, one row per listing —
/// separated from the price/stock form since it's a different concern the
/// merchant reaches for far less often (see [[bim-app-frontend-gap-filling]]).
class _VisibilityTab extends StatelessWidget {
  final RetailListingsState state;
  final ValueChanged<RetailListing> onTap;

  const _VisibilityTab({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return Center(child: Text(l10n.retailListingsEmpty));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final listing = state.items[index];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            onTap: () => onTap(listing),
            leading: CircleAvatar(
              backgroundImage: listing.productImageUrl != null ? NetworkImage(listing.productImageUrl!) : null,
              child: listing.productImageUrl == null
                  ? Text(produceEmoji(listing.productNameEn), style: const TextStyle(fontSize: 18))
                  : null,
            ),
            title: Text(listing.productName ?? '#${listing.productId}'),
            trailing: listing.isRestricted
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.retailListingRestrictedBadge,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  )
                : Text(l10n.retailListingVisibilityPublic, style: TextStyle(color: Theme.of(context).hintColor)),
          ),
        );
      },
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

  @override
  void initState() {
    super.initState();
    // Show what this business already carries the moment the sheet opens —
    // the backend's lookup() is already scoped to the item types the
    // owner's own category child offers under retail, so an empty query
    // isn't "search everything," it's "browse my own product types." A
    // merchant shouldn't have to guess a search term for a product that's
    // already within the one list they sell from.
    _search('');
  }

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
  // A small closed set per locale, plus an "other" escape hatch — a dropdown
  // avoids typos ("kgs" vs "kg" vs "كيلو") for the common cases while still
  // letting a merchant name their own wholesale unit (a sack, a dozen...)
  // the backend column is free text either way.
  static const _unitPresetsAr = ['كيلو', 'جرام', 'طن', 'كرتونة', 'شوال', 'دستة', 'قطعة', 'لتر'];
  static const _unitPresetsEn = ['kg', 'g', 'ton', 'carton', 'sack', 'dozen', 'piece', 'liter'];
  static const _kOtherUnit = '__other__';

  late final _priceController = TextEditingController(text: widget.existing?.price.toStringAsFixed(2) ?? '');
  late final _stockController = TextEditingController(text: widget.existing?.stock?.toString() ?? '');
  late final _minOrderQtyController = TextEditingController(text: widget.existing?.minOrderQty?.toString() ?? '');
  late final _unitController = TextEditingController(text: widget.existing?.unit ?? '');
  String? _unitPreset;
  bool _unitPresetInitialized = false;
  late final _skuController = TextEditingController(text: widget.existing?.sku ?? '');
  late bool _isActive = widget.existing?.isActive ?? true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _minOrderQtyController.dispose();
    _unitController.dispose();
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
      final minOrderQty = int.tryParse(_minOrderQtyController.text.trim());
      final unit = _unitPreset == _kOtherUnit ? _unitController.text.trim() : (_unitPreset ?? '');
      final sku = _skuController.text.trim();
      if (widget.existing == null) {
        await ref
            .read(retailListingsControllerProvider.notifier)
            .create(
              catalogProductId: widget.product!.id,
              price: price,
              stock: stock,
              minOrderQty: minOrderQty,
              unit: unit,
              sku: sku,
            );
      } else {
        // Who-sees-this is edited from the "Visibility" tab instead (see
        // _VisibilityEditSheet) — carried through here UNCHANGED so a plain
        // price/stock save never resets a listing back to public.
        final existing = widget.existing!;
        await ref
            .read(retailListingsControllerProvider.notifier)
            .update(
              existing.id,
              price: price,
              stock: stock,
              minOrderQty: minOrderQty,
              unit: unit,
              sku: sku,
              isActive: _isActive,
              visibility: existing.visibility,
              audienceChildIds: existing.audienceChildren.map((e) => e.id).toList(),
              audienceBusinessIds: existing.audienceBusinesses.map((e) => e.id).toList(),
              audienceCategoryIds: existing.audienceCategoryIds,
            );
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
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final unitPresets = isEnglish ? _unitPresetsEn : _unitPresetsAr;

    if (!_unitPresetInitialized) {
      _unitPresetInitialized = true;
      final existingUnit = widget.existing?.unit;
      if (existingUnit == null || existingUnit.isEmpty) {
        _unitPreset = null;
      } else if (unitPresets.contains(existingUnit)) {
        _unitPreset = existingUnit;
      } else {
        _unitPreset = _kOtherUnit;
        _unitController.text = existingUnit;
      }
    }

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _minOrderQtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.retailListingMinOrderQtyLabel,
                        hintText: l10n.retailListingMinOrderQtyHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unitPreset,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.retailListingUnitLabel),
                      items: [
                        for (final u in unitPresets) DropdownMenuItem(value: u, child: Text(u)),
                        DropdownMenuItem(value: _kOtherUnit, child: Text(l10n.retailListingUnitOther)),
                      ],
                      onChanged: (v) => setState(() {
                        _unitPreset = v;
                        if (v != null && v != _kOtherUnit) _unitController.text = v;
                      }),
                    ),
                  ),
                ],
              ),
              if (_unitPreset == _kOtherUnit) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _unitController,
                  decoration: InputDecoration(hintText: l10n.retailListingUnitHint),
                ),
              ],
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

/// The "Visibility" tab's edit surface for one listing — who sees it, split
/// out of the price/stock form (see _ListingFormSheet) so changing a price
/// never risks touching who can even see the listing, and vice versa.
class _VisibilityEditSheet extends ConsumerStatefulWidget {
  final RetailListing existing;
  const _VisibilityEditSheet({required this.existing});

  @override
  ConsumerState<_VisibilityEditSheet> createState() => _VisibilityEditSheetState();
}

class _VisibilityEditSheetState extends ConsumerState<_VisibilityEditSheet> {
  late String _visibility = widget.existing.visibility;
  late final List<RetailAudienceEntry> _audienceChildren = List.of(widget.existing.audienceChildren);
  late final List<RetailAudienceEntry> _audienceBusinesses = List.of(widget.existing.audienceBusinesses);
  bool _saving = false;
  String? _error;

  Future<void> _addShopType() async {
    final selection = await showModalBottomSheet<CategorySelection>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CategoryPickerSheet(),
    );
    if (selection == null) return;
    if (_audienceChildren.any((e) => e.id == selection.childId)) return;
    setState(() => _audienceChildren.add(RetailAudienceEntry(id: selection.childId, name: selection.label)));
  }

  Future<void> _addBusiness() async {
    final picked = await showModalBottomSheet<BusinessSummary>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const BusinessPickerSheet(),
    );
    if (picked == null) return;
    if (_audienceBusinesses.any((e) => e.id == picked.id)) return;
    setState(() => _audienceBusinesses.add(RetailAudienceEntry(id: picked.id, name: picked.name)));
  }

  /// Adds every member of a saved business group at once — see
  /// [[bim-business-groups]] — instead of searching for each business again.
  Future<void> _addBusinessGroup() async {
    final group = await showModalBottomSheet<BusinessGroup>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const BusinessGroupPickerSheet(),
    );
    if (group == null) return;
    setState(() {
      for (final m in group.members) {
        if (_audienceBusinesses.any((e) => e.id == m.businessId)) continue;
        _audienceBusinesses.add(RetailAudienceEntry(id: m.businessId, name: m.name));
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_visibility == 'restricted' && _audienceChildren.isEmpty && _audienceBusinesses.isEmpty) {
      setState(() => _error = l10n.retailListingAudienceRequired);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final existing = widget.existing;
      await ref
          .read(retailListingsControllerProvider.notifier)
          .update(
            existing.id,
            price: existing.price,
            stock: existing.stock,
            minOrderQty: existing.minOrderQty,
            unit: existing.unit,
            sku: existing.sku,
            isActive: existing.isActive,
            visibility: _visibility,
            audienceChildIds: _audienceChildren.map((e) => e.id).toList(),
            audienceBusinessIds: _audienceBusinesses.map((e) => e.id).toList(),
            audienceCategoryIds: existing.audienceCategoryIds,
          );
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
    final name = widget.existing.productName ?? '#${widget.existing.productId}';

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.retailListingVisibilityLabel, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(name, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: 'public',
                groupValue: _visibility,
                onChanged: (v) => setState(() => _visibility = v!),
                title: Text(l10n.retailListingVisibilityPublic),
                subtitle: Text(l10n.retailListingVisibilityPublicHint),
              ),
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: 'restricted',
                groupValue: _visibility,
                onChanged: (v) => setState(() => _visibility = v!),
                title: Text(l10n.retailListingVisibilityRestricted),
                subtitle: Text(l10n.retailListingVisibilityRestrictedHint),
              ),
              if (_visibility == 'restricted') ...[
                const SizedBox(height: 4),
                _AudienceSection(
                  label: l10n.retailListingAudienceShopTypesLabel,
                  addLabel: l10n.retailListingAddShopType,
                  emptyLabel: l10n.retailListingAudienceEmpty,
                  entries: _audienceChildren,
                  onAdd: _addShopType,
                  onRemove: (i) => setState(() => _audienceChildren.removeAt(i)),
                ),
                const SizedBox(height: 12),
                _AudienceSection(
                  label: l10n.retailListingAudienceBusinessesLabel,
                  addLabel: l10n.retailListingAddBusiness,
                  emptyLabel: l10n.retailListingAudienceEmpty,
                  entries: _audienceBusinesses,
                  onAdd: _addBusiness,
                  onRemove: (i) => setState(() => _audienceBusinesses.removeAt(i)),
                  addGroupLabel: l10n.retailListingAddBusinessGroup,
                  onAddGroup: _addBusinessGroup,
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

/// One named-audience list inside the restricted-visibility form — a wrap of
/// removable chips plus an "add" chip, shared between the shop-type and the
/// specific-business sections since both are just "a list of named things
/// with an add button" once the id is already resolved to a label.
class _AudienceSection extends StatelessWidget {
  final String label;
  final String addLabel;
  final String emptyLabel;
  final List<RetailAudienceEntry> entries;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final String? addGroupLabel;
  final VoidCallback? onAddGroup;

  const _AudienceSection({
    required this.label,
    required this.addLabel,
    required this.emptyLabel,
    required this.entries,
    required this.onAdd,
    required this.onRemove,
    this.addGroupLabel,
    this.onAddGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (entries.isEmpty)
              Text(emptyLabel, style: TextStyle(color: Theme.of(context).hintColor))
            else
              for (var i = 0; i < entries.length; i++)
                Chip(label: Text(entries[i].name), onDeleted: () => onRemove(i)),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(addLabel),
              onPressed: onAdd,
            ),
            if (onAddGroup != null)
              ActionChip(
                avatar: const Icon(Icons.groups_outlined, size: 18),
                label: Text(addGroupLabel!),
                onPressed: onAddGroup,
              ),
          ],
        ),
      ],
    );
  }
}
