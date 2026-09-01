import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/profile_options.dart';
import '../data/profile_api.dart';
import 'profile_controller.dart';

class ProfileOptionsState {
  final List<ProfileOptionGroup> groups;
  final Set<int> selectedIds;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const ProfileOptionsState({
    this.groups = const [],
    this.selectedIds = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  ProfileOptionsState copyWith({
    List<ProfileOptionGroup>? groups,
    Set<int>? selectedIds,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ProfileOptionsState(
      groups: groups ?? this.groups,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// A business's own attribute picks («تقسيط», «توصيل مجاني», ...) — loads the
/// full catalog for its specialty once, tracks the checked set locally as
/// the owner ticks/unticks boxes, and saves the whole set in one PATCH
/// (the backend replaces, it doesn't diff).
class ProfileOptionsController extends StateNotifier<ProfileOptionsState> {
  final ProfileApi _api;

  ProfileOptionsController(this._api) : super(const ProfileOptionsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payload = await _api.showOptions();
      state = state.copyWith(
        groups: payload.groups,
        selectedIds: payload.selectedIds.toSet(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggle(int optionId, bool value) {
    final updated = Set<int>.from(state.selectedIds);
    if (value) {
      updated.add(optionId);
    } else {
      updated.remove(optionId);
    }
    state = state.copyWith(selectedIds: updated);
  }

  Future<void> save() async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final payload = await _api.updateOptions(state.selectedIds.toList());
      state = state.copyWith(groups: payload.groups, selectedIds: payload.selectedIds.toSet(), isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final profileOptionsControllerProvider =
    StateNotifierProvider<ProfileOptionsController, ProfileOptionsState>((ref) {
      return ProfileOptionsController(ref.watch(profileApiProvider));
    });
