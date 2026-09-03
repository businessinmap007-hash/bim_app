import 'package:flutter/material.dart';

import '../../data/models/business_post.dart';
import 'post_image_carousel.dart';

/// One post, laid out like an actual Instagram post rather than a generic
/// Material card: compact header, the photo edge-to-edge with square
/// corners (no card chrome boxing it in), an icon-only action row, the
/// like count bold on its own line, then a caption line that leads with
/// the author's name the same way Instagram repeats it under the image.
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
  final VoidCallback? onOpenComments;

  const PostCard({
    super.key,
    required this.post,
    this.showAuthor = false,
    this.onReact,
    this.onDelete,
    this.onOpenComments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final galleryImages = post.images.isNotEmpty
        ? post.images
        : (post.imageUrl != null ? [PostImage(id: 0, url: post.imageUrl!)] : const <PostImage>[]);
    final liked = post.myReaction == 1;
    final hasCaption = post.title.isNotEmpty || post.body.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAuthor && post.author != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: post.author!.logoUrl != null
                      ? NetworkImage(post.author!.logoUrl!)
                      : null,
                  child: post.author!.logoUrl == null
                      ? const Icon(Icons.storefront_outlined, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post.author!.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
        // Edge-to-edge, square corners — an Instagram photo isn't boxed
        // inside a card, it IS the card. A swipeable gallery once there's
        // more than one.
        if (galleryImages.isNotEmpty) PostImageCarousel(images: galleryImages),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: onReact != null
                        ? () => onReact!(liked ? 0 : 1)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 24,
                        color: liked
                            ? theme.colorScheme.error
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onOpenComments,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.mode_comment_outlined,
                        size: 22,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
              if (post.likesCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '${post.likesCount} إعجاب',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (hasCaption)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (showAuthor && post.author != null)
                          TextSpan(
                            text: '${post.author!.name} ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (post.title.isNotEmpty)
                          TextSpan(
                            text: post.body.isNotEmpty
                                ? '${post.title}\n'
                                : post.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (post.body.isNotEmpty)
                          TextSpan(
                            text: post.body,
                            style: theme.textTheme.bodyMedium,
                          ),
                      ],
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (post.commentsCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                  child: InkWell(
                    onTap: onOpenComments,
                    child: Text(
                      'عرض التعليقات (${post.commentsCount})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
