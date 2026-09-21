/// One linkable thing — a menu item or bookable item the business owns.
class PostSubjectItem {
  final int id;
  final String name;
  final double? price;

  const PostSubjectItem({required this.id, required this.name, this.price});

  factory PostSubjectItem.fromJson(Map<String, dynamic> json) => PostSubjectItem(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
  );
}

/// A section of items (a menu section, or the single bookable-items group).
class PostSubjectGroup {
  final String label;
  final List<PostSubjectItem> items;

  const PostSubjectGroup({required this.label, required this.items});

  factory PostSubjectGroup.fromJson(Map<String, dynamic> json) => PostSubjectGroup(
    label: json['label'] as String? ?? '',
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => PostSubjectItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// One kind of subject (`menu_item` / `bookable_item`) — mirrors an entry of
/// `GET /posts/subject-options`'s `options`.
class PostSubjectType {
  final String type;
  final String label;
  final List<PostSubjectGroup> groups;

  const PostSubjectType({required this.type, required this.label, required this.groups});

  factory PostSubjectType.fromJson(Map<String, dynamic> json) => PostSubjectType(
    type: json['type'] as String? ?? '',
    label: json['label'] as String? ?? '',
    groups: (json['groups'] as List<dynamic>? ?? [])
        .map((e) => PostSubjectGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
