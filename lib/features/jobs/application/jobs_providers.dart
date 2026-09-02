import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../posts/data/models/job_post.dart';
import '../data/jobs_api.dart';
import '../data/models/job_category.dart';
import '../data/models/job_follow.dart';

final jobsApiProvider = Provider<JobsApi>((ref) {
  return JobsApi(ref.watch(apiClientProvider));
});

final jobCategoriesProvider = FutureProvider<List<JobCategoryGroup>>((ref) {
  return ref.watch(jobsApiProvider).categories();
});

class JobsState {
  final List<JobPost> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String query;
  final int? categoryId;
  final int? categoryChildId;

  const JobsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
    this.query = '',
    this.categoryId,
    this.categoryChildId,
  });

  JobsState copyWith({
    List<JobPost>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    String? query,
    int? categoryId,
    int? categoryChildId,
    bool clearCategory = false,
  }) {
    return JobsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryChildId: clearCategory ? null : (categoryChildId ?? this.categoryChildId),
    );
  }
}

class JobsController extends StateNotifier<JobsState> {
  final JobsApi _api;
  int _page = 1;

  JobsController(this._api) : super(const JobsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.browse(
        q: state.query,
        categoryId: state.categoryId,
        categoryChildId: state.categoryChildId,
        page: _page,
      );
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.browse(
        q: state.query,
        categoryId: state.categoryId,
        categoryChildId: state.categoryChildId,
        page: _page + 1,
      );
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

  Future<void> filterByCategory({int? categoryId, int? categoryChildId}) async {
    if (categoryId == null && categoryChildId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId, categoryChildId: categoryChildId);
    }
    await load();
  }
}

final jobsControllerProvider = StateNotifierProvider<JobsController, JobsState>((ref) {
  return JobsController(ref.watch(jobsApiProvider));
});

final jobDetailProvider = FutureProvider.family<JobPost, int>((ref, id) async {
  return ref.watch(jobsApiProvider).show(id);
});

class JobFollowsState {
  final List<JobFollow> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const JobFollowsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  JobFollowsState copyWith({
    List<JobFollow>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return JobFollowsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class JobFollowsController extends StateNotifier<JobFollowsState> {
  final JobsApi _api;
  int _page = 1;

  JobFollowsController(this._api) : super(const JobFollowsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.follows(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.follows(page: _page + 1);
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

  Future<void> follow({int? categoryId, int? categoryChildId}) async {
    await _api.follow(categoryId: categoryId, categoryChildId: categoryChildId);
    await load();
  }

  Future<void> unfollow(int followId) async {
    await _api.unfollow(followId);
    state = state.copyWith(items: state.items.where((f) => f.id != followId).toList());
  }
}

final jobFollowsControllerProvider = StateNotifierProvider<JobFollowsController, JobFollowsState>((ref) {
  return JobFollowsController(ref.watch(jobsApiProvider));
});
