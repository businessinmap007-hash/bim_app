import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/trip_run.dart';
import '../data/schedules_api.dart';
import 'schedules_providers.dart';

class TripRunState {
  final TripRun? run;
  final bool isLoading;
  final bool isActing;
  final String? error;

  const TripRunState({this.run, this.isLoading = false, this.isActing = false, this.error});

  TripRunState copyWith({TripRun? run, bool? isLoading, bool? isActing, String? error, bool clearError = false}) {
    return TripRunState(
      run: run ?? this.run,
      isLoading: isLoading ?? this.isLoading,
      isActing: isActing ?? this.isActing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Drives one run's live detail screen — arrive/advance/reconcile. autoDispose
/// so reopening a run (the driver leaving and coming back to the app) always
/// re-fetches instead of showing whatever was cached from the last visit —
/// see [[chat-reopen-stale-cache-fix]] for why that matters here too.
class TripRunController extends StateNotifier<TripRunState> {
  final SchedulesApi _api;
  final int runId;

  TripRunController(this._api, this.runId) : super(const TripRunState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final run = await _api.run(runId);
      state = state.copyWith(run: run, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> arrive() => _act(() => _api.arriveAtStop(runId));

  Future<void> advance() => _act(() => _api.advanceRun(runId));

  Future<void> reconcile(Map<int, ({int delivered, int returned})> items) =>
      _act(() => _api.reconcileRun(runId, items));

  Future<void> _act(Future<TripRun> Function() call) async {
    if (state.isActing) return;
    state = state.copyWith(isActing: true, clearError: true);
    try {
      final run = await call();
      state = state.copyWith(run: run, isActing: false);
    } catch (e) {
      state = state.copyWith(isActing: false, error: e.toString());
      rethrow;
    }
  }
}

final tripRunControllerProvider = StateNotifierProvider.autoDispose.family<TripRunController, TripRunState, int>((
  ref,
  runId,
) {
  return TripRunController(ref.watch(schedulesApiProvider), runId);
});
