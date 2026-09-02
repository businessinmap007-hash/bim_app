/// Mirrors `BusinessProjectController::serialize()` — a business's own
/// project (manufacturing/construction-style timeline). `progress` is the
/// aggregate rolled up from its tasks, computed server-side.
class Project {
  final int id;
  final String title;
  final String? description;
  final String? reference;
  final String status;
  final String visibility;
  final int progress;
  final DateTime? startsOn;
  final DateTime? dueOn;
  final bool isOverdue;
  final int? tasksCount;
  final DateTime? createdAt;

  const Project({
    required this.id,
    required this.title,
    this.description,
    this.reference,
    required this.status,
    required this.visibility,
    required this.progress,
    this.startsOn,
    this.dueOn,
    required this.isOverdue,
    this.tasksCount,
    this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    reference: json['reference'] as String?,
    status: json['status'] as String? ?? 'planning',
    visibility: json['visibility'] as String? ?? 'private',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    startsOn: json['starts_on'] != null ? DateTime.tryParse(json['starts_on'] as String) : null,
    dueOn: json['due_on'] != null ? DateTime.tryParse(json['due_on'] as String) : null,
    isOverdue: json['is_overdue'] as bool? ?? false,
    tasksCount: json['tasks_count'] as int?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
