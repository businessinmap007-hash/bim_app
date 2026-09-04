import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../business/data/models/business_post.dart';
import '../data/models/followed_account.dart';
import '../data/models/job_post.dart';
import '../data/posts_api.dart';

final postsApiProvider = Provider<PostsApi>((ref) {
  return PostsApi(ref.watch(apiClientProvider));
});

class PostsListState {
  final List<BusinessPost> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const PostsListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  PostsListState copyWith({
    List<BusinessPost>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return PostsListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Shared load/loadMore/react/remove shape for any paginated post list —
/// only which page to fetch differs between "my posts" and the followed
/// feed, so that's the one thing subclasses supply.
abstract class PostsListController extends StateNotifier<PostsListState> {
  final PostsApi api;
  int _page = 1;

  PostsListController(this.api) : super(const PostsListState()) {
    load();
  }

  Future<PostsPage> fetchPage(int page);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await fetchPage(_page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await fetchPage(_page + 1);
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

  /// Optimistic: flips the heart immediately, rolls back if the request fails.
  Future<void> react(int postId, int reaction) async {
    final index = state.items.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final previous = state.items[index];
    final liked = reaction == 1;
    final updated = BusinessPost(
      id: previous.id,
      type: previous.type,
      title: previous.title,
      body: previous.body,
      imageUrl: previous.imageUrl,
      images: previous.images,
      author: previous.author,
      myReaction: liked ? 1 : null,
      isMine: previous.isMine,
      likesCount: previous.likesCount + (liked ? 1 : -1),
      dislikesCount: previous.dislikesCount,
      commentsCount: previous.commentsCount,
      createdAt: previous.createdAt,
    );

    final items = [...state.items];
    items[index] = updated;
    state = state.copyWith(items: items);

    try {
      await api.react(postId, reaction);
    } catch (_) {
      final rolledBack = [...state.items];
      final currentIndex = rolledBack.indexWhere((p) => p.id == postId);
      if (currentIndex != -1) rolledBack[currentIndex] = previous;
      state = state.copyWith(items: rolledBack);
    }
  }

  Future<void> remove(int postId) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((p) => p.id != postId).toList());
    try {
      await api.deletePost(postId);
    } catch (_) {
      state = state.copyWith(items: previous);
      rethrow;
    }
  }
}

/// My own posts wall (GET /posts/mine).
class MyPostsController extends PostsListController {
  MyPostsController(super.api);

  @override
  Future<PostsPage> fetchPage(int page) => api.mine(page: page);
}

/// The followed-accounts feed (GET /posts) — see PostAudienceService.
class FollowedFeedController extends PostsListController {
  FollowedFeedController(super.api);

  @override
  Future<PostsPage> fetchPage(int page) => api.feed(page: page);
}

final myPostsControllerProvider = StateNotifierProvider<MyPostsController, PostsListState>((ref) {
  return MyPostsController(ref.watch(postsApiProvider));
});

final followedFeedControllerProvider = StateNotifierProvider<FollowedFeedController, PostsListState>((ref) {
  return FollowedFeedController(ref.watch(postsApiProvider));
});

class MyJobsState {
  final List<JobPost> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyJobsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyJobsState copyWith({
    List<JobPost>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyJobsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// My own vacancies (GET /jobs/mine) — business accounts only.
class MyJobsController extends StateNotifier<MyJobsState> {
  final PostsApi _api;
  int _page = 1;

  MyJobsController(this._api) : super(const MyJobsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.mineJobs(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.mineJobs(page: _page + 1);
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

  Future<void> remove(int jobId) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((j) => j.id != jobId).toList());
    try {
      await _api.deleteJob(jobId);
    } catch (_) {
      state = state.copyWith(items: previous);
      rethrow;
    }
  }
}

final myJobsControllerProvider = StateNotifierProvider<MyJobsController, MyJobsState>((ref) {
  return MyJobsController(ref.watch(postsApiProvider));
});

class MyFollowsState {
  final List<FollowedAccount> items;
  final bool isLoading;
  final String? error;

  const MyFollowsState({this.items = const [], this.isLoading = false, this.error});

  MyFollowsState copyWith({List<FollowedAccount>? items, bool? isLoading, String? error, bool clearError = false}) {
    return MyFollowsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Accounts feeding the "Following" tab's feed (GET/DELETE /follows) —
/// reviewed and pruned separately from following itself, which happens on
/// each business's own page.
class MyFollowsController extends StateNotifier<MyFollowsState> {
  final PostsApi _api;

  MyFollowsController(this._api) : super(const MyFollowsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.follows();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unfollow(int businessId) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((f) => f.id != businessId).toList());
    try {
      await _api.unfollow(businessId);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    }
  }
}

final myFollowsControllerProvider = StateNotifierProvider<MyFollowsController, MyFollowsState>((ref) {
  return MyFollowsController(ref.watch(postsApiProvider));
});
