import 'package:flutter/material.dart';

/// Sizes its image the way Instagram sizes a post: neither a forced square
/// crop nor the image's raw (sometimes absurd) ratio — clamped between a
/// 4:5 portrait cap and a 1.91:1 landscape cap, cropping (BoxFit.cover)
/// only what falls outside that range. A tall portrait and a wide
/// landscape both read as intentional, not stretched or letterboxed.
class AdaptiveImageBox extends StatefulWidget {
  final ImageProvider imageProvider;
  final BorderRadius borderRadius;
  final List<Widget> overlays;

  static const minRatio = 0.8; // 4:5
  static const maxRatio = 1.91; // 1.91:1

  const AdaptiveImageBox({
    super.key,
    required this.imageProvider,
    this.borderRadius = BorderRadius.zero,
    this.overlays = const [],
  });

  @override
  State<AdaptiveImageBox> createState() => _AdaptiveImageBoxState();
}

class _AdaptiveImageBoxState extends State<AdaptiveImageBox> {
  double? _ratio;
  ImageStream? _stream;
  late final ImageStreamListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = ImageStreamListener(_onImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant AdaptiveImageBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider) {
      _ratio = null;
      _resolve();
    }
  }

  void _resolve() {
    final newStream = widget.imageProvider.resolve(createLocalImageConfiguration(context));
    if (newStream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = newStream;
    _stream!.addListener(_listener);
  }

  void _onImage(ImageInfo info, bool synchronousCall) {
    final raw = info.image.width / info.image.height;
    final clamped = raw.clamp(AdaptiveImageBox.minRatio, AdaptiveImageBox.maxRatio);
    if (!mounted) return;
    setState(() => _ratio = clamped);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        // 4:5 while the real size is still resolving, so the layout
        // doesn't visibly pop once it's known.
        aspectRatio: _ratio ?? AdaptiveImageBox.minRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(image: widget.imageProvider, fit: BoxFit.cover),
            ...widget.overlays,
          ],
        ),
      ),
    );
  }
}
