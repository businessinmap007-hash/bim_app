import '../../../../core/assignment/assignee.dart';
import 'project_agreement.dart';

/// One task's computed schedule row — mirrors `ProjectService::timeline()`'s
/// per-task output (the critical-path/Gantt math already done server-side;
/// this app just displays it as a sorted list rather than drawing bars).
class ProjectTaskRow {
  final int id;
  final String title;
  final String status;
  final int progress;
  final int durationDays;
  final int earliestStartOffset;
  final bool isCritical;
  final String? plannedStart;
  final String? plannedEnd;
  final bool isOverdue;

  /// «يطلب اعتماد العميل»: and where that stands (null | pending | approved | rejected).
  final bool requiresApproval;
  final String? approvalStatus;
  final String? approvalNote;

  /// Who is responsible for this stage.
  final Assignee? assignee;

  /// A work inside a main stage: the main stage, its place («الدور الثالث / شقة 2»), weight, free details, whether the customer
  /// approved its main stage's start, and its quantities.
  final int? parentId;
  final String? zone;
  final int weight;
  final String? details;
  final String? startStatus;
  final String? startNote;
  final List<QuantityItem> items;

  const ProjectTaskRow({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.durationDays,
    required this.earliestStartOffset,
    required this.isCritical,
    this.plannedStart,
    this.plannedEnd,
    required this.isOverdue,
    this.requiresApproval = false,
    this.approvalStatus,
    this.approvalNote,
    this.assignee,
    this.parentId,
    this.zone,
    this.weight = 0,
    this.details,
    this.startStatus,
    this.startNote,
    this.items = const [],
  });

  bool get isDone => status == 'done';

  factory ProjectTaskRow.fromJson(Map<String, dynamic> json) => ProjectTaskRow(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
    earliestStartOffset: (json['earliest_start_offset'] as num?)?.toInt() ?? 0,
    isCritical: json['is_critical'] as bool? ?? false,
    plannedStart: json['planned_start'] as String?,
    plannedEnd: json['planned_end'] as String?,
    isOverdue: json['is_overdue'] as bool? ?? false,
    requiresApproval: json['requires_approval'] as bool? ?? false,
    approvalStatus: json['approval_status'] as String?,
    approvalNote: json['approval_note'] as String?,
    assignee: json['assignee'] is Map<String, dynamic> ? Assignee.fromJson(json['assignee'] as Map<String, dynamic>) : null,
    parentId: (json['parent_id'] as num?)?.toInt(),
    zone: json['zone'] as String?,
    weight: (json['weight'] as num?)?.toInt() ?? 0,
    details: json['details'] as String?,
    startStatus: json['start_status'] as String?,
    startNote: json['start_note'] as String?,
    items: [for (final i in (json['items'] as List<dynamic>? ?? const [])) QuantityItem.fromJson(i as Map<String, dynamic>)],
  );
}

/// Mirrors `ProjectService::timeline()` — `tasks` comes back as a JSON
/// object keyed by task id (a PHP associative array with non-sequential
/// keys), not an array, so this reads its *values*.
class ProjectTimeline {
  final int projectDurationDays;
  final bool hasCycle;
  final List<ProjectTaskRow> tasks;

  const ProjectTimeline({
    required this.projectDurationDays,
    required this.hasCycle,
    required this.tasks,
  });

  factory ProjectTimeline.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'];
    final rows = rawTasks is Map<String, dynamic>
        ? rawTasks.values
        : (rawTasks as List<dynamic>? ?? const []);
    final tasks = rows.map((e) => ProjectTaskRow.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.earliestStartOffset.compareTo(b.earliestStartOffset));
    return ProjectTimeline(
      projectDurationDays: (json['project_duration_days'] as num?)?.toInt() ?? 0,
      hasCycle: json['has_cycle'] as bool? ?? false,
      tasks: tasks,
    );
  }
}
