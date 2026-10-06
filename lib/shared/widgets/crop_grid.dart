import 'package:flutter/material.dart';

/// The light guide grid laid over a photo while its framing is set — five lines across and five down, the middle line
/// each way in another colour so the exact centre is unmistakable. One widget for every crop screen (an item's photo, a
/// profile cover), so the guide looks and behaves the same everywhere. It ignores touches, so it can sit over the
/// thing being dragged.
class CropGrid extends StatelessWidget {
  const CropGrid({super.key});

  @override
  Widget build(BuildContext context) => const IgnorePointer(child: CustomPaint(size: Size.infinite, painter: _CropGridPainter()));
}

/// Five lines across and five down, evenly spaced: the third of each is the centre of the window.
class _CropGridPainter extends CustomPainter {
  const _CropGridPainter();

  static const lines = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 0.8;
    final shade = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    // the middle line each way — a different colour from the rest, so the exact centre is unmistakable
    final centreLine = Paint()
      ..color = const Color(0xFFFF2D55)
      ..strokeWidth = 1.5;

    for (var i = 1; i <= lines; i++) {
      final x = size.width * i / (lines + 1);
      final y = size.height * i / (lines + 1);
      final centre = i == (lines + 1) ~/ 2;
      if (centre) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), centreLine);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), centreLine);
        continue;
      }
      // a thin dark twin under each white line so the grid reads on a light photo too
      canvas.drawLine(Offset(x + 0.8, 0), Offset(x + 0.8, size.height), shade);
      canvas.drawLine(Offset(0, y + 0.8), Offset(size.width, y + 0.8), shade);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), light);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), light);
    }
  }

  @override
  bool shouldRepaint(covariant _CropGridPainter oldDelegate) => false;
}
