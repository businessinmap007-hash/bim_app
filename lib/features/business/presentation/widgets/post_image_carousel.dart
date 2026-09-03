import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_image_box.dart';
import '../../data/models/business_post.dart';

/// A post's photo(s), edge-to-edge like [AdaptiveImageBox] for a single
/// image, or a swipeable [PageView] with a dot indicator and an "i/N" badge
/// once there's more than one — the gallery a multi-photo post needs but a
/// static [AdaptiveImageBox] never gave it. Tapping any frame opens it
/// full-screen, pinch-to-zoom, starting on whichever page was showing.
class PostImageCarousel extends StatefulWidget {
  final List<PostImage> images;
  const PostImageCarousel({super.key, required this.images});

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
      return GestureDetector(
        onTap: () => _openFullScreen(0),
        child: AdaptiveImageBox(imageProvider: NetworkImage(url)),
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
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_index + 1}/${widget.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
  const _FullScreenGallery({required this.urls, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: widget.urls.length > 1
            ? Text('${_index + 1} / ${widget.urls.length}')
            : null,
      ),
      body: PageView.builder(
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
    );
  }
}
