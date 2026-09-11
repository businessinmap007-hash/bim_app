import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/business_groups_api.dart';
import '../data/models/business_group.dart';

final businessGroupsApiProvider = Provider<BusinessGroupsApi>((ref) {
  return BusinessGroupsApi(ref.watch(apiClientProvider));
});

class BusinessGroupsState {
  final List<BusinessGroup> groups;
  final bool isLoading;
  final String? error;

  const BusinessGroupsState({this.groups = const [], this.isLoading = false, this.error});

  BusinessGroupsState copyWith({List<BusinessGroup>? groups, bool? isLoading, String? error, bool clearError = false}) {
    return BusinessGroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BusinessGroupsController extends StateNotifier<BusinessGroupsState> {
  final BusinessGroupsApi _api;

  BusinessGroupsController(this._api) : super(const BusinessGroupsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final groups = await _api.list();
      state = state.copyWith(groups: groups, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create(String name) async {
    final group = await _api.create(name);
    state = state.copyWith(groups: [group, ...state.groups]);
  }

  Future<void> rename(int groupId, String name) async {
    final updated = await _api.rename(groupId, name);
    state = state.copyWith(groups: [for (final g in state.groups) g.id == groupId ? updated : g]);
  }

  Future<void> delete(int groupId) async {
    await _api.delete(groupId);
    state = state.copyWith(groups: state.groups.where((g) => g.id != groupId).toList());
  }

  Future<void> addMember(int groupId, int businessId) async {
    final updated = await _api.addMember(groupId, businessId);
    state = state.copyWith(groups: [for (final g in state.groups) g.id == groupId ? updated : g]);
  }

  Future<void> removeMember(int groupId, int memberId) async {
    final updated = await _api.removeMember(groupId, memberId);
    state = state.copyWith(groups: [for (final g in state.groups) g.id == groupId ? updated : g]);
  }
}

final businessGroupsControllerProvider = StateNotifierProvider<BusinessGroupsController, BusinessGroupsState>((ref) {
  return BusinessGroupsController(ref.watch(businessGroupsApiProvider));
});
