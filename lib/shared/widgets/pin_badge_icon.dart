import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A gold, pin-shaped badge with a white icon centered in its head — the
/// app's own icon language (same silhouette as the launcher mark) instead of
/// a grab-bag of mismatched third-party category art. Pure vector
/// (CustomPainter), so it stays crisp at any size and needs no asset file.
class PinBadgeIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const PinBadgeIcon({
    super.key,
    required this.icon,
    this.size = 48,
    this.color = AppColors.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.18,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 1.18),
            painter: _PinPainter(color: color),
          ),
          Padding(
            padding: EdgeInsets.only(top: size * 0.16),
            child: Icon(icon, color: Colors.white, size: size * 0.42),
          ),
        ],
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  const _PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = size.width / 2;
    final headCenter = Offset(r, r);

    final path = Path()
      ..addOval(Rect.fromCircle(center: headCenter, radius: r))
      ..moveTo(r - r * 0.88, r + r * 0.45)
      ..lineTo(r + r * 0.88, r + r * 0.45)
      ..lineTo(r, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) => oldDelegate.color != color;
}
