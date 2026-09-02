import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../chat/data/models/thread_message.dart';
import '../data/models/body_report.dart';
import '../data/models/training_plan.dart';
import '../data/models/weekly_summary.dart';
import '../data/training_api.dart';

final trainingApiProvider = Provider<TrainingApi>((ref) {
  return TrainingApi(ref.watch(apiClientProvider));
});

class MyTrainingPlansState {
  final List<TrainingPlan> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyTrainingPlansState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyTrainingPlansState copyWith({
    List<TrainingPlan>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyTrainingPlansState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyTrainingPlansController extends StateNotifier<MyTrainingPlansState> {
  final TrainingApi _api;
  int _page = 1;

  MyTrainingPlansController(this._api) : super(const MyTrainingPlansState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.myPlans(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.myPlans(page: _page + 1);
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

final myTrainingPlansControllerProvider =
    StateNotifierProvider<MyTrainingPlansController, MyTrainingPlansState>((ref) {
      return MyTrainingPlansController(ref.watch(trainingApiProvider));
    });

/// One plan in full — the caller invalidates this after logging progress,
/// completing a round, etc. to pick up the fresh state from the server.
final trainingPlanDetailProvider = FutureProvider.family<TrainingPlan, int>((ref, planId) async {
  return ref.watch(trainingApiProvider).plan(planId);
});

final trainingWeeklySummaryProvider = FutureProvider.family<TrainingWeeklySummary, int>((ref, planId) async {
  return ref.watch(trainingApiProvider).weeklySummary(planId);
});

final trainingBodyReportsProvider = FutureProvider.family<List<BodyReport>, int>((ref, planId) async {
  return ref.watch(trainingApiProvider).bodyReports(planId);
});

class TrainingChatState {
  final List<ThreadMessage> messages;
  final ChatThread? thread;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const TrainingChatState({
    this.messages = const [],
    this.thread,
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  TrainingChatState copyWith({
    List<ThreadMessage>? messages,
    ChatThread? thread,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return TrainingChatState(
      messages: messages ?? this.messages,
      thread: thread ?? this.thread,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TrainingChatController extends StateNotifier<TrainingChatState> {
  final TrainingApi _api;
  final int planId;

  TrainingChatController(this._api, this.planId) : super(const TrainingChatState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _api.chatShow(planId);
      state = state.copyWith(
        messages: page.messages.reversed.toList(),
        thread: page.thread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> send(String body) async {
    if (body.trim().isEmpty || state.isSending) return;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final message = await _api.chatPost(planId, body.trim());
      state = state.copyWith(messages: [...state.messages, message], isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}

final trainingChatControllerProvider =
    StateNotifierProvider.family<TrainingChatController, TrainingChatState, int>((ref, planId) {
      return TrainingChatController(ref.watch(trainingApiProvider), planId);
    });
