import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_image_box.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../data/models/business_post.dart';

/// A post's photo(s), edge-to-edge like [AdaptiveImageBox] for a single
/// image, or a swipeable [PageView] with a dot indicator and an "i/N" badge
/// once there's more than one — the gallery a multi-photo post needs but a
/// static [AdaptiveImageBox] never gave it. Tapping any frame opens it
/// full-screen, pinch-to-zoom, starting on whichever page was showing.
///
/// [menuAction] (edit/delete, when the caller owns the post) floats directly
/// on the photo itself — top-end (left in Arabic, right in English — the
/// side a "..." menu conventionally sits on in each language), opposite the
/// "i/N" badge — rather than living in a separate header bar above it.
class PostImageCarousel extends StatefulWidget {
  final List<PostImage> images;
  final Widget? menuAction;
  final VoidCallback? onOpenComments;
  const PostImageCarousel({super.key, required this.images, this.menuAction, this.onOpenComments});

  @override
  State<PostImageCarousel> createState() => _PostImageCarouselState();
}

class _PostImageCarouselState extends State<PostImageCarousel> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen(int initialIndex) {
    // the app's one photo viewer — shared with albums, products, chat… (see FullScreenGallery)
    FullScreenGallery.show(
      context,
      urls: widget.images.map((e) => e.url).toList(),
      sources: widget.images.map((e) => e.source).toList(),
      initialIndex: initialIndex,
      onOpenComments: widget.onOpenComments,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.length <= 1) {
      final url = widget.images.isEmpty ? null : widget.images.first.url;
      if (url == null) return const SizedBox.shrink();
      return AdaptiveImageBox(
        imageProvider: NetworkImage(url),
        overlays: [
          GestureDetector(onTap: () => _openFullScreen(0)),
          if (widget.menuAction != null) PositionedDirectional(top: 6, end: 6, child: widget.menuAction!),
        ],
      );
    }

    return AdaptiveImageBox(
      imageProvider: NetworkImage(widget.images.first.url),
      overlays: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => _openFullScreen(i),
            child: Image(image: NetworkImage(widget.images[i].url), fit: BoxFit.cover),
          ),
        ),
        if (widget.menuAction != null) PositionedDirectional(top: 6, end: 6, child: widget.menuAction!),
        PositionedDirectional(
          top: 10,
          start: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            // Forced LTR: a bare "N/M" run reading through an RTL paragraph
            // can have the bidi algorithm reorder it to "M/N" — a page
            // counter must read in a fixed digit order regardless of locale.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${_index + 1}/${widget.images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.images.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: i == _index ? 7 : 5,
                  height: i == _index ? 7 : 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: i == _index ? 0.95 : 0.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
