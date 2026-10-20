/// One stage of a ready plan — mirrors `GET /business/projects/templates`.
class TemplateStage {
  final String title;
  final int durationDays;
  final bool requiresApproval;

  const TemplateStage({required this.title, required this.durationDays, required this.requiresApproval});

  factory TemplateStage.fromJson(Map<String, dynamic> json) => TemplateStage(
    title: json['title'] as String? ?? '',
    durationDays: (json['duration_days'] as num?)?.toInt() ?? 1,
    requiresApproval: json['requires_approval'] as bool? ?? false,
  );
}

/// A ready stage plan for a trade («تشطيب شقة», «صيانة سيارة»…). The business picks one when it starts a project and edits
/// the copy it gets.
class ProjectTemplate {
  final int id;
  final String code;
  final String title;
  final List<TemplateStage> stages;

  const ProjectTemplate({required this.id, required this.code, required this.title, required this.stages});

  factory ProjectTemplate.fromJson(Map<String, dynamic> json) => ProjectTemplate(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String? ?? '',
    title: json['title'] as String? ?? '',
    stages: [
      for (final s in (json['stages'] as List<dynamic>? ?? const [])) TemplateStage.fromJson(s as Map<String, dynamic>),
    ],
  );

  int get totalDays => stages.fold(0, (sum, s) => sum + s.durationDays);
}

/// A stage assigned to me that still needs work — mirrors `GET /business/projects/my-stages`.
class MyStage {
  final int id;
  final int projectId;
  final String projectTitle;
  final String title;
  final String status;
  final int progress;
  final String? startsOn;
  final String? endsOn;
  final bool requiresPhoto;
  final String? approvalStatus;
  final String? approvalNote;

  const MyStage({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.title,
    required this.status,
    required this.progress,
    this.startsOn,
    this.endsOn,
    required this.requiresPhoto,
    this.approvalStatus,
    this.approvalNote,
  });

  bool get sentBack => approvalStatus == 'rejected';

  factory MyStage.fromJson(Map<String, dynamic> json) => MyStage(
    id: (json['id'] as num).toInt(),
    projectId: (json['project_id'] as num).toInt(),
    projectTitle: json['project_title'] as String? ?? '',
    title: json['title'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    startsOn: json['starts_on'] as String?,
    endsOn: json['ends_on'] as String?,
    requiresPhoto: json['requires_photo'] as bool? ?? false,
    approvalStatus: json['approval_status'] as String?,
    approvalNote: json['approval_note'] as String?,
  );
}
