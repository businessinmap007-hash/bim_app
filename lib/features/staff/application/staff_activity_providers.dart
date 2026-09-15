import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/staff_activity.dart';
import '../data/staff_activity_api.dart';

final staffActivityApiProvider = Provider<StaffActivityApi>((ref) {
  return StaffActivityApi(ref.watch(apiClientProvider));
});

class StaffActivityState {
  final List<StaffActivityEntry> rows;
  final List<StaffActivitySummaryEntry> summary;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final DateTime from;
  final DateTime to;
  final int? userId;

  StaffActivityState({
    this.rows = const [],
    this.summary = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
    DateTime? from,
    DateTime? to,
    this.userId,
  }) : from = from ?? DateTime.now(),
       to = to ?? DateTime.now();

  StaffActivityState copyWith({
    List<StaffActivityEntry>? rows,
    List<StaffActivitySummaryEntry>? summary,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    DateTime? from,
    DateTime? to,
    int? userId,
    bool clearUserId = false,
  }) {
    return StaffActivityState(
      rows: rows ?? this.rows,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      from: from ?? this.from,
      to: to ?? this.to,
      userId: clearUserId ? null : (userId ?? this.userId),
    );
  }
}

/// End-of-shift review: every staff-attributed action, filterable by date
/// range and staff member, plus a whole-period per-staff operation count
/// (`summary`) that ignores the staff-member filter so the dropdown/cards
/// always show everyone, even while one person's rows are filtered in.
class StaffActivityController extends StateNotifier<StaffActivityState> {
  final StaffActivityApi _api;
  int _page = 1;

  StaffActivityController(this._api) : super(StaffActivityState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final page = await _api.fetch(from: state.from, to: state.to, userId: state.userId, page: _page);
      state = state.copyWith(rows: page.rows, summary: page.summary, isLoading: false, hasMore: page.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _api.fetch(from: state.from, to: state.to, userId: state.userId, page: _page + 1);
      _page += 1;
      state = state.copyWith(rows: [...state.rows, ...page.rows], isLoadingMore: false, hasMore: page.hasMore);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> setRange(DateTime from, DateTime to) async {
    state = state.copyWith(from: from, to: to);
    await load();
  }

  Future<void> setUserId(int? userId) async {
    state = state.copyWith(userId: userId, clearUserId: userId == null);
    await load();
  }
}

final staffActivityControllerProvider =
    StateNotifierProvider.autoDispose<StaffActivityController, StaffActivityState>((ref) {
      return StaffActivityController(ref.watch(staffActivityApiProvider));
    });
