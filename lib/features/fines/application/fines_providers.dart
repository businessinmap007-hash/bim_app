import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/fines_api.dart';
import '../data/models/fine.dart';

final finesApiProvider = Provider<FinesApi>((ref) {
  return FinesApi(ref.watch(apiClientProvider));
});

class FinesState {
  final List<Fine> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const FinesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  FinesState copyWith({
    List<Fine>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return FinesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FinesController extends StateNotifier<FinesState> {
  final FinesApi _api;
  int _page = 1;

  FinesController(this._api) : super(const FinesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(page: _page + 1);
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

  Future<void> appeal(int id, String statement) async {
    final updated = await _api.appeal(id, statement);
    state = state.copyWith(items: [for (final f in state.items) f.id == id ? updated : f]);
  }
}

final finesControllerProvider = StateNotifierProvider<FinesController, FinesState>((ref) {
  return FinesController(ref.watch(finesApiProvider));
});
