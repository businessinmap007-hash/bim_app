import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/staff_group.dart';
import '../data/staff_api.dart';
import 'staff_providers.dart';

class StaffGroupsState {
  final List<StaffGroup> groups;
  final bool isLoading;
  final String? error;

  const StaffGroupsState({this.groups = const [], this.isLoading = false, this.error});

  StaffGroupsState copyWith({List<StaffGroup>? groups, bool? isLoading, String? error, bool clearError = false}) {
    return StaffGroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StaffGroupsController extends StateNotifier<StaffGroupsState> {
  final StaffApi _api;

  StaffGroupsController(this._api) : super(const StaffGroupsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final groups = await _api.groups();
      state = state.copyWith(groups: groups, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final staffGroupsControllerProvider =
    StateNotifierProvider.autoDispose<StaffGroupsController, StaffGroupsState>((ref) {
      return StaffGroupsController(ref.watch(staffApiProvider));
    });
