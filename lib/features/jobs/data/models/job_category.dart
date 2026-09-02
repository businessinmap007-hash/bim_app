/// A specialty under a root, only ever present when it has an open job —
/// mirrors one entry of `JobController::categories()`'s `children`.
class JobCategoryChild {
  final int id;
  final String? name;
  final int jobsCount;

  const JobCategoryChild({required this.id, this.name, this.jobsCount = 0});

  factory JobCategoryChild.fromJson(Map<String, dynamic> json) => JobCategoryChild(
    id: json['id'] as int,
    name: json['name'] as String?,
    jobsCount: (json['jobs_count'] as num?)?.toInt() ?? 0,
  );
}

/// A root category with at least one open job — mirrors
/// `JobController::categories()`'s top-level rows.
class JobCategoryGroup {
  final int id;
  final String? name;
  final int jobsCount;
  final List<JobCategoryChild> children;

  const JobCategoryGroup({required this.id, this.name, this.jobsCount = 0, this.children = const []});

  factory JobCategoryGroup.fromJson(Map<String, dynamic> json) => JobCategoryGroup(
    id: json['id'] as int,
    name: json['name'] as String?,
    jobsCount: (json['jobs_count'] as num?)?.toInt() ?? 0,
    children: (json['children'] as List<dynamic>? ?? [])
        .map((e) => JobCategoryChild.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
