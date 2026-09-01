import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

enum _CropAspect { original, square, portrait, landscape }

/// A lightweight, dependency-free crop tool: the frame stays fixed and the
/// photo pans/zooms underneath it (the same gesture Instagram's own crop
/// step uses), then export captures exactly what's visible in the frame.
/// Built on InteractiveViewer + RepaintBoundary rather than a native
/// cropper plugin, so it works identically on every platform this app
/// targets — web included — with no extra native setup.
class ImageCropperScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ImageCropperScreen({super.key, required this.imageBytes});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  final _boundaryKey = GlobalKey();
  final _viewerController = TransformationController();
  _CropAspect _aspect = _CropAspect.original;
  ui.Image? _decoded;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _decoded = frame.image);
  }

  double _frameRatioFor(ui.Image image) {
    switch (_aspect) {
      case _CropAspect.original:
        return (image.width / image.height).clamp(0.5, 2.0);
      case _CropAspect.square:
        return 1;
      case _CropAspect.portrait:
        return 0.8;
      case _CropAspect.landscape:
        return 1.91;
    }
  }

  void _setAspect(_CropAspect aspect) {
    // The old transform was relative to the previous frame shape and no
    // longer means anything once the frame's aspect changes — reset to the
    // fresh cover-fit baseline FittedBox establishes for the new shape.
    _viewerController.value = Matrix4.identity();
    setState(() => _aspect = aspect);
  }

  Future<void> _confirm() async {
    setState(() => _exporting = true);
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Export at up to the source photo's own resolution so a tightly
      // zoomed crop doesn't come out blurrier than the original — capped
      // so a huge source photo can't blow up export time/memory.
      final targetWidth = (_decoded?.width ?? 1080).toDouble();
      final pixelRatio = (targetWidth / boundary.size.width).clamp(1.0, 4.0);
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      Navigator.of(context).pop(byteData!.buffer.asUint8List());
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final image = _decoded;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.cropTitle),
        actions: [
          TextButton(
            onPressed: (image == null || _exporting) ? null : _confirm,
            child: _exporting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    l10n.cropConfirm,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: image == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _frameRatioFor(image),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return ClipRect(
                            child: RepaintBoundary(
                              key: _boundaryKey,
                              child: InteractiveViewer(
                                transformationController: _viewerController,
                                boundaryMargin: EdgeInsets.zero,
                                minScale: 1,
                                maxScale: 4,
                                // Sized to exactly fill the frame, with the
                                // photo cover-fit inside via FittedBox —
                                // at identity transform (scale 1, no pan)
                                // this already covers the frame edge to
                                // edge, so InteractiveViewer needs no
                                // manually-computed initial matrix; pinch
                                // zoom only zooms in further from there.
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: image.width.toDouble(),
                                      height: image.height.toDouble(),
                                      child: Image.memory(widget.imageBytes),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AspectChip(
                        label: l10n.cropAspectOriginal,
                        selected: _aspect == _CropAspect.original,
                        onTap: () => _setAspect(_CropAspect.original),
                      ),
                      _AspectChip(
                        label: l10n.cropAspectSquare,
                        selected: _aspect == _CropAspect.square,
                        onTap: () => _setAspect(_CropAspect.square),
                      ),
                      _AspectChip(
                        label: l10n.cropAspectPortrait,
                        selected: _aspect == _CropAspect.portrait,
                        onTap: () => _setAspect(_CropAspect.portrait),
                      ),
                      _AspectChip(
                        label: l10n.cropAspectLandscape,
                        selected: _aspect == _CropAspect.landscape,
                        onTap: () => _setAspect(_CropAspect.landscape),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _AspectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AspectChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accentGold,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryNavy : Colors.white,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
