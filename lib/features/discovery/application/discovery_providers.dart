import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/discovery_api.dart';
import '../data/models/business_summary.dart';

final discoveryApiProvider = Provider<DiscoveryApi>((ref) {
  return DiscoveryApi(ref.watch(apiClientProvider));
});

class BusinessListState {
  final List<BusinessSummary> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String query;

  const BusinessListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
    this.query = '',
  });

  BusinessListState copyWith({
    List<BusinessSummary>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    String? query,
  }) {
    return BusinessListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
    );
  }
}

class BusinessListController extends StateNotifier<BusinessListState> {
  final DiscoveryApi _api;
  final int childId;
  int _page = 1;

  BusinessListController(this._api, this.childId)
    : super(const BusinessListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.businesses(
        childId: childId,
        q: state.query,
        page: _page,
      );
      state = state.copyWith(
        items: result.items,
        isLoading: false,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.businesses(
        childId: childId,
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

  void search(String q) {
    state = state.copyWith(query: q);
    load();
  }
}

final businessListControllerProvider =
    StateNotifierProvider.family<
      BusinessListController,
      BusinessListState,
      int
    >(
      (ref, childId) =>
          BusinessListController(ref.watch(discoveryApiProvider), childId),
    );
