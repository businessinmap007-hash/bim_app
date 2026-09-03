import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/business_post.dart';
import 'post_image_carousel.dart';

/// One post, laid out like an actual Instagram post rather than a generic
/// Material card: compact header, the caption, the photo edge-to-edge with
/// square corners (no card chrome boxing it in), then an icon-only action
/// row with the like count and a "view comments" link.
///
/// [showAuthor] is on for a multi-author list (the followed-accounts feed)
/// and off for a single business's own wall, where every card would repeat
/// the same name — on, the avatar/name are also a tap target into
/// [onOpenAuthor]. [onReact]/[onEdit]/[onDelete] are opt-in per screen: the
/// public wall stays read-only, the feed can like, and "my posts" can edit
/// or delete — that menu shows whenever either is set, independently of
/// [showAuthor], so it isn't silently hidden on the one screen it matters.
class PostCard extends StatelessWidget {
  final BusinessPost post;
  final bool showAuthor;
  final ValueChanged<int>? onReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenComments;
  final VoidCallback? onOpenAuthor;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    this.showAuthor = false,
    this.onReact,
    this.onEdit,
    this.onDelete,
    this.onOpenComments,
    this.onOpenAuthor,
    this.onShare,
  });

  /// Edit/delete, when either is set. [onImage] styles it to float over a
  /// photo (small, white-on-black-circle) instead of sitting inline in a
  /// plain header row.
  Widget? _menu(BuildContext context, AppLocalizations l10n, {required bool onImage}) {
    if (onEdit == null && onDelete == null) return null;

    final button = PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert, size: onImage ? 18 : 20, color: onImage ? Colors.white : null),
      onSelected: (choice) {
        if (choice == 'edit') onEdit?.call();
        if (choice == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        if (onEdit != null) PopupMenuItem(value: 'edit', child: Text(l10n.postsEdit)),
        if (onDelete != null) PopupMenuItem(value: 'delete', child: Text(l10n.postsDelete)),
      ],
    );

    if (!onImage) return button;

    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final galleryImages = post.images.isNotEmpty
        ? post.images
        : (post.imageUrl != null ? [PostImage(id: 0, url: post.imageUrl!)] : const <PostImage>[]);
    final hasImages = galleryImages.isNotEmpty;
    final inlineMenu = hasImages ? null : _menu(context, l10n, onImage: false);
    final liked = post.myReaction == 1;
    final hasCaption = post.title.isNotEmpty || post.body.isNotEmpty;
    final canOpenAuthor = showAuthor && post.author != null && onOpenAuthor != null;

    // A bare Column with no card chrome (see the class doc) reads as one
    // continuous surface once a second post follows right after it on the
    // same background — this line is the only thing marking where one post
    // ends and the next begins.
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((showAuthor && post.author != null) || inlineMenu != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
              child: Row(
                children: [
                  if (showAuthor && post.author != null) ...[
                    InkWell(
                      onTap: canOpenAuthor ? onOpenAuthor : null,
                      customBorder: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: post.author!.logoUrl != null
                            ? NetworkImage(post.author!.logoUrl!)
                            : null,
                        child: post.author!.logoUrl == null
                            ? const Icon(Icons.storefront_outlined, size: 16)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: showAuthor && post.author != null
                        ? InkWell(
                            onTap: canOpenAuthor ? onOpenAuthor : null,
                            child: Text(
                              post.author!.name,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  // On a photo-less post there's nowhere but here to put it.
                  ?inlineMenu,
                ],
              ),
            ),
          // The caption sits above the photo (owner's own ordering — the
          // words that give the picture context come first, not tucked
          // underneath it), 2 lines with a "...more" expand for anything
          // longer. No author-name prefix here even when showAuthor is on —
          // the header row right above it already names the author; a
          // second copy immediately below it just reads as a glitch.
          if (hasCaption)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _ExpandableCaption(title: post.title, body: post.body),
            ),
          // Edge-to-edge, square corners — an Instagram photo isn't boxed
          // inside a card, it IS the card. A swipeable gallery once there's
          // more than one. Edit/delete floats on the photo itself rather than
          // a separate bar above it.
          if (hasImages)
            PostImageCarousel(
              images: galleryImages,
              menuAction: _menu(context, l10n, onImage: true),
              onOpenComments: onOpenComments,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // Spread across the full width — like/comment/share each
                  // get their own third of the row instead of clustering
                  // together on one side with empty space past them.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    if (onShare != null)
                      InkWell(
                        onTap: onShare,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.share_outlined,
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
      ),
    );
  }
}

/// The caption text, capped at 2 lines with a "...more" toggle — checked via
/// [TextPainter] against the actual laid-out width rather than guessing a
/// character count, so it's right regardless of font/locale/screen size.
class _ExpandableCaption extends StatefulWidget {
  final String title;
  final String body;
  const _ExpandableCaption({required this.title, required this.body});

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  static const _maxLines = 2;
  bool _expanded = false;

  TextSpan _span(ThemeData theme) => TextSpan(
    children: [
      if (widget.title.isNotEmpty)
        TextSpan(
          text: widget.body.isNotEmpty ? '${widget.title}\n' : widget.title,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      if (widget.body.isNotEmpty) TextSpan(text: widget.body, style: theme.textTheme.bodyMedium),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final span = _span(theme);

    if (_expanded) {
      return Text.rich(span);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: span,
          maxLines: _maxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text.rich(span);
        }

        // "...more" as its own line under the clipped text rather than
        // appended inline — inline risks the ellipsis landing mid-suffix
        // (or hiding it entirely) once the body text alone already fills
        // both lines; a separate tap target is always fully visible.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(span, maxLines: _maxLines, overflow: TextOverflow.ellipsis),
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Text(
                l10n.postsReadMore,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
