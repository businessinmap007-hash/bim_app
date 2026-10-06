import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'photo_source_badge.dart';

/// A full-screen, swipeable, pinch-to-zoom photo viewer for any screen that just needs to show a set of photos
/// starting at one of them (a product's photos, an album).
///
/// The screen is divided so the photo is never fighting the controls — «العرض يكون 80% من ارتفاع الشاشة و20%
/// مقسمة أعلى وأسفل الصورة» — المالك، 2026-10-06:
///  * the top tenth: close, the «2 / 5» counter, and where the photo came from (camera / gallery);
///  * the middle eight tenths: the photo itself (swipe, pinch to zoom, swipe down to close);
///  * the bottom tenth: a strip of thumbnails to jump between the photos.
class FullScreenGallery extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  /// Per photo: `camera` (a live shot) or `upload` (from the gallery); null = not said. Same length as [urls].
  final List<String?>? sources;
  const FullScreenGallery({super.key, required this.urls, this.initialIndex = 0, this.sources});

  /// Opens the viewer as a full-screen route.
  static Future<void> show(BuildContext context, {required List<String> urls, int initialIndex = 0, List<String?>? sources}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(urls: urls, initialIndex: initialIndex, sources: sources),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  final ScrollController _thumbs = ScrollController();
  late int _index = widget.initialIndex;
  double _dragOffset = 0;
  static const _dismissThreshold = 80.0;
  static const _thumbSize = 44.0;
  late final List<TransformationController> _transformControllers = List.generate(
    widget.urls.length,
    (_) => TransformationController(),
  );

  @override
  void dispose() {
    _controller.dispose();
    _thumbs.dispose();
    for (final controller in _transformControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _currentPageZoomed => _transformControllers[_index].value.getMaxScaleOnAxis() > 1.01;

  String? _sourceOf(int i) {
    final sources = widget.sources;
    return sources != null && i < sources.length ? sources[i] : null;
  }

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

  /// Keeps the chosen thumbnail in view as the pages swipe.
  void _scrollThumbsTo(int i) {
    if (!_thumbs.hasClients) return;
    final target = (i * (_thumbSize + 8) - 120).clamp(0.0, _thumbs.position.maxScrollExtent);
    _thumbs.animateTo(target, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final source = _sourceOf(_index);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── the top tenth ────────────────────────────────────────────────
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (widget.urls.length > 1)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('${_index + 1} / ${widget.urls.length}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  const Spacer(),
                  // camera or gallery — the customer is told which this photo is
                  if (source != null) ...[
                    Text(
                      source == 'camera' ? l10n.mediaCapturedByCamera : l10n.mediaFromGallery,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    PhotoSourceBadge(source: source, size: 18),
                    const SizedBox(width: 14),
                  ],
                ],
              ),
            ),
            // ── the eight tenths: the photo ──────────────────────────────────
            Expanded(
              flex: 8,
              child: GestureDetector(
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: Opacity(
                    opacity: (1 - (_dragOffset.abs() / 400)).clamp(0.3, 1.0),
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: widget.urls.length,
                      onPageChanged: (i) {
                        setState(() => _index = i);
                        _scrollThumbsTo(i);
                      },
                      itemBuilder: (context, i) => AnimatedBuilder(
                        animation: _transformControllers[i],
                        builder: (context, child) => InteractiveViewer(
                          transformationController: _transformControllers[i],
                          panEnabled: _transformControllers[i].value.getMaxScaleOnAxis() > 1.01,
                          child: child!,
                        ),
                        child: SizedBox.expand(
                          child: Image(
                            image: NetworkImage(widget.urls[i]),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ── the bottom tenth: thumbnails ─────────────────────────────────
            Expanded(
              flex: 1,
              child: widget.urls.length < 2
                  ? const SizedBox.shrink()
                  : Center(
                      child: SizedBox(
                        height: _thumbSize + 8,
                        child: ListView.separated(
                          controller: _thumbs,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: widget.urls.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) => GestureDetector(
                            onTap: () => _controller.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: _thumbSize,
                              height: _thumbSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: i == _index ? AppColors.accentGold : Colors.transparent, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Opacity(
                                  opacity: i == _index ? 1 : 0.55,
                                  child: Image(image: NetworkImage(widget.urls[i]), fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Colors.white12)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
