import '../../../../core/env/env.dart';

/// A root category — the app's opening screen. Mirrors `GET /categories`.
class CategoryRoot {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? slug;
  final String? imageUrl;

  const CategoryRoot({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.slug,
    this.imageUrl,
  });

  factory CategoryRoot.fromJson(Map<String, dynamic> json) => CategoryRoot(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
    slug: json['slug'] as String?,
    imageUrl: Env.assetUrl(json['image'] as String?),
  );

  /// The name to show for [languageCode] — falls back to Arabic when the
  /// English name is missing (most of today's taxonomy) rather than a
  /// blank label.
  String localizedName(String languageCode) {
    if (languageCode == 'en' && (nameEn?.isNotEmpty ?? false)) return nameEn!;
    return nameAr;
  }
}
