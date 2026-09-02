import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/business_prices_api.dart';
import '../data/models/price_options.dart';
import '../data/models/price_row.dart';

final businessPricesApiProvider = Provider<BusinessPricesApi>((ref) {
  return BusinessPricesApi(ref.watch(apiClientProvider));
});

final priceOptionsProvider = FutureProvider.autoDispose<PriceOptions>((ref) {
  return ref.watch(businessPricesApiProvider).options();
});

class BusinessPricesState {
  final List<PriceRow> items;
  final int? serviceId;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const BusinessPricesState({
    this.items = const [],
    this.serviceId,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  BusinessPricesState copyWith({
    List<PriceRow>? items,
    int? serviceId,
    bool clearServiceId = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return BusinessPricesState(
      items: items ?? this.items,
      serviceId: clearServiceId ? null : (serviceId ?? this.serviceId),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BusinessPricesController extends StateNotifier<BusinessPricesState> {
  final BusinessPricesApi _api;
  int _page = 1;

  BusinessPricesController(this._api) : super(const BusinessPricesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(serviceId: state.serviceId, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(serviceId: state.serviceId, page: _page + 1);
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

  Future<void> setServiceFilter(int? serviceId) async {
    state = state.copyWith(serviceId: serviceId, clearServiceId: serviceId == null);
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

final businessPricesControllerProvider = StateNotifierProvider<BusinessPricesController, BusinessPricesState>((ref) {
  return BusinessPricesController(ref.watch(businessPricesApiProvider));
});
