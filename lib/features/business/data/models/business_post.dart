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

/// The author of a post — present on every PostResource payload (business
/// wall, personal feed, and "my posts") since all three eager-load `user`.
class PostAuthor {
  final int id;
  final String name;
  final String? logoUrl;

  const PostAuthor({required this.id, required this.name, this.logoUrl});

  factory PostAuthor.fromJson(Map<String, dynamic> json) => PostAuthor(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    logoUrl: Env.assetUrl((json['logo'] as String?) ?? (json['image'] as String?)),
  );
}

/// Mirrors `App\Http\Resources\V2\PostResource` — one post, as returned by
/// GET /businesses/{id}/posts, GET /posts (the followed-accounts feed) and
/// GET /posts/mine. `author`/`myReaction`/`isMine` are always present on the
/// wire (every caller eager-loads `user` and attaches viewer state); a
/// single-business wall just happens to repeat the same author on every row.
class BusinessPost {
  final int id;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final List<PostImage> images;
  final PostAuthor? author;
  final int? myReaction;
  final bool isMine;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final DateTime? createdAt;

  const BusinessPost({
    required this.id,
    this.type = 'post',
    required this.title,
    required this.body,
    this.imageUrl,
    required this.images,
    this.author,
    this.myReaction,
    this.isMine = false,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    this.createdAt,
  });

  factory BusinessPost.fromJson(Map<String, dynamic> json) => BusinessPost(
    id: json['id'] as int,
    type: json['type'] as String? ?? 'post',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    imageUrl: Env.assetUrl(json['image'] as String?),
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => PostImage.fromJson(e as Map<String, dynamic>))
        .toList(),
    author: json['author'] is Map<String, dynamic> ? PostAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
    myReaction: (json['my_reaction'] as num?)?.toInt(),
    isMine: json['is_mine'] as bool? ?? false,
    likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
    dislikesCount: (json['dislikes_count'] as num?)?.toInt() ?? 0,
    commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
