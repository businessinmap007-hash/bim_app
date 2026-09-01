import '../../../../core/env/env.dart';

/// A named id — category, category child, or the posting business, all of
/// which JobController's publicShape() renders the same tiny `{id, name}`
/// (or `{id, name, logo}`) shape.
class JobRef {
  final int id;
  final String name;
  final String? logoUrl;

  const JobRef({required this.id, required this.name, this.logoUrl});

  factory JobRef.fromJson(Map<String, dynamic> json) =>
      JobRef(id: json['id'] as int, name: json['name'] as String? ?? '', logoUrl: Env.assetUrl(json['logo'] as String?));
}

/// Mirrors `Api\V2\JobController::publicShape()` — a vacancy, as returned by
/// GET /jobs, GET /jobs/{id} and GET /jobs/mine (`withBody: true` on the
/// latter two, so body/requirements are only sometimes present).
class JobPost {
  final int id;
  final String title;
  final String? body;
  final String? requirements;
  final String? salary;
  final JobRef? category;
  final JobRef? categoryChild;
  final JobRef? business;
  final int applicantsCount;
  final bool isActive;
  final DateTime? expireAt;
  final DateTime? createdAt;

  const JobPost({
    required this.id,
    required this.title,
    this.body,
    this.requirements,
    this.salary,
    this.category,
    this.categoryChild,
    this.business,
    required this.applicantsCount,
    this.isActive = true,
    this.expireAt,
    this.createdAt,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) => JobPost(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    body: json['body'] as String?,
    requirements: json['requirements'] as String?,
    salary: json['salary'] as String?,
    category: json['category'] is Map<String, dynamic> ? JobRef.fromJson(json['category'] as Map<String, dynamic>) : null,
    categoryChild: json['category_child'] is Map<String, dynamic>
        ? JobRef.fromJson(json['category_child'] as Map<String, dynamic>)
        : null,
    business: json['business'] is Map<String, dynamic> ? JobRef.fromJson(json['business'] as Map<String, dynamic>) : null,
    applicantsCount: (json['applicants_count'] as num?)?.toInt() ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    expireAt: json['expire_at'] != null ? DateTime.tryParse(json['expire_at'] as String) : null,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
