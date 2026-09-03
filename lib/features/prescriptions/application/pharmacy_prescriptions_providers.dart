import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/prescription.dart';
import '../data/pharmacy_prescriptions_api.dart';

final pharmacyPrescriptionsApiProvider = Provider<PharmacyPrescriptionsApi>((ref) {
  return PharmacyPrescriptionsApi(ref.watch(apiClientProvider));
});

class PharmacyQueueState {
  final List<Prescription> items;
  final String? status;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const PharmacyQueueState({
    this.items = const [],
    this.status,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  PharmacyQueueState copyWith({
    List<Prescription>? items,
    String? status,
    bool clearStatus = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return PharmacyQueueState(
      items: items ?? this.items,
      status: clearStatus ? null : (status ?? this.status),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PharmacyQueueController extends StateNotifier<PharmacyQueueState> {
  final PharmacyPrescriptionsApi _api;
  int _page = 1;

  PharmacyQueueController(this._api) : super(const PharmacyQueueState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.incoming(status: state.status, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.incoming(status: state.status, page: _page + 1);
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

  Future<void> setStatus(String? status) async {
    state = state.copyWith(status: status, clearStatus: status == null);
    await load();
  }
}

final pharmacyQueueControllerProvider = StateNotifierProvider<PharmacyQueueController, PharmacyQueueState>((ref) {
  return PharmacyQueueController(ref.watch(pharmacyPrescriptionsApiProvider));
});
