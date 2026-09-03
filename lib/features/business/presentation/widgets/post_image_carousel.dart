import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_image_box.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(
          urls: widget.images.map((e) => e.url).toList(),
          initialIndex: initialIndex,
          onOpenComments: widget.onOpenComments,
        ),
        fullscreenDialog: true,
      ),
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

class _FullScreenGallery extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final VoidCallback? onOpenComments;
  const _FullScreenGallery({required this.urls, required this.initialIndex, this.onOpenComments});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  double _dragOffset = 0;
  // A vertical swipe — either direction — closes the viewer, the same
  // dismiss gesture every full-screen photo view uses. Only free to fire
  // when the current page isn't zoomed in (see panEnabled below): otherwise
  // a pinch-pan would trigger it by accident.
  static const _dismissThreshold = 80.0;
  // One per page, so pinch-zooming one photo doesn't leave the next one
  // pre-zoomed. Its own listener toggles panEnabled below — an
  // InteractiveViewer that's always pan-enabled fights the PageView for
  // every horizontal drag and wins, so swiping between photos silently
  // stops working the moment there's more than one. Panning only turns on
  // once the user has actually zoomed in past 1x.
  late final List<TransformationController> _transformControllers = List.generate(
    widget.urls.length,
    (_) => TransformationController(),
  );

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _transformControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _currentPageZoomed => _transformControllers[_index].value.getMaxScaleOnAxis() > 1.01;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_currentPageZoomed) return;
    setState(() => _dragOffset += details.delta.dy);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _dismissThreshold) {
      Navigator.of(context).pop();
    } else if (_dragOffset != 0) {
      setState(() => _dragOffset = 0);
    }
  }

  void _openComments() {
    Navigator.of(context).pop();
    widget.onOpenComments?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        // Forced LTR — see the same fix on the inline carousel badge above.
        title: widget.urls.length > 1
            ? Directionality(
                textDirection: TextDirection.ltr,
                child: Text('${_index + 1} / ${widget.urls.length}'),
              )
            : null,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Opacity(
            opacity: (1 - (_dragOffset.abs() / 400)).clamp(0.3, 1.0),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => AnimatedBuilder(
                animation: _transformControllers[i],
                builder: (context, child) => InteractiveViewer(
                  transformationController: _transformControllers[i],
                  panEnabled: _transformControllers[i].value.getMaxScaleOnAxis() > 1.01,
                  child: child!,
                ),
                child: SizedBox.expand(
                  child: Image(image: NetworkImage(widget.urls[i]), fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.onOpenComments == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: IconButton(
                  icon: const Icon(Icons.mode_comment_outlined, color: Colors.white),
                  onPressed: _openComments,
                ),
              ),
            ),
    );
  }
}
