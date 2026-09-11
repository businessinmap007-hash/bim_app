import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/app_notification.dart';
import '../data/notifications_api.dart';

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(apiClientProvider));
});

/// Just the unread badge count — its own provider (rather than reading off
/// [notificationsControllerProvider]) so the bell icon on the home app bars
/// can show a number without pulling in the full list screen's state.
/// Invalidated (not polled) after anything that can change the count: the
/// notifications screen loading, marking one/all read, or archiving.
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(notificationsApiProvider).unreadCount();
});

class NotificationsState {
  final List<AppNotification> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  final NotificationsApi _api;
  final Ref _ref;
  int _page = 1;

  NotificationsController(this._api, this._ref) : super(const NotificationsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(page: _page);
      state = state.copyWith(
        items: result.page.items,
        isLoading: false,
        hasMore: result.page.hasMore,
      );
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(page: _page + 1);
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...result.page.items],
        isLoadingMore: false,
        hasMore: result.page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> markRead(AppNotification notification) async {
    if (!notification.isUnread) return;
    _replace(notification.copyWith(status: 'read', readAt: DateTime.now()));
    try {
      await _api.markRead(notification.id);
    } finally {
      _ref.invalidate(unreadNotificationCountProvider);
    }
  }

  Future<void> markAllRead() async {
    final now = DateTime.now();
    state = state.copyWith(
      items: [
        for (final n in state.items)
          n.isUnread ? n.copyWith(status: 'read', readAt: now) : n,
      ],
    );
    try {
      await _api.markAllRead();
    } finally {
      _ref.invalidate(unreadNotificationCountProvider);
    }
  }

  Future<void> archive(AppNotification notification) async {
    state = state.copyWith(
      items: state.items.where((n) => n.id != notification.id).toList(),
    );
    try {
      await _api.archive(notification.id);
    } finally {
      _ref.invalidate(unreadNotificationCountProvider);
    }
  }

  Future<void> archiveAll() async {
    final previous = state.items;
    state = state.copyWith(items: []);
    try {
      await _api.archiveAll();
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    } finally {
      _ref.invalidate(unreadNotificationCountProvider);
    }
  }

  void _replace(AppNotification updated) {
    state = state.copyWith(
      items: [
        for (final n in state.items) n.id == updated.id ? updated : n,
      ],
    );
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
      return NotificationsController(ref.watch(notificationsApiProvider), ref);
    });
