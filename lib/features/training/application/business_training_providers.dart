import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/body_report.dart';
import '../data/models/training_plan.dart';
import '../data/training_api.dart';
import 'training_providers.dart';

class MyTrainingClientsState {
  final List<TrainingPlan> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyTrainingClientsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyTrainingClientsState copyWith({
    List<TrainingPlan>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyTrainingClientsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyTrainingClientsController extends StateNotifier<MyTrainingClientsState> {
  final TrainingApi _api;
  int _page = 1;

  MyTrainingClientsController(this._api) : super(const MyTrainingClientsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.myClientPlans(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.myClientPlans(page: _page + 1);
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
}

final myTrainingClientsControllerProvider =
    StateNotifierProvider<MyTrainingClientsController, MyTrainingClientsState>((ref) {
      return MyTrainingClientsController(ref.watch(trainingApiProvider));
    });

class TrainingPlanManageState {
  final TrainingPlan? plan;
  final List<BodyReport> bodyReports;
  final bool isLoading;
  final bool isLoadingReports;
  final String? error;

  const TrainingPlanManageState({
    this.plan,
    this.bodyReports = const [],
    this.isLoading = false,
    this.isLoadingReports = false,
    this.error,
  });

  TrainingPlanManageState copyWith({
    TrainingPlan? plan,
    List<BodyReport>? bodyReports,
    bool? isLoading,
    bool? isLoadingReports,
    String? error,
    bool clearError = false,
  }) {
    return TrainingPlanManageState(
      plan: plan ?? this.plan,
      bodyReports: bodyReports ?? this.bodyReports,
      isLoading: isLoading ?? this.isLoading,
      isLoadingReports: isLoadingReports ?? this.isLoadingReports,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TrainingPlanManageController extends StateNotifier<TrainingPlanManageState> {
  final TrainingApi _api;
  final int planId;

  TrainingPlanManageController(this._api, this.planId) : super(const TrainingPlanManageState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final plan = await _api.businessPlan(planId);
      state = state.copyWith(plan: plan, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadBodyReports() async {
    state = state.copyWith(isLoadingReports: true);
    try {
      final reports = await _api.businessBodyReports(planId);
      state = state.copyWith(bodyReports: reports, isLoadingReports: false);
    } catch (_) {
      state = state.copyWith(isLoadingReports: false);
    }
  }

  Future<void> setStatus(String status) async {
    final plan = await _api.setPlanStatus(planId, status);
    state = state.copyWith(plan: plan);
  }

  Future<void> addExercise({
    required String name,
    int? dayOfWeek,
    int? sets,
    String? reps,
    int? restSeconds,
    String? notes,
  }) async {
    await _api.addExercise(
      planId,
      name: name,
      dayOfWeek: dayOfWeek,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      notes: notes,
    );
    await load();
  }

  Future<void> removeExercise(int exerciseId) async {
    await _api.removeExercise(planId, exerciseId);
    await load();
  }

  Future<void> addMeal({required String mealType, required String name, int? calories, String? notes}) async {
    await _api.addMeal(planId, mealType: mealType, name: name, calories: calories, notes: notes);
    await load();
  }

  Future<void> removeMeal(int mealId) async {
    await _api.removeMeal(planId, mealId);
    await load();
  }

  Future<void> addBodyReport({
    DateTime? forMonth,
    double? weightKg,
    double? muscleMassKg,
    double? fatPercent,
    double? waterPercent,
    String? notes,
  }) async {
    await _api.addBodyReport(
      planId,
      forMonth: forMonth,
      weightKg: weightKg,
      muscleMassKg: muscleMassKg,
      fatPercent: fatPercent,
      waterPercent: waterPercent,
      notes: notes,
    );
    await loadBodyReports();
  }

  Future<void> deleteBodyReport(int reportId) async {
    await _api.deleteBodyReport(planId, reportId);
    await loadBodyReports();
  }
}

final trainingPlanManageControllerProvider =
    StateNotifierProvider.family<TrainingPlanManageController, TrainingPlanManageState, int>((ref, planId) {
      return TrainingPlanManageController(ref.watch(trainingApiProvider), planId);
    });
