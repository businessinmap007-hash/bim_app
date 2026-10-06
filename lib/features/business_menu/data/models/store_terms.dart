/// «شروط المتجر» — a policy of the store (returns, minimum order, delivery, trade scope), answered
/// once in its profile. The merchant's copy lists every option with `selected`; the customer's copy
/// (menu page, cart, order) lists only what the store answered. Edited in the profile (GET/PATCH /profile/options).
class StoreTermOption {
  final int id;
  final String name;
  final bool selected;

  const StoreTermOption({required this.id, required this.name, this.selected = true});

  factory StoreTermOption.fromJson(Map<String, dynamic> json) => StoreTermOption(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    selected: json['selected'] as bool? ?? true,
  );
}

class StoreTermGroup {
  final int groupId;
  final String name;
  final List<StoreTermOption> options;

  const StoreTermGroup({required this.groupId, required this.name, required this.options});

  factory StoreTermGroup.fromJson(Map<String, dynamic> json) => StoreTermGroup(
    groupId: (json['group_id'] as num).toInt(),
    name: json['group_name'] as String? ?? '',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => StoreTermOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// The names the store answered, for a read-only line.
  String get answer => options.where((o) => o.selected).map((o) => o.name).join('، ');

  static List<StoreTermGroup> listFrom(Object? json) =>
      (json as List<dynamic>? ?? []).map((e) => StoreTermGroup.fromJson(e as Map<String, dynamic>)).toList();
}
