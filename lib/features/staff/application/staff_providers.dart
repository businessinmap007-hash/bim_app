import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/staff_member.dart';
import '../data/staff_api.dart';

final staffApiProvider = Provider<StaffApi>((ref) {
  return StaffApi(ref.watch(apiClientProvider));
});

/// The keys of the platform services this business's own category actually
/// offers (BusinessCapability::forBusiness on the backend) — reused from the
/// staff-delegation picker to gate which tiles Service Settings shows, so a
/// hotel stops seeing "Training & Nutrition Plans" just because the field
/// existed for everyone. `ORDERS`/`OFFERS`/`PRICES`/`WORKING_HOURS` (account
/// management, not a sellable service) always come back regardless of
/// category — see the backend's own doc comment on BusinessCapability.
final myServiceKeysProvider = FutureProvider<Set<String>>((ref) async {
  final options = await ref.watch(staffApiProvider).capabilities();
  return options.map((o) => o.key).toSet();
});

class StaffState {
  final List<CapabilityOption> capabilities;
  final List<StaffMember> staff;
  final bool isLoading;
  final String? error;

  const StaffState({
    this.capabilities = const [],
    this.staff = const [],
    this.isLoading = false,
    this.error,
  });

  StaffState copyWith({
    List<CapabilityOption>? capabilities,
    List<StaffMember>? staff,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StaffState(
      capabilities: capabilities ?? this.capabilities,
      staff: staff ?? this.staff,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// A business's delegated staff roster + the capability catalog it can
/// grant from — loaded together so the add/edit sheet never waits on the
/// catalog separately.
class StaffController extends StateNotifier<StaffState> {
  final StaffApi _api;

  StaffController(this._api) : super(const StaffState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([_api.capabilities(), _api.list()]);
      state = state.copyWith(
        capabilities: results[0] as List<CapabilityOption>,
        staff: results[1] as List<StaffMember>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> add({
    required String phone,
    String? title,
    required List<String> capabilities,
    bool isActive = true,
  }) async {
    final member = await _api.add(phone: phone, title: title, capabilities: capabilities, isActive: isActive);
    final without = state.staff.where((s) => s.userId != member.userId).toList();
    state = state.copyWith(staff: [member, ...without]);
  }

  Future<void> update(
    int userId, {
    String? title,
    List<String>? capabilities,
    bool? isActive,
  }) async {
    final updated = await _api.update(userId, title: title, capabilities: capabilities, isActive: isActive);
    state = state.copyWith(
      staff: [for (final s in state.staff) s.userId == userId ? updated : s],
    );
  }

  Future<void> remove(int userId) async {
    await _api.remove(userId);
    state = state.copyWith(staff: state.staff.where((s) => s.userId != userId).toList());
  }
}

final staffControllerProvider = StateNotifierProvider<StaffController, StaffState>((ref) {
  return StaffController(ref.watch(staffApiProvider));
});
