import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/chat_api.dart';
import '../data/models/thread_message.dart';

final operationChatApiProvider = Provider<OperationChatApi>((ref) {
  return OperationChatApi(ref.watch(apiClientProvider));
});

class OperationChatKey {
  final String type;
  final int id;
  const OperationChatKey(this.type, this.id);

  @override
  bool operator ==(Object other) =>
      other is OperationChatKey && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

class OperationChatState {
  final List<ThreadMessage> messages;
  final ChatThread? thread;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const OperationChatState({
    this.messages = const [],
    this.thread,
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  OperationChatState copyWith({
    List<ThreadMessage>? messages,
    ChatThread? thread,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return OperationChatState(
      messages: messages ?? this.messages,
      thread: thread ?? this.thread,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OperationChatController extends StateNotifier<OperationChatState> {
  final OperationChatApi _api;
  final OperationChatKey key;

  OperationChatController(this._api, this.key) : super(const OperationChatState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _api.show(key.type, key.id);
      // Server returns newest-first; a chat reads top-to-bottom oldest-first.
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
      final message = await _api.postMessage(key.type, key.id, body.trim());
      state = state.copyWith(messages: [...state.messages, message], isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}

final operationChatControllerProvider = StateNotifierProvider.family<
    OperationChatController, OperationChatState, OperationChatKey>((ref, key) {
  return OperationChatController(ref.watch(operationChatApiProvider), key);
});
