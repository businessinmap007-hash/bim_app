import '../../../../core/env/env.dart';

/// One row of GET /follows — see Api\V2\FollowController::index. Almost
/// always a business (following drives the personal posts feed's audience).
class FollowedAccount {
  final int id;
  final String name;
  final String? type;
  final String? logoUrl;
  final String? imageUrl;

  const FollowedAccount({
    required this.id,
    required this.name,
    this.type,
    this.logoUrl,
    this.imageUrl,
  });

  factory FollowedAccount.fromJson(Map<String, dynamic> json) => FollowedAccount(
    id: json['id'] as int,
    name: json['name'] as String,
    type: json['type'] as String?,
    logoUrl: Env.assetUrl(json['logo'] as String?),
    imageUrl: Env.assetUrl(json['image'] as String?),
  );
}
