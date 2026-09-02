import '../../../../core/env/env.dart';

class CommentAuthor {
  final int id;
  final String name;
  final String? logoUrl;
  final String? imageUrl;

  const CommentAuthor({required this.id, required this.name, this.logoUrl, this.imageUrl});

  factory CommentAuthor.fromJson(Map<String, dynamic> json) => CommentAuthor(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    logoUrl: Env.assetUrl(json['logo'] as String?),
    imageUrl: Env.assetUrl(json['image'] as String?),
  );
}

/// Mirrors `CommentResource`. `isMine`/`canDelete` are only ever present on
/// responses the controller attached viewer state to (every one this app
/// calls); `isPrivate` is the "only the post's owner and I can see this"
/// flag, not a delete-vs-visible distinction.
class Comment {
  final int id;
  final int postId;
  final int parentId;
  final String body;
  final bool isPrivate;
  final int repliesCount;
  final CommentAuthor? author;
  final bool isMine;
  final bool canDelete;
  final DateTime? createdAt;

  const Comment({
    required this.id,
    required this.postId,
    this.parentId = 0,
    required this.body,
    this.isPrivate = false,
    this.repliesCount = 0,
    this.author,
    this.isMine = false,
    this.canDelete = false,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as int,
    postId: (json['post_id'] as num?)?.toInt() ?? 0,
    parentId: (json['parent_id'] as num?)?.toInt() ?? 0,
    body: json['comment'] as String? ?? '',
    isPrivate: json['is_private'] as bool? ?? false,
    repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
    author: json['author'] != null ? CommentAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
    isMine: json['is_mine'] as bool? ?? false,
    canDelete: json['can_delete'] as bool? ?? false,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}
