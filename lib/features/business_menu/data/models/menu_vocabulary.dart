import 'menu_item.dart';

/// One option group as it appears in this merchant's own vocabulary — e.g.
/// "أنواع الأجهزة الكهربائية" (a `line` group, its options are the branches
/// like "ثلاجات") or "ماركات الأجهزة الكهربائية" (a `modifier` group).
class VocabularyGroup {
  final int groupId;
  final String groupName;
  final List<VocabularyOptionRef> options;
  const VocabularyGroup({required this.groupId, required this.groupName, required this.options});

  factory VocabularyGroup.fromJson(Map<String, dynamic> json) => VocabularyGroup(
    groupId: json['group_id'] as int,
    groupName: json['group_name'] as String,
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => VocabularyOptionRef.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// GET /business/menu/vocabulary — what this merchant may say a catalog item
/// IS (`lines`, grouped into what becomes its menu section) and what may
/// qualify it (`modifiers` — brand, condition...), narrowed to this
/// business's own catalog. See Api\V2\BusinessMenuItemController::vocabulary().
class MenuVocabulary {
  final List<VocabularyGroup> lines;
  final List<VocabularyGroup> modifiers;
  const MenuVocabulary({required this.lines, required this.modifiers});

  factory MenuVocabulary.fromJson(Map<String, dynamic> json) => MenuVocabulary(
    lines: (json['lines'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    modifiers: (json['modifiers'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  bool get hasLines => lines.any((g) => g.options.isNotEmpty);
}
