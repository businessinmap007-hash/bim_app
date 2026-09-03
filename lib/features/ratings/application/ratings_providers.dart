import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/my_rating.dart';
import '../data/models/operation_review.dart';
import '../data/ratings_api.dart';

final ratingsApiProvider = Provider<RatingsApi>((ref) {
  return RatingsApi(ref.watch(apiClientProvider));
});

class ReviewsState {
  final List<OperationReview> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ReviewsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  ReviewsState copyWith({
    List<OperationReview>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ReviewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ReviewsController extends StateNotifier<ReviewsState> {
  final RatingsApi _api;
  final int userId;
  int _page = 1;

  ReviewsController(this._api, this.userId) : super(const ReviewsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.reviews(userId, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.reviews(userId, page: _page + 1);
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

final reviewsControllerProvider =
    StateNotifierProvider.family<ReviewsController, ReviewsState, int>((ref, userId) {
      return ReviewsController(ref.watch(ratingsApiProvider), userId);
    });

class MyRatingController extends StateNotifier<AsyncValue<MyRating>> {
  final RatingsApi _api;

  MyRatingController(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.me());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> enable() async {
    await _api.enable();
    await load();
  }

  Future<void> disable() async {
    await _api.disable();
    await load();
  }
}

final myRatingControllerProvider = StateNotifierProvider<MyRatingController, AsyncValue<MyRating>>((ref) {
  return MyRatingController(ref.watch(ratingsApiProvider));
});
