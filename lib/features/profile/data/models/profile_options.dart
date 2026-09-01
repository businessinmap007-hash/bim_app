/// One selectable attribute — "تقسيط", "توصيل مجاني" — describing the
/// business itself, distinct from a priced offering. Mirrors one entry in
/// ProfileController::optionsPayload()'s `groups[].options[]`.
class ProfileOption {
  final int id;
  final String name;
  final bool selected;

  const ProfileOption({required this.id, required this.name, required this.selected});

  factory ProfileOption.fromJson(Map<String, dynamic> json) => ProfileOption(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    selected: json['selected'] as bool? ?? false,
  );
}

/// One attribute group — «الدفع», «التوصيل» — grouping related options
/// together for display, same grouping the backend already computed.
class ProfileOptionGroup {
  final int? id;
  final String name;
  final List<ProfileOption> options;

  const ProfileOptionGroup({required this.id, required this.name, required this.options});

  factory ProfileOptionGroup.fromJson(Map<String, dynamic> json) => ProfileOptionGroup(
    id: json['id'] as int?,
    name: json['name'] as String? ?? '',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => ProfileOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// GET /profile/options — the whole attribute catalog for the business's own
/// specialty, each option marked with whether it's currently picked.
class ProfileOptionsPayload {
  final int? childId;
  final List<ProfileOptionGroup> groups;
  final List<int> selectedIds;

  const ProfileOptionsPayload({required this.childId, required this.groups, required this.selectedIds});

  factory ProfileOptionsPayload.fromJson(Map<String, dynamic> json) => ProfileOptionsPayload(
    childId: json['child_id'] as int?,
    groups: (json['groups'] as List<dynamic>? ?? [])
        .map((e) => ProfileOptionGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    selectedIds: (json['selected_ids'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
  );
}
