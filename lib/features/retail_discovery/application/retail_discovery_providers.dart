import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/catalog_product_listing.dart';
import '../data/retail_discovery_api.dart';

final retailDiscoveryApiProvider = Provider<RetailDiscoveryApi>((ref) {
  return RetailDiscoveryApi(ref.watch(apiClientProvider));
});

final retailFiltersProvider = FutureProvider.autoDispose<RetailFilters>((ref) {
  return ref.watch(retailDiscoveryApiProvider).filters();
});

typedef ProductOffersParams = int;

final productOffersProvider = FutureProvider.autoDispose.family<ProductDetail, ProductOffersParams>((ref, productId) {
  return ref.watch(retailDiscoveryApiProvider).show(productId);
});

class ShopProductsState {
  final List<CatalogProductSummary> items;
  final String query;
  final int? categoryId;
  final int? childId;
  final int? brandId;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ShopProductsState({
    this.items = const [],
    this.query = '',
    this.categoryId,
    this.childId,
    this.brandId,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  ShopProductsState copyWith({
    List<CatalogProductSummary>? items,
    String? query,
    int? categoryId,
    bool clearCategoryId = false,
    int? childId,
    bool clearChildId = false,
    int? brandId,
    bool clearBrandId = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ShopProductsState(
      items: items ?? this.items,
      query: query ?? this.query,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      childId: clearChildId ? null : (childId ?? this.childId),
      brandId: clearBrandId ? null : (brandId ?? this.brandId),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ShopProductsController extends StateNotifier<ShopProductsState> {
  final RetailDiscoveryApi _api;
  int _page = 1;

  ShopProductsController(this._api) : super(const ShopProductsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.products(
        categoryId: state.categoryId,
        childId: state.childId,
        brandId: state.brandId,
        q: state.query,
        page: _page,
      );
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.products(
        categoryId: state.categoryId,
        childId: state.childId,
        brandId: state.brandId,
        q: state.query,
        page: _page + 1,
      );
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...result.items],
        isLoadingMore: false,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> setQuery(String q) async {
    state = state.copyWith(query: q);
    await load();
  }

  Future<void> setCategoryId(int? id) async {
    state = state.copyWith(categoryId: id, clearCategoryId: id == null);
    await load();
  }

  Future<void> setBrandId(int? id) async {
    state = state.copyWith(brandId: id, clearBrandId: id == null);
    await load();
  }
}

final shopProductsControllerProvider = StateNotifierProvider<ShopProductsController, ShopProductsState>((ref) {
  return ShopProductsController(ref.watch(retailDiscoveryApiProvider));
});
