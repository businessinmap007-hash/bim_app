import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/retail_listing.dart';
import '../data/retail_listings_api.dart';

final retailListingsApiProvider = Provider<RetailListingsApi>((ref) {
  return RetailListingsApi(ref.watch(apiClientProvider));
});

class RetailListingsState {
  final List<RetailListing> items;
  final String query;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const RetailListingsState({
    this.items = const [],
    this.query = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  RetailListingsState copyWith({
    List<RetailListing>? items,
    String? query,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return RetailListingsState(
      items: items ?? this.items,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RetailListingsController extends StateNotifier<RetailListingsState> {
  final RetailListingsApi _api;
  int _page = 1;

  RetailListingsController(this._api) : super(const RetailListingsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(q: state.query, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(q: state.query, page: _page + 1);
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

  Future<void> create({
    required int catalogProductId,
    required double price,
    int? stock,
    String? sku,
  }) async {
    await _api.create(catalogProductId: catalogProductId, price: price, stock: stock, sku: sku);
    await load();
  }

  Future<void> update(
    int id, {
    required double price,
    int? stock,
    String? sku,
    required bool isActive,
  }) async {
    await _api.update(id, price: price, stock: stock, sku: sku, isActive: isActive);
    await load();
  }

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((i) => i.id != id).toList());
    try {
      await _api.delete(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    }
  }
}

final retailListingsControllerProvider = StateNotifierProvider<RetailListingsController, RetailListingsState>((ref) {
  return RetailListingsController(ref.watch(retailListingsApiProvider));
});
