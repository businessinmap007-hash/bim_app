import '../../../../core/env/env.dart';

/// One row in a group, mirroring BusinessGroupController::serialize()'s
/// `members[]` — the id here is the membership row's own id (needed to
/// remove it), not the member business's own id.
class BusinessGroupMember {
  final int id;
  final int businessId;
  final String name;
  final String? logoUrl;

  const BusinessGroupMember({required this.id, required this.businessId, required this.name, this.logoUrl});

  factory BusinessGroupMember.fromJson(Map<String, dynamic> json) => BusinessGroupMember(
    id: json['id'] as int,
    businessId: json['business_id'] as int,
    name: json['name'] as String? ?? '',
    logoUrl: Env.assetUrl(json['logo'] as String?),
  );
}

/// A business's own named group of OTHER businesses ("محلات الخضار",
/// "مصانع الأثاث") — a reusable target list for wholesale/retail offers. See
/// BusinessGroupController on the backend. `members` is only populated by
/// endpoints that return a single group (index/create/rename/add/remove);
/// treat an empty list from a stale copy as "not loaded", not "no members".
class BusinessGroup {
  final int id;
  final String name;
  final int membersCount;
  final List<BusinessGroupMember> members;

  const BusinessGroup({
    required this.id,
    required this.name,
    required this.membersCount,
    this.members = const [],
  });

  factory BusinessGroup.fromJson(Map<String, dynamic> json) => BusinessGroup(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    membersCount: json['members_count'] as int? ?? 0,
    members: (json['members'] as List<dynamic>? ?? [])
        .map((e) => BusinessGroupMember.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
