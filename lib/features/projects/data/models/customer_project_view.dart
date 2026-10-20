import '../../../../core/assignment/assignee.dart';
import '../../../../core/env/env.dart';
import 'project.dart';
import 'project_agreement.dart';

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

  /// The customer's approval of this stage: it asks for it, and where that stands (null | pending | approved | rejected).
  final bool requiresApproval;
  final String? approvalStatus;
  final String? approvalNote;
  final Assignee? assignee;
  final int? parentId;
  final String? zone;
  final String? details;
  final String? startStatus;
  final String? startNote;
  final List<QuantityItem> items;

  const CustomerProjectTask({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    this.startsOn,
    this.endsOn,
    required this.photoUrls,
    this.requiresApproval = false,
    this.approvalStatus,
    this.approvalNote,
    this.assignee,
    this.parentId,
    this.zone,
    this.details,
    this.startStatus,
    this.startNote,
    this.items = const [],
  });

  bool get startRequested => startStatus == 'requested';
  bool get isMain => parentId == null;

  bool get waitsForMe => approvalStatus == 'pending';

  factory CustomerProjectTask.fromJson(Map<String, dynamic> json) => CustomerProjectTask(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    startsOn: json['starts_on'] as String?,
    endsOn: json['ends_on'] as String?,
    requiresApproval: json['requires_approval'] as bool? ?? false,
    approvalStatus: json['approval_status'] as String?,
    approvalNote: json['approval_note'] as String?,
    assignee: json['assignee'] is Map<String, dynamic> ? Assignee.fromJson(json['assignee'] as Map<String, dynamic>) : null,
    parentId: (json['parent_id'] as num?)?.toInt(),
    zone: json['zone'] as String?,
    details: json['details'] as String?,
    startStatus: json['start_status'] as String?,
    startNote: json['start_note'] as String?,
    items: [for (final i in (json['items'] as List<dynamic>? ?? const [])) QuantityItem.fromJson(i as Map<String, dynamic>)],
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

  /// `business` for the operation's own business, `customer` for its buyer.
  final String viewer;

  /// The agreement, the requests waiting for the customer, and the history of the quantities.
  final AgreementBlock block;

  const CustomerProjectView({required this.project, required this.tasks, this.viewer = 'customer', this.block = const AgreementBlock()});

  bool get viewerIsBusiness => viewer == 'business';

  /// The stage being worked on now: the first that is not done (or the last one when all are).
  CustomerProjectTask? get currentStage {
    for (final t in tasks) {
      if (t.status != 'done') return t;
    }
    return tasks.isEmpty ? null : tasks.last;
  }

  /// How many completed stages wait for the customer's approval.
  int get waitingForApproval => tasks.where((t) => t.waitsForMe).length;

  factory CustomerProjectView.fromJson(Map<String, dynamic> json) => CustomerProjectView(
    project: Project.fromJson(json['project'] as Map<String, dynamic>),
    tasks: (json['tasks'] as List<dynamic>? ?? [])
        .map((e) => CustomerProjectTask.fromJson(e as Map<String, dynamic>))
        .toList(),
    viewer: json['viewer'] as String? ?? 'customer',
    block: AgreementBlock.fromJson(json),
  );
}
