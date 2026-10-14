import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/clinic_api.dart';
import '../data/models/clinic_appointment.dart';
import '../data/models/clinic_slot.dart';

final clinicApiProvider = Provider<ClinicApi>((ref) {
  return ClinicApi(ref.watch(apiClientProvider));
});

/// One clinic's open slots — a plain FutureProvider (read-only; booking a
/// slot is a separate call, and the caller invalidates this to refresh the
/// list once one is taken).
final clinicSlotsBoardProvider = FutureProvider.family<ClinicSlotsResult, int>((ref, clinicId) {
  return ref.watch(clinicApiProvider).slotsWithDays(clinicId);
});

/// One physician's board at a hospital: his times and his strip of days.
final clinicPhysicianBoardProvider = FutureProvider.family<ClinicSlotsResult, ({int clinicId, int physicianId})>((ref, key) {
  return ref.watch(clinicApiProvider).slotsWithDays(key.clinicId, physicianId: key.physicianId);
});

/// The hospital's physicians a patient may choose between — empty for a clinic with none.
final clinicPhysiciansProvider = FutureProvider.family<List<ClinicPhysician>, int>((ref, clinicId) {
  return ref.watch(clinicApiProvider).physicians(clinicId);
});

final clinicSlotsProvider = FutureProvider.family<List<ClinicSlot>, int>((ref, clinicId) async {
  return (await ref.watch(clinicSlotsBoardProvider(clinicId).future)).slots;
});

/// Every visit kind a clinic prices (the radio list), with what the caller still owes it.
final clinicVisitKindsProvider = FutureProvider.autoDispose.family<VisitKindsResult, int>((ref, clinicId) {
  return ref.watch(clinicApiProvider).visitKinds(clinicId);
});

class MyClinicAppointmentsState {
  final List<ClinicAppointment> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyClinicAppointmentsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyClinicAppointmentsState copyWith({
    List<ClinicAppointment>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyClinicAppointmentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyClinicAppointmentsController extends StateNotifier<MyClinicAppointmentsState> {
  final ClinicApi _api;
  int _page = 1;

  MyClinicAppointmentsController(this._api) : super(const MyClinicAppointmentsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.myAppointments(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.myAppointments(page: _page + 1);
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

  void _withAccount(ClinicAppointment updated) {
    state = state.copyWith(
      items: [for (final a in state.items) a.id == updated.id ? a.copyWith(billing: updated.billing) : a],
    );
  }

  Future<void> confirmPayment(int id, int paymentId) async => _withAccount(await _api.confirmPayment(id, paymentId));

  Future<void> disputePayment(int id, int paymentId, {String? note}) async =>
      _withAccount(await _api.disputePayment(id, paymentId, note: note));

  Future<void> cancel(int id) async {
    final updated = await _api.cancel(id);
    state = state.copyWith(
      items: [for (final a in state.items) a.id == id ? a.copyWith(status: updated.status) : a],
    );
  }

  Future<void> reschedule(int id, DateTime scheduledAt) async {
    final updated = await _api.reschedule(id, scheduledAt);
    state = state.copyWith(
      items: [
        for (final a in state.items)
          a.id == id ? a.copyWith(status: updated.status, scheduledAt: updated.scheduledAt) : a,
      ],
    );
  }
}

final myClinicAppointmentsControllerProvider =
    StateNotifierProvider<MyClinicAppointmentsController, MyClinicAppointmentsState>((ref) {
      return MyClinicAppointmentsController(ref.watch(clinicApiProvider));
    });
