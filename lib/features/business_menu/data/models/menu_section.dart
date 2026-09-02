/// A business's own menu section — see Api\V2\BusinessMenuSectionController
/// / MenuSectionResource.
class BusinessMenuSection {
  final int id;
  final String nameAr;
  final String? nameEn;
  final int sortOrder;
  final bool isActive;

  const BusinessMenuSection({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.sortOrder,
    required this.isActive,
  });

  factory BusinessMenuSection.fromJson(Map<String, dynamic> json) => BusinessMenuSection(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String?,
    sortOrder: json['sort_order'] as int,
    isActive: json['is_active'] as bool,
  );
}
