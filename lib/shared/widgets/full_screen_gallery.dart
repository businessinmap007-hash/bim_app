import 'package:flutter/material.dart';

/// A plain full-screen, swipeable, pinch-to-zoom photo viewer — the same
/// interaction PostImageCarousel's own gallery gives a post's photos, without
/// the post-specific "open comments" hook, for any other screen that just
/// needs to show a set of photos starting at one of them (a menu item's
/// gallery, opened by tapping its photo-count badge).
class FullScreenGallery extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const FullScreenGallery({super.key, required this.urls, this.initialIndex = 0});

  /// Opens the viewer as a full-screen route.
  static Future<void> show(BuildContext context, {required List<String> urls, int initialIndex = 0}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(urls: urls, initialIndex: initialIndex),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  double _dragOffset = 0;
  static const _dismissThreshold = 80.0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
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
    );
  }
}
