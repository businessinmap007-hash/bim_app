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
