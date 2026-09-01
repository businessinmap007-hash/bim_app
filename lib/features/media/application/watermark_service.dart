import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Valid repeat counts for [WatermarkService.apply] — the owner picks how
/// dense the watermark grid is; anything else is rejected rather than
/// silently rounded to the nearest valid count.
const kWatermarkRepeatCounts = [4, 6, 8, 10];

/// Stamps a diagonal, repeating text watermark (a phone number or business
/// name) across a photo — the owner's proof-of-ownership mark, picked by
/// them, not a fixed corner logo. Pure `dart:ui` compositing: draw the
/// source image once, then the text N times over it, re-encode as PNG.
class WatermarkService {
  const WatermarkService();

  Future<Uint8List> apply({
    required Uint8List imageBytes,
    required String text,
    required int repeatCount,
    Color color = Colors.white,
    double opacity = 0.55,
  }) async {
    assert(kWatermarkRepeatCounts.contains(repeatCount));

    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final width = image.width.toDouble();
    final height = image.height.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    canvas.drawImage(image, Offset.zero, Paint());
    _paintWatermarkGrid(
      canvas: canvas,
      canvasSize: Size(width, height),
      text: text,
      repeatCount: repeatCount,
      color: color,
      opacity: opacity,
    );

    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(width.round(), height.round());
    final byteData = await outputImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _paintWatermarkGrid({
    required Canvas canvas,
    required Size canvasSize,
    required String text,
    required int repeatCount,
    required Color color,
    required double opacity,
  }) {
    // All four allowed counts are even, so a fixed 2-column grid always
    // divides evenly (2x2, 3x2, 4x2, 5x2) instead of guessing rows/cols
    // per count.
    const cols = 2;
    final rows = repeatCount ~/ cols;

    final fontSize = canvasSize.shortestSide / 14;
    final textStyle = TextStyle(
      color: color.withValues(alpha: opacity),
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      shadows: [Shadow(color: Colors.black.withValues(alpha: opacity * 0.6), blurRadius: 4)],
    );

    final cellWidth = canvasSize.width / cols;
    final cellHeight = canvasSize.height / rows;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final center = Offset(cellWidth * (col + 0.5), cellHeight * (row + 0.5));
        _paintRotatedText(canvas, text, textStyle, center);
      }
    }
  }

  void _paintRotatedText(Canvas canvas, String text, TextStyle style, Offset center) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    // The classic photo-watermark tilt.
    canvas.rotate(-0.5);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }
}
