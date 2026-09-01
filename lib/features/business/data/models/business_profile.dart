import '../../../../core/env/env.dart';
import 'rating_summary.dart';

/// Which tabs the client should surface — decided by the backend
/// (BusinessPageController::show), not guessed client-side from other data.
class BusinessSections {
  final bool posts;
  final bool menu;
  final bool services;

  const BusinessSections({
    required this.posts,
    required this.menu,
    required this.services,
  });

  bool get any => posts || menu || services;

  factory BusinessSections.fromJson(Map<String, dynamic> json) => BusinessSections(
    posts: json['posts'] as bool? ?? false,
    menu: json['menu'] as bool? ?? false,
    services: json['services'] as bool? ?? false,
  );
}

/// GET /businesses/{id} — the profile aggregate a search result opens into.
class BusinessProfile {
  final int id;
  final String name;
  final String? logoUrl;
  final String? coverUrl;
  final String? about;
  final String? phone;
  final int? categoryId;
  final int? categoryChildId;
  final RatingSummary rating;
  final bool openNow;
  final int postsCount;
  final BusinessSections sections;

  const BusinessProfile({
    required this.id,
    required this.name,
    this.logoUrl,
    this.coverUrl,
    this.about,
    this.phone,
    this.categoryId,
    this.categoryChildId,
    required this.rating,
    required this.openNow,
    required this.postsCount,
    required this.sections,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>? ?? const {};
    final counts = json['counts'] as Map<String, dynamic>? ?? const {};

    return BusinessProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      logoUrl: Env.assetUrl(json['logo'] as String?),
      coverUrl: Env.assetUrl(json['cover'] as String?),
      about: (json['about'] as String?)?.trim().isNotEmpty == true ? json['about'] as String : null,
      phone: json['phone'] as String?,
      categoryId: (category['id'] as num?)?.toInt(),
      categoryChildId: (category['child_id'] as num?)?.toInt(),
      rating: RatingSummary.fromJson(json['rating'] as Map<String, dynamic>? ?? const {}),
      openNow: json['open_now'] as bool? ?? true,
      postsCount: (counts['posts'] as num?)?.toInt() ?? 0,
      sections: BusinessSections.fromJson(json['sections'] as Map<String, dynamic>? ?? const {}),
    );
  }
}
