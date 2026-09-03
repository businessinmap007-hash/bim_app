import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/placed_order.dart';
import '../data/orders_api.dart';
import 'orders_providers.dart';

class BusinessOrdersState {
  final List<PlacedOrder> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const BusinessOrdersState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  BusinessOrdersState copyWith({
    List<PlacedOrder>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return BusinessOrdersState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BusinessOrdersController extends StateNotifier<BusinessOrdersState> {
  final OrdersApi _api;
  int _page = 1;
  String? _status;

  BusinessOrdersController(this._api) : super(const BusinessOrdersState()) {
    load();
  }

  Future<void> load({String? status}) async {
    _status = status;
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.businessList(status: _status, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.businessList(status: _status, page: _page + 1);
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

final businessOrdersControllerProvider =
    StateNotifierProvider<BusinessOrdersController, BusinessOrdersState>((ref) {
      return BusinessOrdersController(ref.watch(ordersApiProvider));
    });

class BusinessOrderDetailState {
  final PlacedOrder? order;
  final bool isLoading;
  final bool isBusy;
  final String? error;

  const BusinessOrderDetailState({this.order, this.isLoading = false, this.isBusy = false, this.error});

  BusinessOrderDetailState copyWith({
    PlacedOrder? order,
    bool? isLoading,
    bool? isBusy,
    String? error,
    bool clearError = false,
  }) {
    return BusinessOrderDetailState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BusinessOrderDetailController extends StateNotifier<BusinessOrderDetailState> {
  final OrdersApi _api;
  final int orderId;

  BusinessOrderDetailController(this._api, this.orderId) : super(const BusinessOrderDetailState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final order = await _api.businessShow(orderId);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> reject({String? reason}) async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessReject(orderId, reason: reason);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> accept({bool acceptWithoutDeposit = false}) async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessAccept(orderId, acceptWithoutDeposit: acceptWithoutDeposit);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> markPreparing() async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessPreparing(orderId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> markReady() async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessReady(orderId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }
}

final businessOrderDetailControllerProvider =
    StateNotifierProvider.family<BusinessOrderDetailController, BusinessOrderDetailState, int>((ref, orderId) {
      return BusinessOrderDetailController(ref.watch(ordersApiProvider), orderId);
    });
