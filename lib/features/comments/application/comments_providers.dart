import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/comments_api.dart';
import '../data/models/comment.dart';

final commentsApiProvider = Provider<CommentsApi>((ref) {
  return CommentsApi(ref.watch(apiClientProvider));
});

class CommentsListState {
  final List<Comment> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isPosting;
  final String? error;

  const CommentsListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.isPosting = false,
    this.error,
  });

  CommentsListState copyWith({
    List<Comment>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isPosting,
    String? error,
    bool clearError = false,
  }) {
    return CommentsListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isPosting: isPosting ?? this.isPosting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// The top-level comments on one post.
class PostCommentsController extends StateNotifier<CommentsListState> {
  final CommentsApi _api;
  final int postId;
  int _page = 1;

  PostCommentsController(this._api, this.postId) : super(const CommentsListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final page = await _api.forPost(postId, page: _page);
      state = state.copyWith(items: page.items, isLoading: false, hasMore: page.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _api.forPost(postId, page: _page + 1);
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> add(String body, {bool private = false}) async {
    state = state.copyWith(isPosting: true);
    try {
      final comment = await _api.add(postId, body, private: private);
      state = state.copyWith(items: [comment, ...state.items], isPosting: false);
    } catch (e) {
      state = state.copyWith(isPosting: false);
      rethrow;
    }
  }

  Future<void> update(int commentId, String body) async {
    final updated = await _api.update(commentId, body);
    state = state.copyWith(items: [for (final c in state.items) c.id == commentId ? updated : c]);
  }

  Future<void> delete(int commentId) async {
    await _api.delete(commentId);
    state = state.copyWith(items: state.items.where((c) => c.id != commentId).toList());
  }
}

final postCommentsControllerProvider =
    StateNotifierProvider.family<PostCommentsController, CommentsListState, int>((ref, postId) {
      return PostCommentsController(ref.watch(commentsApiProvider), postId);
    });

/// The replies under one top-level comment — a separate provider per
/// comment, only built when its thread is expanded (Riverpod families are
/// lazy: nothing fetches until first watched).
class CommentRepliesController extends StateNotifier<CommentsListState> {
  final CommentsApi _api;
  final int commentId;
  int _page = 1;

  CommentRepliesController(this._api, this.commentId) : super(const CommentsListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final page = await _api.replies(commentId, page: _page);
      state = state.copyWith(items: page.items, isLoading: false, hasMore: page.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _api.replies(commentId, page: _page + 1);
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> add(String body) async {
    state = state.copyWith(isPosting: true);
    try {
      final reply = await _api.reply(commentId, body);
      state = state.copyWith(items: [...state.items, reply], isPosting: false);
    } catch (e) {
      state = state.copyWith(isPosting: false);
      rethrow;
    }
  }

  Future<void> delete(int replyId) async {
    await _api.delete(replyId);
    state = state.copyWith(items: state.items.where((c) => c.id != replyId).toList());
  }
}

final commentRepliesControllerProvider =
    StateNotifierProvider.family<CommentRepliesController, CommentsListState, int>((ref, commentId) {
      return CommentRepliesController(ref.watch(commentsApiProvider), commentId);
    });
