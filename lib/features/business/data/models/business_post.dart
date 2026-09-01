import '../../../../core/env/env.dart';

/// One image attached to a post — mirrors PostResource's `images` array.
class PostImage {
  final int id;
  final String url;

  const PostImage({required this.id, required this.url});

  factory PostImage.fromJson(Map<String, dynamic> json) => PostImage(
    id: json['id'] as int,
    url: Env.assetUrl(json['image'] as String?) ?? '',
  );
}

/// Mirrors `App\Http\Resources\V2\PostResource` — a business's feed post, as
/// returned by GET /businesses/{id}/posts. Reactions (my_reaction) and
/// authorship aren't needed on a single business's own wall (the author is
/// always that business), so they're left out here on purpose.
class BusinessPost {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final List<PostImage> images;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final DateTime? createdAt;

  const BusinessPost({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.images,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    this.createdAt,
  });

  factory BusinessPost.fromJson(Map<String, dynamic> json) => BusinessPost(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    imageUrl: Env.assetUrl(json['image'] as String?),
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => PostImage.fromJson(e as Map<String, dynamic>))
        .toList(),
    likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
    dislikesCount: (json['dislikes_count'] as num?)?.toInt() ?? 0,
    commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
