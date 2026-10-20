import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/project.dart';
import 'models/project_template.dart';
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

  Future<Paginated<Project>> list({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final data =
        await _client.get(
              '/business/projects',
              query: {'status': ?status, 'page': page, 'per_page': perPage},
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, Project.fromJson);
  }

  Future<Project> create({
    required String title,
    String? description,
    String? reference,
    DateTime? startsOn,
    DateTime? dueOn,
    int? templateId,
    String? operationType,
    int? operationId,
  }) async {
    final data =
        await _client.post(
              '/business/projects',
              data: {
                'template_id': ?templateId,
                if (operationType != null && operationId != null) ...{'operation_type': operationType, 'operation_id': operationId},
                'title': title,
                if (description != null && description.isNotEmpty)
                  'description': description,
                if (reference != null && reference.isNotEmpty)
                  'reference': reference,
                if (startsOn != null) 'starts_on': _dateOnly(startsOn),
                if (dueOn != null) 'due_on': _dateOnly(dueOn),
              },
            )
            as Map<String, dynamic>;
    return Project.fromJson(data['project'] as Map<String, dynamic>);
  }

  /// The ready stage plans offered to my trade (and the general ones).
  Future<List<ProjectTemplate>> templates() async {
    final data = await _client.get('/business/projects/templates') as Map<String, dynamic>;
    return [
      for (final t in (data['templates'] as List<dynamic>? ?? const [])) ProjectTemplate.fromJson(t as Map<String, dynamic>),
    ];
  }

  /// The stages assigned to me that still need work ([businessId] when I work for one of several).
  Future<List<MyStage>> myStages({int? businessId}) async {
    final data = await _client.get('/business/projects/my-stages', query: {'business_id': ?businessId}) as Map<String, dynamic>;
    return [
      for (final s in (data['stages'] as List<dynamic>? ?? const [])) MyStage.fromJson(s as Map<String, dynamic>),
    ];
  }

  /// Hand a stage to one of my providers (null = release); returns nothing — the caller reloads.
  Future<void> assignTask(int projectId, int taskId, int? assigneeId, {int? businessId}) => _client.put(
    '/business/projects/$projectId/tasks/$taskId/assignee',
    data: {'assignee_id': assigneeId, 'business_id': ?businessId},
  );

  /// A live camera photo of a stage — the server refuses anything not declared as taken by the camera.
  Future<void> uploadPhoto(int projectId, int taskId, Uint8List bytes, {int? businessId}) => _client.post(
    '/business/projects/$projectId/tasks/$taskId/photo',
    data: FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: 'stage.jpg'),
      'source': 'camera',
      'business_id': ?businessId,
    }),
  );

  Future<ProjectDetail> show(int id) async {
    final data =
        await _client.get('/business/projects/$id') as Map<String, dynamic>;
    return (
      project: Project.fromJson(data['project'] as Map<String, dynamic>),
      timeline: ProjectTimeline.fromJson(
        data['timeline'] as Map<String, dynamic>,
      ),
    );
  }

  Future<Project> updateStatus(int id, String status) async {
    final data =
        await _client.patch('/business/projects/$id', data: {'status': status})
            as Map<String, dynamic>;
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
    bool requiresApproval = false,
  }) {
    return _client.post(
      '/business/projects/$projectId/tasks',
      data: {
        'requires_approval': requiresApproval,
        'title': title,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (startsOn != null) 'starts_on': _dateOnly(startsOn),
        if (endsOn != null) 'ends_on': _dateOnly(endsOn),
        'requires_photo': requiresPhoto,
      },
    );
  }

  Future<void> updateTaskProgress(
    int projectId,
    int taskId, {
    int? progress,
    String? status,
    int? businessId,
  }) {
    return _client.patch(
      '/business/projects/$projectId/tasks/$taskId/progress',
      data: {'progress': ?progress, 'status': ?status, 'business_id': ?businessId},
    );
  }

  Future<void> deleteTask(int projectId, int taskId) =>
      _client.delete('/business/projects/$projectId/tasks/$taskId');

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
