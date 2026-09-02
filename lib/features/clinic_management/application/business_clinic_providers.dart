import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/business_clinic_api.dart';
import '../data/models/business_clinic_appointment.dart';
import '../data/models/business_clinic_slot.dart';

final businessClinicApiProvider = Provider<BusinessClinicApi>((ref) {
  return BusinessClinicApi(ref.watch(apiClientProvider));
});

// ─────────────────────────── Appointments ───────────────────────────

class ClinicAppointmentsState {
  final List<BusinessClinicAppointment> items;
  final String? status;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ClinicAppointmentsState({
    this.items = const [],
    this.status,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  ClinicAppointmentsState copyWith({
    List<BusinessClinicAppointment>? items,
    String? status,
    bool clearStatus = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ClinicAppointmentsState(
      items: items ?? this.items,
      status: clearStatus ? null : (status ?? this.status),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ClinicAppointmentsController extends StateNotifier<ClinicAppointmentsState> {
  final BusinessClinicApi _api;
  int _page = 1;

  ClinicAppointmentsController(this._api) : super(const ClinicAppointmentsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.appointments(status: state.status, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.appointments(status: state.status, page: _page + 1);
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

  Future<void> filterByStatus(String? status) async {
    state = status == null ? state.copyWith(clearStatus: true) : state.copyWith(status: status);
    await load();
  }

  void _replace(BusinessClinicAppointment updated) {
    state = state.copyWith(items: [for (final a in state.items) a.id == updated.id ? updated : a]);
  }

  Future<void> confirm(int id) async => _replace(await _api.confirm(id));
  Future<void> reject(int id) async => _replace(await _api.reject(id));
  Future<void> complete(int id) async => _replace(await _api.complete(id));
  Future<void> noShow(int id) async => _replace(await _api.noShow(id));

  Future<void> reschedule(int id, DateTime at, {int? durationMinutes}) async =>
      _replace(await _api.reschedule(id, at, durationMinutes: durationMinutes));
}

final clinicAppointmentsControllerProvider =
    StateNotifierProvider<ClinicAppointmentsController, ClinicAppointmentsState>((ref) {
      return ClinicAppointmentsController(ref.watch(businessClinicApiProvider));
    });

// ─────────────────────────── Slots ───────────────────────────

class ClinicSlotsState {
  final List<BusinessClinicSlot> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ClinicSlotsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  ClinicSlotsState copyWith({
    List<BusinessClinicSlot>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ClinicSlotsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ClinicSlotsController extends StateNotifier<ClinicSlotsState> {
  final BusinessClinicApi _api;
  int _page = 1;

  ClinicSlotsController(this._api) : super(const ClinicSlotsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.slots(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.slots(page: _page + 1);
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

  Future<({int created, int skipped})> publishSlots({DateTime? startsAt, List<DateTime>? slots}) async {
    final result = await _api.publishSlots(startsAt: startsAt, slots: slots);
    await load();
    return result;
  }

  Future<Map<String, dynamic>> generateSlots({
    required List<int> weekdays,
    required String startTime,
    required String endTime,
    int? intervalMinutes,
    int weeks = 4,
  }) async {
    final result = await _api.generateSlots(
      weekdays: weekdays,
      startTime: startTime,
      endTime: endTime,
      intervalMinutes: intervalMinutes,
      weeks: weeks,
    );
    await load();
    return result;
  }

  Future<void> deleteSlot(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((s) => s.id != id).toList());
    try {
      await _api.deleteSlot(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    }
  }
}

final clinicSlotsControllerProvider = StateNotifierProvider<ClinicSlotsController, ClinicSlotsState>((ref) {
  return ClinicSlotsController(ref.watch(businessClinicApiProvider));
});
