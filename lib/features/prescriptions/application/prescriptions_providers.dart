import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/medicines_api.dart';
import '../data/models/prescription.dart';
import '../data/prescriptions_api.dart';

final prescriptionsApiProvider = Provider<PrescriptionsApi>((ref) {
  return PrescriptionsApi(ref.watch(apiClientProvider));
});

final medicinesApiProvider = Provider<MedicinesApi>((ref) {
  return MedicinesApi(ref.watch(apiClientProvider));
});

class MyPrescriptionsState {
  final List<Prescription> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyPrescriptionsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyPrescriptionsState copyWith({
    List<Prescription>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyPrescriptionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyPrescriptionsController extends StateNotifier<MyPrescriptionsState> {
  final PrescriptionsApi _api;
  int _page = 1;

  MyPrescriptionsController(this._api) : super(const MyPrescriptionsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.myPrescriptions(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.myPrescriptions(page: _page + 1);
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

final myPrescriptionsControllerProvider =
    StateNotifierProvider<MyPrescriptionsController, MyPrescriptionsState>((ref) {
      return MyPrescriptionsController(ref.watch(prescriptionsApiProvider));
    });

/// One prescription in full — callers invalidate this after send/cancel/
/// share/add-image/remove-image to pick up the fresh state from the server.
final prescriptionDetailProvider = FutureProvider.family<Prescription, int>((ref, id) async {
  return ref.watch(prescriptionsApiProvider).prescription(id);
});

class IssuedPrescriptionsState {
  final List<Prescription> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const IssuedPrescriptionsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  IssuedPrescriptionsState copyWith({
    List<Prescription>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return IssuedPrescriptionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class IssuedPrescriptionsController extends StateNotifier<IssuedPrescriptionsState> {
  final PrescriptionsApi _api;
  int _page = 1;

  IssuedPrescriptionsController(this._api) : super(const IssuedPrescriptionsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.issuedPrescriptions(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.issuedPrescriptions(page: _page + 1);
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

final issuedPrescriptionsControllerProvider =
    StateNotifierProvider<IssuedPrescriptionsController, IssuedPrescriptionsState>((ref) {
      return IssuedPrescriptionsController(ref.watch(prescriptionsApiProvider));
    });
