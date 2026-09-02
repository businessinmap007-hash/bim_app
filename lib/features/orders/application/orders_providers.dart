import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/placed_order.dart';
import '../data/orders_api.dart';

final ordersApiProvider = Provider<OrdersApi>((ref) {
  return OrdersApi(ref.watch(apiClientProvider));
});

class MyOrdersState {
  final List<PlacedOrder> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyOrdersState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyOrdersState copyWith({
    List<PlacedOrder>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyOrdersState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyOrdersController extends StateNotifier<MyOrdersState> {
  final OrdersApi _api;
  int _page = 1;

  MyOrdersController(this._api) : super(const MyOrdersState()) {
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

  /// Replaces one row with the freshly loaded detail (has `items`, unlike the
  /// list rows) so the detail sheet can show a cancelled/updated order
  /// without a full reload.
  Future<PlacedOrder> loadDetail(int id) async {
    final detail = await _api.show(id);
    state = state.copyWith(items: [for (final o in state.items) o.id == id ? detail : o]);
    return detail;
  }

  Future<PlacedOrder> cancel(int id, {String? reason}) async {
    final updated = await _api.cancel(id, reason: reason);
    state = state.copyWith(items: [for (final o in state.items) o.id == id ? updated : o]);
    return updated;
  }
}

final myOrdersControllerProvider = StateNotifierProvider<MyOrdersController, MyOrdersState>((ref) {
  return MyOrdersController(ref.watch(ordersApiProvider));
});
