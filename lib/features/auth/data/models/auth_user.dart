import '../../../../core/env/env.dart';
import '../../../business/data/models/business_profile.dart' show SocialLinks;

/// Mirrors `App\Http\Resources\V2\AccountResource` on the backend.
/// Kept intentionally small — extend as screens need more fields, but never
/// guess a field name; check the resource/openapi-v2.yaml first.
class AuthUser {
  final int id;
  final String name;
  final String? nameEn;
  final String email;
  final String phone;
  final String type; // 'client' | 'business'
  final String? logoUrl;
  final String? coverUrl;
  final String? imageUrl;
  final String? about;
  final double? latitude;
  final double? longitude;
  final int? countryId;
  final int? governorateId;
  final int? cityId;
  final int? categoryId;
  final int? categoryChildId;
  final SocialLinks? social;

  const AuthUser({
    required this.id,
    required this.name,
    this.nameEn,
    required this.email,
    required this.phone,
    required this.type,
    this.logoUrl,
    this.coverUrl,
    this.imageUrl,
    this.about,
    this.latitude,
    this.longitude,
    this.countryId,
    this.governorateId,
    this.cityId,
    this.categoryId,
    this.categoryChildId,
    this.social,
  });

  bool get isBusiness => type == 'business';
  bool get hasLocation => latitude != null && longitude != null;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    nameEn: json['name_en'] as String?,
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    type: json['type'] as String? ?? 'client',
    logoUrl: Env.assetUrl(json['logo'] as String?),
    coverUrl: Env.assetUrl(json['cover'] as String?),
    imageUrl: Env.assetUrl(json['image'] as String?),
    about: json['about'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    countryId: (json['country_id'] as num?)?.toInt(),
    governorateId: (json['governorate_id'] as num?)?.toInt(),
    cityId: (json['city_id'] as num?)?.toInt(),
    categoryId: (json['category_id'] as num?)?.toInt(),
    categoryChildId: (json['category_child_id'] as num?)?.toInt(),
    social: SocialLinks.fromJsonOrNull(json['social']),
  );
}
