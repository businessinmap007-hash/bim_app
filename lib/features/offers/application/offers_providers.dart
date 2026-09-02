import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/commercial_offer.dart';
import '../data/models/offer_follow.dart';
import '../data/offers_api.dart';

final offersApiProvider = Provider<OffersApi>((ref) {
  return OffersApi(ref.watch(apiClientProvider));
});

class OffersState {
  final List<CommercialOffer> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String query;
  final String sort;

  const OffersState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
    this.query = '',
    this.sort = 'boosted',
  });

  OffersState copyWith({
    List<CommercialOffer>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    String? query,
    String? sort,
  }) {
    return OffersState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
      sort: sort ?? this.sort,
    );
  }
}

class OffersController extends StateNotifier<OffersState> {
  final OffersApi _api;
  int _page = 1;

  OffersController(this._api) : super(const OffersState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.browse(q: state.query, sort: state.sort, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.browse(q: state.query, sort: state.sort, page: _page + 1);
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

  Future<void> setQuery(String q) async {
    state = state.copyWith(query: q);
    await load();
  }

  Future<void> setSort(String sort) async {
    state = state.copyWith(sort: sort);
    await load();
  }
}

final offersControllerProvider = StateNotifierProvider<OffersController, OffersState>((ref) {
  return OffersController(ref.watch(offersApiProvider));
});

final offerDetailProvider = FutureProvider.family<CommercialOffer, int>((ref, id) async {
  final offer = await ref.watch(offersApiProvider).show(id);
  // Fire-and-forget — a failed impression write should never block the
  // detail screen from rendering.
  unawaited(ref.read(offersApiProvider).track(id).catchError((_) {}));
  return offer;
});

class MyOfferFollowsState {
  final List<OfferFollow> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyOfferFollowsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyOfferFollowsState copyWith({
    List<OfferFollow>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyOfferFollowsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyOfferFollowsController extends StateNotifier<MyOfferFollowsState> {
  final OffersApi _api;
  int _page = 1;

  MyOfferFollowsController(this._api) : super(const MyOfferFollowsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.myFollows(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.myFollows(page: _page + 1);
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

  Future<void> unfollow(int followId) async {
    await _api.unfollow(followId);
    state = state.copyWith(items: state.items.where((f) => f.id != followId).toList());
  }
}

final myOfferFollowsControllerProvider =
    StateNotifierProvider<MyOfferFollowsController, MyOfferFollowsState>((ref) {
      return MyOfferFollowsController(ref.watch(offersApiProvider));
    });
