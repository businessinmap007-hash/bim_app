import '../../../../core/env/env.dart';
import 'project.dart';

/// One task as the customer following an operation sees it — mirrors
/// `ProjectService::customerView()`'s `tasks[]`: no critical-path math (that's
/// for the business planning it), just status/progress/dates and the
/// camera-evidence photos for that stage.
class CustomerProjectTask {
  final int id;
  final String title;
  final String status;
  final int progress;
  final String? startsOn;
  final String? endsOn;
  final List<String> photoUrls;

  const CustomerProjectTask({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    this.startsOn,
    this.endsOn,
    required this.photoUrls,
  });

  factory CustomerProjectTask.fromJson(Map<String, dynamic> json) => CustomerProjectTask(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    startsOn: json['starts_on'] as String?,
    endsOn: json['ends_on'] as String?,
    photoUrls: (json['photos'] as List<dynamic>? ?? [])
        .map((e) => Env.assetUrl((e as Map<String, dynamic>)['url'] as String?))
        .whereType<String>()
        .toList(),
  );
}

/// Mirrors `ProjectService::customerView()` — the read-only progress view a
/// customer gets for the project the business linked to their order/booking.
class CustomerProjectView {
  final Project project;
  final List<CustomerProjectTask> tasks;

  const CustomerProjectView({required this.project, required this.tasks});

  factory CustomerProjectView.fromJson(Map<String, dynamic> json) => CustomerProjectView(
    project: Project.fromJson(json['project'] as Map<String, dynamic>),
    tasks: (json['tasks'] as List<dynamic>? ?? [])
        .map((e) => CustomerProjectTask.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
