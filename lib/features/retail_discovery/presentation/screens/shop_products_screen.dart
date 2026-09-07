import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/retail_discovery_providers.dart';
import '../../data/models/catalog_product_listing.dart';
import 'product_offers_screen.dart';

/// Api\V2\RetailDiscoveryController — cross-business product marketplace:
/// browse a catalog product, see its price range and how many businesses
/// sell it, then open one to compare sellers. Reached from the app drawer.
class ShopProductsScreen extends ConsumerStatefulWidget {
  const ShopProductsScreen({super.key});

  @override
  ConsumerState<ShopProductsScreen> createState() => _ShopProductsScreenState();
}

class _ShopProductsScreenState extends ConsumerState<ShopProductsScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(shopProductsControllerProvider.notifier).loadMore();
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(shopProductsControllerProvider.notifier).setQuery(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(shopProductsControllerProvider);
    final filtersAsync = ref.watch(retailFiltersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopProductsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: l10n.shopProductsSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          filtersAsync.when(
            data: (filters) => _BrandFilterBar(
              brands: filters.brands,
              selectedId: state.brandId,
              onChanged: (id) => ref.read(shopProductsControllerProvider.notifier).setBrandId(id),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
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
                          onPressed: () => ref.read(shopProductsControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.shopProductsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(shopProductsControllerProvider.notifier).load(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _ProductTile(product: state.items[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BrandFilterBar extends StatelessWidget {
  final List<RetailFilterFacet> brands;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _BrandFilterBar({required this.brands, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: MouseWheelHorizontalScroll(
        builder: (context, controller) => ListView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(l10n.shopProductsFilterAllBrands),
                selected: selectedId == null,
                onSelected: (_) => onChanged(null),
              ),
            ),
            for (final brand in brands)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${brand.name} (${brand.products})'),
                  selected: selectedId == brand.id,
                  onSelected: (_) => onChanged(brand.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final CatalogProductSummary product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceLabel = product.minPrice == product.maxPrice
        ? product.minPrice.toStringAsFixed(0)
        : '${product.minPrice.toStringAsFixed(0)} - ${product.maxPrice.toStringAsFixed(0)}';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductOffersScreen(productId: product.id)),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: product.image != null
                ? CachedNetworkImage(imageUrl: product.image!, fit: BoxFit.cover)
                : Container(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                    child: const Icon(Icons.inventory_2_outlined),
                  ),
          ),
        ),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [product.brand, product.package].where((s) => s.isNotEmpty).join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$priceLabel EGP', style: Theme.of(context).textTheme.titleSmall),
            Text(
              '${product.businesses} ${l10n.shopProductsSellersLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
