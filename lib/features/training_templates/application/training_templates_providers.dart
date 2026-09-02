import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/training_template.dart';
import '../data/training_templates_api.dart';

final trainingTemplatesApiProvider = Provider<TrainingTemplatesApi>((ref) {
  return TrainingTemplatesApi(ref.watch(apiClientProvider));
});

class TrainingTemplatesState {
  final List<TrainingTemplate> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const TrainingTemplatesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  TrainingTemplatesState copyWith({
    List<TrainingTemplate>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return TrainingTemplatesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TrainingTemplatesController extends StateNotifier<TrainingTemplatesState> {
  final TrainingTemplatesApi _api;
  int _page = 1;

  TrainingTemplatesController(this._api) : super(const TrainingTemplatesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(page: _page + 1);
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

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((t) => t.id != id).toList());
    try {
      await _api.delete(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    }
  }
}

final trainingTemplatesControllerProvider =
    StateNotifierProvider<TrainingTemplatesController, TrainingTemplatesState>((ref) {
      return TrainingTemplatesController(ref.watch(trainingTemplatesApiProvider));
    });

/// One template's full detail (with exercises/meals) plus every sub-resource
/// mutation — each reloads the whole template afterward, mirroring
/// MenuItemEditController's shape.
class TrainingTemplateEditController extends StateNotifier<AsyncValue<TrainingTemplate>> {
  final TrainingTemplatesApi _api;
  final int templateId;

  TrainingTemplateEditController(this._api, this.templateId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.show(templateId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBase({required String title, String? goal, String? notes}) async {
    await _api.update(templateId, title: title, goal: goal, notes: notes);
    await load();
  }

  Future<void> addExercise({
    int? dayOfWeek,
    required String name,
    int? sets,
    String? reps,
    int? restSeconds,
    String? notes,
  }) async {
    await _api.addExercise(
      templateId,
      dayOfWeek: dayOfWeek,
      name: name,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      notes: notes,
    );
    await load();
  }

  Future<void> removeExercise(int exerciseId) async {
    await _api.removeExercise(templateId, exerciseId);
    await load();
  }

  Future<void> addMeal({required String mealType, required String name, int? calories, String? notes}) async {
    await _api.addMeal(templateId, mealType: mealType, name: name, calories: calories, notes: notes);
    await load();
  }

  Future<void> removeMeal(int mealId) async {
    await _api.removeMeal(templateId, mealId);
    await load();
  }
}

final trainingTemplateEditControllerProvider =
    StateNotifierProvider.family<TrainingTemplateEditController, AsyncValue<TrainingTemplate>, int>((ref, id) {
      return TrainingTemplateEditController(ref.watch(trainingTemplatesApiProvider), id);
    });
