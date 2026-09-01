import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_image_box.dart';
import '../../data/models/business_post.dart';

/// One post — reuses [AdaptiveImageBox] so a post photo gets the same
/// Instagram-style adaptive framing as the media composer, without
/// letterboxing tall or wide shots.
///
/// [showAuthor] is on for a multi-author list (the followed-accounts feed)
/// and off for a single business's own wall, where every card would repeat
/// the same name. [onReact]/[onDelete] are opt-in per screen: the public
/// wall stays read-only, the feed can like, and "my posts" can delete.
class PostCard extends StatelessWidget {
  final BusinessPost post;
  final bool showAuthor;
  final ValueChanged<int>? onReact;
  final VoidCallback? onDelete;

  const PostCard({super.key, required this.post, this.showAuthor = false, this.onReact, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = post.imageUrl ?? (post.images.isNotEmpty ? post.images.first.url : null);
    final liked = post.myReaction == 1;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAuthor && post.author != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: post.author!.logoUrl != null ? NetworkImage(post.author!.logoUrl!) : null,
                    child: post.author!.logoUrl == null ? const Icon(Icons.storefront_outlined, size: 16) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.author!.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          if (imageUrl != null) AdaptiveImageBox(imageProvider: NetworkImage(imageUrl)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title.isNotEmpty)
                  Text(post.title, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (post.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(post.body, style: theme.textTheme.bodyMedium, maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: onReact != null ? () => onReact!(liked ? 0 : 1) : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Row(
                          children: [
                            Icon(
                              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: liked ? theme.colorScheme.error : theme.hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text('${post.likesCount}', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.mode_comment_outlined, size: 16, color: theme.hintColor),
                    const SizedBox(width: 4),
                    Text('${post.commentsCount}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
