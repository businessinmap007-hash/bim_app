import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../chat/data/models/thread_message.dart';
import '../data/general_chat_api.dart';
import '../data/models/chat_thread_summary.dart';
import '../data/models/direct_chat_thread.dart';

final generalChatApiProvider = Provider<GeneralChatApi>((ref) {
  return GeneralChatApi(ref.watch(apiClientProvider));
});

class ChatsListState {
  final List<ChatThreadSummary> items;
  final bool isLoading;
  final String? error;

  const ChatsListState({this.items = const [], this.isLoading = false, this.error});

  ChatsListState copyWith({List<ChatThreadSummary>? items, bool? isLoading, String? error, bool clearError = false}) {
    return ChatsListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatsListController extends StateNotifier<ChatsListState> {
  final GeneralChatApi _api;

  ChatsListController(this._api) : super(const ChatsListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.list();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// autoDispose: a chats-list visit that's no longer on screen is dropped, so
// reopening the list (or a specific thread below) always re-fetches instead
// of showing whatever was cached from the last visit.
final chatsListControllerProvider = StateNotifierProvider.autoDispose<ChatsListController, ChatsListState>((ref) {
  return ChatsListController(ref.watch(generalChatApiProvider));
});

class ChatThreadState {
  final List<ThreadMessage> messages;
  final DirectChatThread? thread;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatThreadState({
    this.messages = const [],
    this.thread,
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatThreadState copyWith({
    List<ThreadMessage>? messages,
    DirectChatThread? thread,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ChatThreadState(
      messages: messages ?? this.messages,
      thread: thread ?? this.thread,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatThreadController extends StateNotifier<ChatThreadState> {
  final GeneralChatApi _api;
  final int threadId;

  ChatThreadController(this._api, this.threadId) : super(const ChatThreadState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _api.show(threadId);
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
      final message = await _api.postMessage(threadId, body.trim());
      state = state.copyWith(messages: [...state.messages, message], isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> rename(String title) async {
    final thread = await _api.rename(threadId, title);
    state = state.copyWith(thread: thread);
  }

  Future<void> addMember(int userId) async {
    final thread = await _api.addMember(threadId, userId);
    state = state.copyWith(thread: thread);
  }

  Future<void> removeMember(int userId) async {
    final thread = await _api.removeMember(threadId, userId);
    state = state.copyWith(thread: thread);
  }
}

final chatThreadControllerProvider =
    StateNotifierProvider.autoDispose.family<ChatThreadController, ChatThreadState, int>((ref, threadId) {
      return ChatThreadController(ref.watch(generalChatApiProvider), threadId);
    });
