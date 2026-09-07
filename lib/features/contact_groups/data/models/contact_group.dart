/// One row in a group, mirroring ContactGroupController::serialize()'s
/// `members[]` — the id here is the membership row's own id (needed to
/// remove it), not the member's user id.
class ContactGroupMember {
  final int id;
  final int userId;
  final String name;

  const ContactGroupMember({required this.id, required this.userId, required this.name});

  factory ContactGroupMember.fromJson(Map<String, dynamic> json) => ContactGroupMember(
    id: json['id'] as int,
    userId: json['user_id'] as int,
    name: json['name'] as String? ?? '',
  );
}

/// A user's own named contact group ("العائلة", "أصدقاء دمياط") — see
/// ContactGroupController on the backend. `members` is only populated by
/// endpoints that return a single group (index/create/rename/add/remove);
/// treat an empty list from a stale copy as "not loaded", not "no members".
class ContactGroup {
  final int id;
  final String name;
  final int membersCount;
  final List<ContactGroupMember> members;

  const ContactGroup({
    required this.id,
    required this.name,
    required this.membersCount,
    this.members = const [],
  });

  factory ContactGroup.fromJson(Map<String, dynamic> json) => ContactGroup(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    membersCount: json['members_count'] as int? ?? 0,
    members: (json['members'] as List<dynamic>? ?? [])
        .map((e) => ContactGroupMember.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
