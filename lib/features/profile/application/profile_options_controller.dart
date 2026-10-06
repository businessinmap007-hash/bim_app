import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/profile_options.dart';
import '../data/profile_api.dart';
import 'profile_controller.dart';

class ProfileOptionsState {
  /// True once the catalog has really been read: a screen that failed to load must never save an empty set over the server's.
  final bool loaded;
  final List<ProfileOptionGroup> terms;
  final List<ProfileOptionGroup> groups;
  final Set<int> selectedIds;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const ProfileOptionsState({
    this.loaded = false,
    this.terms = const [],
    this.groups = const [],
    this.selectedIds = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  ProfileOptionsState copyWith({
    bool? loaded,
    List<ProfileOptionGroup>? terms,
    List<ProfileOptionGroup>? groups,
    Set<int>? selectedIds,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ProfileOptionsState(
      loaded: loaded ?? this.loaded,
      terms: terms ?? this.terms,
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
        loaded: true,
        terms: payload.terms,
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

  /// Saves the whole set (the server replaces it). Returns false when it did not go through — and never runs
  /// before the catalog was read, so a screen that failed to load cannot wipe what the store already ticked.
  Future<bool> save() async {
    if (!state.loaded) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final payload = await _api.updateOptions(state.selectedIds.toList());
      state = state.copyWith(
        terms: payload.terms,
        groups: payload.groups,
        selectedIds: payload.selectedIds.toSet(),
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final profileOptionsControllerProvider =
    StateNotifierProvider<ProfileOptionsController, ProfileOptionsState>((ref) {
      return ProfileOptionsController(ref.watch(profileApiProvider));
    });
