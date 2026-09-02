import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/trip_reservation.dart';
import '../data/models/trip_schedule.dart';
import '../data/schedules_api.dart';

final schedulesApiProvider = Provider<SchedulesApi>((ref) {
  return SchedulesApi(ref.watch(apiClientProvider));
});

class TripSearchState {
  final List<TripScheduleResult> results;
  final bool isLoading;
  final bool searched;
  final String? error;

  const TripSearchState({this.results = const [], this.isLoading = false, this.searched = false, this.error});

  TripSearchState copyWith({
    List<TripScheduleResult>? results,
    bool? isLoading,
    bool? searched,
    String? error,
    bool clearError = false,
  }) {
    return TripSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      searched: searched ?? this.searched,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TripSearchController extends StateNotifier<TripSearchState> {
  final SchedulesApi _api;
  TripSearchController(this._api) : super(const TripSearchState());

  Future<void> search({
    required int originGovernorateId,
    required int destinationGovernorateId,
    DateTime? date,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await _api.search(
        originGovernorateId: originGovernorateId,
        destinationGovernorateId: destinationGovernorateId,
        date: date,
      );
      state = state.copyWith(results: results, isLoading: false, searched: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, searched: true, error: e.toString());
    }
  }
}

final tripSearchControllerProvider = StateNotifierProvider<TripSearchController, TripSearchState>((ref) {
  return TripSearchController(ref.watch(schedulesApiProvider));
});

class MyReservationsState {
  final List<TripReservation> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyReservationsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyReservationsState copyWith({
    List<TripReservation>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyReservationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyReservationsController extends StateNotifier<MyReservationsState> {
  final SchedulesApi _api;
  int _page = 1;

  MyReservationsController(this._api) : super(const MyReservationsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.myReservations(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.myReservations(page: _page + 1);
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

  Future<void> cancel(int id) async {
    await _api.cancel(id);
    state = state.copyWith(
      items: [for (final r in state.items) r.id == id ? _cancelled(r) : r],
    );
  }

  TripReservation _cancelled(TripReservation r) => TripReservation(
    id: r.id,
    tripScheduleId: r.tripScheduleId,
    units: r.units,
    unitPrice: r.unitPrice,
    totalPrice: r.totalPrice,
    currency: r.currency,
    status: 'cancelled',
    notes: r.notes,
    createdAt: r.createdAt,
  );
}

final myReservationsControllerProvider =
    StateNotifierProvider<MyReservationsController, MyReservationsState>((ref) {
      return MyReservationsController(ref.watch(schedulesApiProvider));
    });
