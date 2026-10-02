import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/menu_search_api.dart';
import '../data/models/menu_search.dart';

final menuSearchApiProvider = Provider<MenuSearchApi>((ref) {
  return MenuSearchApi(ref.watch(apiClientProvider));
});

final searchKindsProvider = FutureProvider.autoDispose<List<SearchKind>>((ref) {
  return ref.watch(menuSearchApiProvider).kinds();
});

/// Every shop that sells one exact product, cheapest first — the comparison.
final productComparisonProvider = FutureProvider.autoDispose.family<SearchPage, int>((ref, productId) {
  return ref.watch(menuSearchApiProvider).search(catalogProductId: productId, sort: 'price_asc');
});

class MenuSearchState {
  final String? kind;
  final String query;
  final SearchFilters filters;
  final String sort;
  final List<SearchItem> items;
  final Map<String, SearchFacet> facets;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool failed;

  const MenuSearchState({
    this.kind,
    this.query = '',
    this.filters = const SearchFilters(),
    this.sort = 'price_asc',
    this.items = const [],
    this.facets = const {},
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.failed = false,
  });

  MenuSearchState copyWith({
    String? kind,
    bool clearKind = false,
    String? query,
    SearchFilters? filters,
    String? sort,
    List<SearchItem>? items,
    Map<String, SearchFacet>? facets,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? failed,
  }) {
    return MenuSearchState(
      kind: clearKind ? null : (kind ?? this.kind),
      query: query ?? this.query,
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      items: items ?? this.items,
      facets: facets ?? this.facets,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      failed: failed ?? this.failed,
    );
  }
}

class MenuSearchController extends StateNotifier<MenuSearchState> {
  final MenuSearchApi _api;
  int _page = 1;
  // A slow answer for a filter the customer already changed must not overwrite
  // the newer one.
  int _generation = 0;

  MenuSearchController(this._api) : super(const MenuSearchState());

  Future<void> load() async {
    final generation = ++_generation;
    _page = 1;
    state = state.copyWith(isLoading: true, failed: false);
    try {
      final page = await _api.search(kind: state.kind, q: state.query, filters: state.filters, sort: state.sort);
      if (generation != _generation) return;
      state = state.copyWith(
        items: page.items,
        facets: page.facets,
        total: page.total,
        hasMore: page.hasMore,
        isLoading: false,
      );
    } catch (_) {
      if (generation != _generation) return;
      state = state.copyWith(isLoading: false, failed: true);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final generation = _generation;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _api.search(
        kind: state.kind,
        q: state.query,
        filters: state.filters,
        sort: state.sort,
        page: _page + 1,
      );
      if (generation != _generation) return;
      _page += 1;
      state = state.copyWith(items: [...state.items, ...page.items], hasMore: page.hasMore, isLoadingMore: false);
    } catch (_) {
      if (generation == _generation) state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Another kind has other fields — the old kind's filters mean nothing there.
  Future<void> setKind(String? kind) {
    state = state.copyWith(kind: kind, clearKind: kind == null, filters: const SearchFilters());
    return load();
  }

  Future<void> setQuery(String q) {
    state = state.copyWith(query: q);
    return load();
  }

  Future<void> setFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    return load();
  }

  Future<void> setSort(String sort) {
    state = state.copyWith(sort: sort);
    return load();
  }
}

final menuSearchControllerProvider =
    StateNotifierProvider.autoDispose<MenuSearchController, MenuSearchState>((ref) {
      return MenuSearchController(ref.watch(menuSearchApiProvider));
    });
