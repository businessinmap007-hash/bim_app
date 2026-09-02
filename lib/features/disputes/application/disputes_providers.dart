import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../chat/data/models/thread_message.dart';
import '../data/disputes_api.dart';
import '../data/models/conduct_charter.dart';
import '../data/models/dispute.dart';

final disputesApiProvider = Provider<DisputesApi>((ref) {
  return DisputesApi(ref.watch(apiClientProvider));
});

final disputeReasonCodesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(disputesApiProvider).reasonCodes();
});

class MyDisputesState {
  final List<Dispute> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyDisputesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyDisputesState copyWith({
    List<Dispute>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyDisputesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyDisputesController extends StateNotifier<MyDisputesState> {
  final DisputesApi _api;
  int _page = 1;

  MyDisputesController(this._api) : super(const MyDisputesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.myDisputes(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.myDisputes(page: _page + 1);
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

final myDisputesControllerProvider = StateNotifierProvider<MyDisputesController, MyDisputesState>((ref) {
  return MyDisputesController(ref.watch(disputesApiProvider));
});

/// One dispute in full — callers invalidate this after any action that
/// changes its state (cooperate, settlement, arbitration request, closure).
final disputeDetailProvider = FutureProvider.family<DisputeDetail, int>((ref, id) async {
  return ref.watch(disputesApiProvider).show(id);
});

final settlementPaymentsProvider = FutureProvider.family<SettlementPaymentsPage, int>((ref, disputeId) async {
  return ref.watch(disputesApiProvider).settlementPayments(disputeId);
});

final disputeConductProvider = FutureProvider.family<ConductCharter, int>((ref, disputeId) async {
  return ref.watch(disputesApiProvider).conduct(disputeId);
});

final disputeObligationsProvider = FutureProvider<ObligationsSummary>((ref) {
  return ref.watch(disputesApiProvider).obligationsSummary();
});

class DisputeRoomState {
  final List<ThreadMessage> messages;
  final bool locked;
  final bool conductAccepted;
  final int conductVersion;
  final bool purged;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const DisputeRoomState({
    this.messages = const [],
    this.locked = false,
    this.conductAccepted = false,
    this.conductVersion = 1,
    this.purged = false,
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  DisputeRoomState copyWith({
    List<ThreadMessage>? messages,
    bool? locked,
    bool? conductAccepted,
    int? conductVersion,
    bool? purged,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return DisputeRoomState(
      messages: messages ?? this.messages,
      locked: locked ?? this.locked,
      conductAccepted: conductAccepted ?? this.conductAccepted,
      conductVersion: conductVersion ?? this.conductVersion,
      purged: purged ?? this.purged,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DisputeRoomController extends StateNotifier<DisputeRoomState> {
  final DisputesApi _api;
  final int disputeId;

  DisputeRoomController(this._api, this.disputeId) : super(const DisputeRoomState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _api.room(disputeId);
      state = state.copyWith(
        messages: page.messages.reversed.toList(),
        locked: page.locked,
        conductAccepted: page.conductAccepted,
        conductVersion: page.conductVersion,
        purged: page.purged,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> acceptConduct() async {
    await _api.acceptConduct(disputeId);
    state = state.copyWith(conductAccepted: true);
  }

  Future<void> declineConduct() async {
    await _api.declineConduct(disputeId);
    state = state.copyWith(conductAccepted: false);
  }

  Future<void> send(String body, {String? imagePath}) async {
    if (body.trim().isEmpty && imagePath == null) return;
    if (state.isSending) return;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final message = await _api.postMessage(disputeId, body.trim(), imagePath: imagePath);
      state = state.copyWith(messages: [...state.messages, message], isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      rethrow;
    }
  }
}

final disputeRoomControllerProvider =
    StateNotifierProvider.family<DisputeRoomController, DisputeRoomState, int>((ref, disputeId) {
      return DisputeRoomController(ref.watch(disputesApiProvider), disputeId);
    });
