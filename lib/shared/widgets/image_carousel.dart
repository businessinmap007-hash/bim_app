import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Swipeable image gallery with a dot page-indicator, matching Instagram's
/// multi-photo post carousel. Used anywhere a post/listing/product needs to
/// show more than one photo — feed posts today, product/listing galleries
/// later.
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double aspectRatio;
  final BorderRadius borderRadius;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.aspectRatio = 1,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    final single = widget.imageUrls.length == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: widget.borderRadius,
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: single
                ? _CarouselImage(url: widget.imageUrls.first)
                : PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) => setState(() => _page = index),
                    itemBuilder: (context, index) =>
                        _CarouselImage(url: widget.imageUrls[index]),
                  ),
          ),
        ),
        if (!single) ...[
          const SizedBox(height: 8),
          _Dots(count: widget.imageUrls.length, activeIndex: _page),
        ],
      ],
    );
  }
}

class _CarouselImage extends StatelessWidget {
  final String url;
  const _CarouselImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          ColoredBox(color: Theme.of(context).colorScheme.surface),
      errorWidget: (context, url, error) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Icon(
          Icons.broken_image_outlined,
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _Dots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : color.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
