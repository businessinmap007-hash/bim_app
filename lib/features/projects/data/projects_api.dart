import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/project.dart';
import 'models/project_timeline.dart';

typedef ProjectDetail = ({Project project, ProjectTimeline timeline});

/// /business/projects — see Api\V2\BusinessProjectController +
/// BusinessProjectTaskController. Camera-evidence photos, task dependencies
/// and follower management aren't wired up here — task creation defaults
/// `requires_photo` to false so completing a task never needs one from this
/// app; a task built elsewhere with photo evidence required still works,
/// it just can't be marked done from here without one (surfaces as a normal
/// validation error).
class ProjectsApi {
  final ApiClient _client;
  const ProjectsApi(this._client);

  Future<Paginated<Project>> list({String? status, int page = 1, int perPage = 20}) async {
    final data = await _client.get(
      '/business/projects',
      query: {if (status != null) 'status': status, 'page': page, 'per_page': perPage},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, Project.fromJson);
  }

  Future<Project> create({
    required String title,
    String? description,
    String? reference,
    DateTime? startsOn,
    DateTime? dueOn,
  }) async {
    final data = await _client.post(
      '/business/projects',
      data: {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        if (reference != null && reference.isNotEmpty) 'reference': reference,
        if (startsOn != null) 'starts_on': _dateOnly(startsOn),
        if (dueOn != null) 'due_on': _dateOnly(dueOn),
      },
    ) as Map<String, dynamic>;
    return Project.fromJson(data['project'] as Map<String, dynamic>);
  }

  Future<ProjectDetail> show(int id) async {
    final data = await _client.get('/business/projects/$id') as Map<String, dynamic>;
    return (
      project: Project.fromJson(data['project'] as Map<String, dynamic>),
      timeline: ProjectTimeline.fromJson(data['timeline'] as Map<String, dynamic>),
    );
  }

  Future<Project> updateStatus(int id, String status) async {
    final data = await _client.patch(
      '/business/projects/$id',
      data: {'status': status},
    ) as Map<String, dynamic>;
    return Project.fromJson(data['project'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/business/projects/$id');

  Future<void> createTask({
    required int projectId,
    required String title,
    String? notes,
    DateTime? startsOn,
    DateTime? endsOn,
    bool requiresPhoto = false,
  }) {
    return _client.post(
      '/business/projects/$projectId/tasks',
      data: {
        'title': title,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (startsOn != null) 'starts_on': _dateOnly(startsOn),
        if (endsOn != null) 'ends_on': _dateOnly(endsOn),
        'requires_photo': requiresPhoto,
      },
    );
  }

  Future<void> updateTaskProgress(int projectId, int taskId, {int? progress, String? status}) {
    return _client.patch(
      '/business/projects/$projectId/tasks/$taskId/progress',
      data: {
        if (progress != null) 'progress': progress,
        if (status != null) 'status': status,
      },
    );
  }

  Future<void> deleteTask(int projectId, int taskId) =>
      _client.delete('/business/projects/$projectId/tasks/$taskId');

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
