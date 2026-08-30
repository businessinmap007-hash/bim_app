/// A specialty under a root category. `id` IS discovery's `child_id` —
/// see GET /categories/{category}/specialties.
class Specialty {
  final int id;
  final String nameAr;
  final String? nameEn;
  final int businessCount;

  const Specialty({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.businessCount,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) => Specialty(
        id: json['id'] as int,
        nameAr: json['name_ar'] as String? ?? '',
        nameEn: json['name_en'] as String?,
        businessCount: (json['businesses'] as num?)?.toInt() ?? 0,
      );
}
