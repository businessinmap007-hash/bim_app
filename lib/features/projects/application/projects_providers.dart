import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/project.dart';
import '../data/models/project_timeline.dart';
import '../data/projects_api.dart';

final projectsApiProvider = Provider<ProjectsApi>((ref) {
  return ProjectsApi(ref.watch(apiClientProvider));
});

class ProjectsState {
  final List<Project> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ProjectsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  ProjectsState copyWith({
    List<Project>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ProjectsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProjectsController extends StateNotifier<ProjectsState> {
  final ProjectsApi _api;
  int _page = 1;

  ProjectsController(this._api) : super(const ProjectsState()) {
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

  Future<void> create({
    required String title,
    String? description,
    String? reference,
    DateTime? startsOn,
    DateTime? dueOn,
  }) async {
    final project = await _api.create(
      title: title,
      description: description,
      reference: reference,
      startsOn: startsOn,
      dueOn: dueOn,
    );
    state = state.copyWith(items: [project, ...state.items]);
  }

  Future<void> delete(int id) async {
    await _api.delete(id);
    state = state.copyWith(items: state.items.where((p) => p.id != id).toList());
  }
}

final projectsControllerProvider = StateNotifierProvider<ProjectsController, ProjectsState>((ref) {
  return ProjectsController(ref.watch(projectsApiProvider));
});

class ProjectDetailState {
  final Project? project;
  final ProjectTimeline? timeline;
  final bool isLoading;
  final String? error;

  const ProjectDetailState({this.project, this.timeline, this.isLoading = false, this.error});

  ProjectDetailState copyWith({
    Project? project,
    ProjectTimeline? timeline,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProjectDetailState(
      project: project ?? this.project,
      timeline: timeline ?? this.timeline,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// One project's own detail + task timeline. Every task mutation just
/// reloads the whole thing — the server recomputes the critical path and
/// the project's rolled-up progress on every change, so there is nothing
/// worth patching locally.
class ProjectDetailController extends StateNotifier<ProjectDetailState> {
  final ProjectsApi _api;
  final int projectId;

  ProjectDetailController(this._api, this.projectId) : super(const ProjectDetailState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _api.show(projectId);
      state = state.copyWith(project: detail.project, timeline: detail.timeline, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTask({
    required String title,
    String? notes,
    DateTime? startsOn,
    DateTime? endsOn,
    bool requiresPhoto = false,
  }) async {
    await _api.createTask(
      projectId: projectId,
      title: title,
      notes: notes,
      startsOn: startsOn,
      endsOn: endsOn,
      requiresPhoto: requiresPhoto,
    );
    await load();
  }

  Future<void> updateTaskProgress(int taskId, {int? progress, String? status}) async {
    await _api.updateTaskProgress(projectId, taskId, progress: progress, status: status);
    await load();
  }

  Future<void> deleteTask(int taskId) async {
    await _api.deleteTask(projectId, taskId);
    await load();
  }

  Future<void> updateStatus(String status) async {
    final project = await _api.updateStatus(projectId, status);
    state = state.copyWith(project: project);
  }
}

final projectDetailControllerProvider =
    StateNotifierProvider.family<ProjectDetailController, ProjectDetailState, int>((ref, projectId) {
      return ProjectDetailController(ref.watch(projectsApiProvider), projectId);
    });
