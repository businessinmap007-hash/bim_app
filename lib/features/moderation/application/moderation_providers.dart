import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/moderation_api.dart';

final moderationApiProvider = Provider<ModerationApi>((ref) {
  return ModerationApi(ref.watch(apiClientProvider));
});

final reportReasonsProvider = FutureProvider.autoDispose<List<ReportReason>>((
  ref,
) {
  return ref.watch(moderationApiProvider).reasons();
});

class ReportQueueState {
  final List<ReportedItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ReportQueueState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  ReportQueueState copyWith({
    List<ReportedItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) => ReportQueueState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    error: clearError ? null : (error ?? this.error),
  );
}

/// The moderator's queue, 50 rows a page; the family argument is "handled" (false = still open).
class ReportQueueController extends StateNotifier<ReportQueueState> {
  final ModerationApi _api;
  final bool handled;
  int _page = 1;

  ReportQueueController(this._api, this.handled)
    : super(const ReportQueueState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final r = await _api.queue(handled: handled);
      state = state.copyWith(
        items: r.items,
        hasMore: r.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final r = await _api.queue(handled: handled, page: _page + 1);
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...r.items],
        hasMore: r.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final reportQueueProvider = StateNotifierProvider.autoDispose
    .family<ReportQueueController, ReportQueueState, bool>((ref, handled) {
      return ReportQueueController(ref.watch(moderationApiProvider), handled);
    });
