/// A business's own menu section — see Api\V2\BusinessMenuSectionController
/// / MenuSectionResource.
class BusinessMenuSection {
  final int id;
  final String nameAr;
  final String? nameEn;
  final int sortOrder;
  final bool isActive;
  /// Null for one the owner typed by hand; set for one grown from a
  /// vocabulary `line` option group — matches that group's own id, so a
  /// picker built from BOTH sections and groups can tell which groups
  /// already have a section and skip listing them twice.
  final int? optionGroupId;

  const BusinessMenuSection({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.sortOrder,
    required this.isActive,
    this.optionGroupId,
  });

  factory BusinessMenuSection.fromJson(Map<String, dynamic> json) => BusinessMenuSection(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    sortOrder: json['sort_order'] as int,
    isActive: json['is_active'] as bool,
    optionGroupId: json['option_group_id'] as int?,
  );
}
