import '../../../../core/env/env.dart';

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
  );
}
