import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/staff_membership.dart';
import '../data/staff_api.dart';
import '../data/staff_attendance_api.dart';
import 'staff_providers.dart';

final staffAttendanceApiProvider = Provider<StaffAttendanceApi>((ref) {
  return StaffAttendanceApi(ref.watch(apiClientProvider));
});

class MyWorkState {
  final List<StaffMembership> memberships;
  final Map<int, AttendanceStatus> attendanceByBusiness;
  final bool isLoading;
  final Set<int> busyBusinessIds;
  final String? error;

  const MyWorkState({
    this.memberships = const [],
    this.attendanceByBusiness = const {},
    this.isLoading = false,
    this.busyBusinessIds = const {},
    this.error,
  });

  MyWorkState copyWith({
    List<StaffMembership>? memberships,
    Map<int, AttendanceStatus>? attendanceByBusiness,
    bool? isLoading,
    Set<int>? busyBusinessIds,
    String? error,
    bool clearError = false,
  }) {
    return MyWorkState(
      memberships: memberships ?? this.memberships,
      attendanceByBusiness: attendanceByBusiness ?? this.attendanceByBusiness,
      isLoading: isLoading ?? this.isLoading,
      busyBusinessIds: busyBusinessIds ?? this.busyBusinessIds,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// The businesses I work for as staff, each with today's attendance —
/// loaded together since the whole point of this screen is "did I check in
/// everywhere I'm supposed to work today".
class MyWorkController extends StateNotifier<MyWorkState> {
  final StaffApi _staffApi;
  final StaffAttendanceApi _attendanceApi;

  MyWorkController(this._staffApi, this._attendanceApi) : super(const MyWorkState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final memberships = await _staffApi.memberships();
      final statuses = await Future.wait(memberships.map((m) => _attendanceApi.today(m.businessId)));
      final byBusiness = <int, AttendanceStatus>{
        for (var i = 0; i < memberships.length; i++) memberships[i].businessId: statuses[i],
      };
      state = state.copyWith(memberships: memberships, attendanceByBusiness: byBusiness, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkIn(int businessId, {String? qrToken, double? lat, double? lng}) async {
    state = state.copyWith(busyBusinessIds: {...state.busyBusinessIds, businessId});
    try {
      final status = await _attendanceApi.checkIn(businessId, qrToken: qrToken, lat: lat, lng: lng);
      state = state.copyWith(attendanceByBusiness: {...state.attendanceByBusiness, businessId: status});
    } finally {
      if (mounted) {
        state = state.copyWith(busyBusinessIds: {...state.busyBusinessIds}..remove(businessId));
      }
    }
  }

  Future<void> checkOut(int businessId, {String? qrToken, double? lat, double? lng}) async {
    state = state.copyWith(busyBusinessIds: {...state.busyBusinessIds, businessId});
    try {
      final status = await _attendanceApi.checkOut(businessId, qrToken: qrToken, lat: lat, lng: lng);
      state = state.copyWith(attendanceByBusiness: {...state.attendanceByBusiness, businessId: status});
    } finally {
      if (mounted) {
        state = state.copyWith(busyBusinessIds: {...state.busyBusinessIds}..remove(businessId));
      }
    }
  }
}

final myWorkControllerProvider = StateNotifierProvider.autoDispose<MyWorkController, MyWorkState>((ref) {
  return MyWorkController(ref.watch(staffApiProvider), ref.watch(staffAttendanceApiProvider));
});
