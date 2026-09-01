import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_image_box.dart';
import '../../data/models/business_post.dart';

/// One post on a business's wall — reuses [AdaptiveImageBox] so a post
/// photo gets the same Instagram-style adaptive framing as the media
/// composer, without letterboxing tall or wide shots. Reactions
/// (like/comment) are a later module — this is the read-only card.
class PostCard extends StatelessWidget {
  final BusinessPost post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = post.imageUrl ?? (post.images.isNotEmpty ? post.images.first.url : null);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    Icon(Icons.favorite_border_rounded, size: 16, color: theme.hintColor),
                    const SizedBox(width: 4),
                    Text('${post.likesCount}', style: theme.textTheme.bodySmall),
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
