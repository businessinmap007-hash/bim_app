import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/deposits_api.dart';
import '../data/models/deposit.dart';

final depositsApiProvider = Provider<DepositsApi>((ref) {
  return DepositsApi(ref.watch(apiClientProvider));
});

class DepositsState {
  final List<Deposit> items;
  final String? status;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const DepositsState({
    this.items = const [],
    this.status,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  DepositsState copyWith({
    List<Deposit>? items,
    String? status,
    bool clearStatus = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return DepositsState(
      items: items ?? this.items,
      status: clearStatus ? null : (status ?? this.status),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DepositsController extends StateNotifier<DepositsState> {
  final DepositsApi _api;
  int _page = 1;

  DepositsController(this._api) : super(const DepositsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(status: state.status, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(status: state.status, page: _page + 1);
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

  Future<void> filterByStatus(String? status) async {
    state = status == null
        ? state.copyWith(clearStatus: true)
        : state.copyWith(status: status);
    await load();
  }
}

final depositsControllerProvider = StateNotifierProvider<DepositsController, DepositsState>((ref) {
  return DepositsController(ref.watch(depositsApiProvider));
});
