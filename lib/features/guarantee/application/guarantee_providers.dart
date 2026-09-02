import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/guarantee_api.dart';
import '../data/models/guarantee_level.dart';

final guaranteeApiProvider = Provider<GuaranteeApi>((ref) {
  return GuaranteeApi(ref.watch(apiClientProvider));
});

final guaranteeLevelsProvider = FutureProvider<List<GuaranteeLevel>>((ref) {
  return ref.watch(guaranteeApiProvider).levels();
});

final guaranteeMeProvider = FutureProvider<GuaranteeMe>((ref) {
  return ref.watch(guaranteeApiProvider).me();
});

class GuaranteeTransactionsState {
  final List<GuaranteeTransaction> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const GuaranteeTransactionsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  GuaranteeTransactionsState copyWith({
    List<GuaranteeTransaction>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return GuaranteeTransactionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class GuaranteeTransactionsController extends StateNotifier<GuaranteeTransactionsState> {
  final GuaranteeApi _api;
  int _page = 1;

  GuaranteeTransactionsController(this._api) : super(const GuaranteeTransactionsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final page = await _api.transactions(page: _page);
      state = state.copyWith(items: page.items, isLoading: false, hasMore: page.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _api.transactions(page: _page + 1);
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final guaranteeTransactionsControllerProvider =
    StateNotifierProvider<GuaranteeTransactionsController, GuaranteeTransactionsState>((ref) {
      return GuaranteeTransactionsController(ref.watch(guaranteeApiProvider));
    });
