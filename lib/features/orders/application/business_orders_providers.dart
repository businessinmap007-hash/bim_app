import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/order_reports.dart';
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
  final int? businessId;
  int _page = 1;
  String? _status;

  BusinessOrdersController(this._api, this.businessId) : super(const BusinessOrdersState()) {
    load();
  }

  Future<void> load({String? status}) async {
    _status = status;
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.businessList(status: _status, page: _page, businessId: businessId);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.businessList(status: _status, page: _page + 1, businessId: businessId);
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

/// Keyed by the business a delegated staff member acts for (null = the
/// business account itself).
final businessOrdersControllerProvider =
    StateNotifierProvider.family<BusinessOrdersController, BusinessOrdersState, int?>((ref, businessId) {
      return BusinessOrdersController(ref.watch(ordersApiProvider), businessId);
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
  final int? businessId;

  BusinessOrderDetailController(this._api, this.orderId, this.businessId) : super(const BusinessOrderDetailState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final order = await _api.businessShow(orderId, businessId: businessId);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> reject({String? reason}) async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessReject(orderId, reason: reason, businessId: businessId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> accept({bool acceptWithoutDeposit = false}) async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessAccept(orderId, acceptWithoutDeposit: acceptWithoutDeposit, businessId: businessId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> markPreparing() async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessPreparing(orderId, businessId: businessId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> markReady() async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessReady(orderId, businessId: businessId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  /// Pickup/dine-in only -- a delivery order completes through the QR
  /// handover instead (DeliveryDispatchService.confirmDelivery).
  Future<void> complete() async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessComplete(orderId, businessId: businessId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> confirmPayment() async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessConfirmPayment(orderId, businessId: businessId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> markItemUnavailable(int itemId, {String? note}) async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _api.businessMarkItemUnavailable(orderId, itemId, note: note, businessId: businessId);
      state = state.copyWith(order: order, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }
}

typedef BusinessOrderKey = ({int orderId, int? businessId});

final businessOrderDetailControllerProvider =
    StateNotifierProvider.family<BusinessOrderDetailController, BusinessOrderDetailState, BusinessOrderKey>((ref, key) {
      return BusinessOrderDetailController(ref.watch(ordersApiProvider), key.orderId, key.businessId);
    });

class BusinessOrderReportsState {
  final OrderReports? reports;
  final bool isLoading;
  final String? error;
  final DateTime from;
  final DateTime to;

  BusinessOrderReportsState({this.reports, this.isLoading = false, this.error, DateTime? from, DateTime? to})
    : to = to ?? DateTime.now(),
      from = from ?? DateTime.now().subtract(const Duration(days: 29));

  BusinessOrderReportsState copyWith({
    OrderReports? reports,
    bool? isLoading,
    String? error,
    bool clearError = false,
    DateTime? from,
    DateTime? to,
  }) {
    return BusinessOrderReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

class BusinessOrderReportsController extends StateNotifier<BusinessOrderReportsState> {
  final OrdersApi _api;

  BusinessOrderReportsController(this._api) : super(BusinessOrderReportsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final reports = await _api.businessReports(from: state.from, to: state.to);
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Presets the merchant picks from -- 7/30/90 days back from today.
  Future<void> setRangeDays(int days) async {
    final to = DateTime.now();
    state = state.copyWith(from: to.subtract(Duration(days: days - 1)), to: to);
    await load();
  }

  Future<void> setCustomRange(DateTime from, DateTime to) async {
    state = state.copyWith(from: from, to: to);
    await load();
  }
}

final businessOrderReportsControllerProvider =
    StateNotifierProvider<BusinessOrderReportsController, BusinessOrderReportsState>((ref) {
      return BusinessOrderReportsController(ref.watch(ordersApiProvider));
    });
