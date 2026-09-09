/// One option in the FULL `line` catalog for this business's (root, child) —
/// e.g. "خيار" under "الخضروات" — flagged whether the business already
/// ticked it. See GET /business/menu/available-types.
class AvailableTypeOption {
  final int id;
  final String nameAr;
  final String? nameEn;
  final bool selected;
  const AvailableTypeOption({required this.id, required this.nameAr, this.nameEn, required this.selected});

  factory AvailableTypeOption.fromJson(Map<String, dynamic> json) => AvailableTypeOption(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    selected: json['selected'] as bool? ?? false,
  );

  AvailableTypeOption copyWith({bool? selected}) =>
      AvailableTypeOption(id: id, nameAr: nameAr, nameEn: nameEn, selected: selected ?? this.selected);
}

/// A section of the full `line` catalog — e.g. "الخضروات" (45 options) or
/// "الفواكه" (77 options) for a greengrocer's child. Unlike
/// [VocabularyGroup] (narrowed to what's already ticked, or the child's
/// whole list when nothing is), this is always the full universe, so a
/// merchant can grow a narrow starting selection.
class AvailableTypeGroup {
  final int groupId;
  final String groupName;
  final List<AvailableTypeOption> options;
  const AvailableTypeGroup({required this.groupId, required this.groupName, required this.options});

  factory AvailableTypeGroup.fromJson(Map<String, dynamic> json) => AvailableTypeGroup(
    groupId: json['group_id'] as int,
    groupName: json['group_name'] as String,
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => AvailableTypeOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  int get selectedCount => options.where((o) => o.selected).length;
}
