import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/wallet_summary.dart';
import '../data/models/wallet_transaction.dart';
import '../data/wallet_api.dart';

final walletApiProvider = Provider<WalletApi>((ref) {
  return WalletApi(ref.watch(apiClientProvider));
});

final walletSummaryProvider = FutureProvider<WalletSummary>((ref) {
  return ref.watch(walletApiProvider).show();
});

class WalletTransactionsState {
  final List<WalletTransaction> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const WalletTransactionsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  WalletTransactionsState copyWith({
    List<WalletTransaction>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return WalletTransactionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WalletTransactionsController extends StateNotifier<WalletTransactionsState> {
  final WalletApi _api;
  int _page = 1;

  WalletTransactionsController(this._api) : super(const WalletTransactionsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.transactions(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.transactions(page: _page + 1);
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
}

final walletTransactionsControllerProvider =
    StateNotifierProvider<WalletTransactionsController, WalletTransactionsState>((ref) {
      return WalletTransactionsController(ref.watch(walletApiProvider));
    });
