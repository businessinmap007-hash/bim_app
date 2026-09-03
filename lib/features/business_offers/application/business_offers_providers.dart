import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../business_menu/application/business_menu_providers.dart';
import '../../business_prices/application/business_prices_providers.dart';
import '../../offers/data/models/commercial_offer.dart';
import '../../retail_listings/application/retail_listings_providers.dart';
import '../data/business_offers_api.dart';
import '../data/models/offer_boost_package.dart';
import '../data/models/offer_boost_purchase.dart';
import '../data/models/offers_usage.dart';
import '../data/offerable_items_api.dart';

final businessOffersApiProvider = Provider<BusinessOffersApi>((ref) {
  return BusinessOffersApi(ref.watch(apiClientProvider));
});

final offerableItemsApiProvider = Provider<OfferableItemsApi>((ref) {
  return OfferableItemsApi(
    ref.watch(businessMenuApiProvider),
    ref.watch(retailListingsApiProvider),
    ref.watch(businessPricesApiProvider),
  );
});

final boostPackagesProvider = FutureProvider.autoDispose<List<OfferBoostPackage>>((ref) {
  return ref.watch(businessOffersApiProvider).boostPackages();
});

class BusinessOffersState {
  final List<CommercialOffer> items;
  final String? status;
  final OffersUsage? usage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const BusinessOffersState({
    this.items = const [],
    this.status,
    this.usage,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  BusinessOffersState copyWith({
    List<CommercialOffer>? items,
    String? status,
    bool clearStatus = false,
    OffersUsage? usage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return BusinessOffersState(
      items: items ?? this.items,
      status: clearStatus ? null : (status ?? this.status),
      usage: usage ?? this.usage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BusinessOffersController extends StateNotifier<BusinessOffersState> {
  final BusinessOffersApi _api;
  int _page = 1;

  BusinessOffersController(this._api) : super(const BusinessOffersState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(status: state.status, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore, usage: result.usage);
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
        usage: result.usage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> setStatus(String? status) async {
    state = state.copyWith(status: status, clearStatus: status == null);
    await load();
  }

  Future<void> toggle(int id) async {
    final updated = await _api.toggle(id);
    state = state.copyWith(items: [for (final o in state.items) if (o.id == id) updated else o]);
  }

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((o) => o.id != id).toList());
    try {
      await _api.delete(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    }
  }
}

final businessOffersControllerProvider = StateNotifierProvider<BusinessOffersController, BusinessOffersState>((ref) {
  return BusinessOffersController(ref.watch(businessOffersApiProvider));
});

class BoostPurchasesState {
  final List<OfferBoostPurchase> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const BoostPurchasesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  BoostPurchasesState copyWith({
    List<OfferBoostPurchase>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return BoostPurchasesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BoostPurchasesController extends StateNotifier<BoostPurchasesState> {
  final BusinessOffersApi _api;
  int _page = 1;

  BoostPurchasesController(this._api) : super(const BoostPurchasesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.boostPurchases(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.boostPurchases(page: _page + 1);
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

final boostPurchasesControllerProvider = StateNotifierProvider<BoostPurchasesController, BoostPurchasesState>((ref) {
  return BoostPurchasesController(ref.watch(businessOffersApiProvider));
});
