import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The platform's own mark for a guarantee level: a coin with «BIM» on it, in the metal of the level —
/// bronze, silver and gold coins; platinum with a second rim; diamond cut as a gem; elite in night blue and gold;
/// royal in purple under a crown.
///
/// Drawn, not an image: it stays sharp at any size and needs no asset per level.
class BimCoin extends StatelessWidget {
  final String code;
  final double size;

  /// The face of the letters; null = the app's own. (The preview tool names one.)
  final String? fontFamily;

  const BimCoin({super.key, required this.code, this.size = 22, this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: BimCoinPainter(code, fontFamily: fontFamily)),
    );
  }
}

class _Palette {
  final Color rim;
  final Color edge;
  final Color faceLight;
  final Color faceDark;
  final Color ink;

  const _Palette({required this.rim, required this.edge, required this.faceLight, required this.faceDark, required this.ink});
}

const Map<String, _Palette> _palettes = {
  'bronze': _Palette(rim: Color(0xFFB87333), edge: Color(0xFF7A4A1E), faceLight: Color(0xFFF0B27A), faceDark: Color(0xFFCD7F32), ink: Color(0xFF5A3410)),
  'silver': _Palette(rim: Color(0xFFB8BEC8), edge: Color(0xFF6E7684), faceLight: Color(0xFFFFFFFF), faceDark: Color(0xFFC7CCD4), ink: Color(0xFF4A515E)),
  'gold': _Palette(rim: Color(0xFFE0A91B), edge: Color(0xFF9C7000), faceLight: Color(0xFFFFEE9A), faceDark: Color(0xFFF2C230), ink: Color(0xFF7A5600)),
  'platinum': _Palette(rim: Color(0xFF9FB8C4), edge: Color(0xFF5E7C8A), faceLight: Color(0xFFFFFFFF), faceDark: Color(0xFFD7E6EC), ink: Color(0xFF3F5967)),
  'diamond': _Palette(rim: Color(0xFF3FB4E0), edge: Color(0xFF1B6F94), faceLight: Color(0xFFE6FAFF), faceDark: Color(0xFF8ADCF5), ink: Color(0xFF0E5675)),
  'elite': _Palette(rim: Color(0xFFD4A84B), edge: Color(0xFF8C6A1F), faceLight: Color(0xFF4A5282), faceDark: Color(0xFF1E2447), ink: Color(0xFFF2CF7A)),
  'royal': _Palette(rim: Color(0xFFD4A84B), edge: Color(0xFF8C6A1F), faceLight: Color(0xFF9A52C7), faceDark: Color(0xFF55207A), ink: Color(0xFFFFE08A)),
};

const _Palette _fallback = _Palette(
  rim: Color(0xFF9AA3AF),
  edge: Color(0xFF5B6470),
  faceLight: Color(0xFFF3F4F6),
  faceDark: Color(0xFFD1D5DB),
  ink: Color(0xFF374151),
);

class BimCoinPainter extends CustomPainter {
  final String code;
  final String? fontFamily;

  const BimCoinPainter(this.code, {this.fontFamily});

  @override
  void paint(Canvas canvas, Size size) {
    final p = _palettes[code] ?? _fallback;
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final gem = code == 'diamond';

    Path outline(double radius) {
      if (!gem) return Path()..addOval(Rect.fromCircle(center: c, radius: radius));
      // a cut gem: an octagon with its corners pointing up/down/left/right and diagonally
      final path = Path();
      for (var i = 0; i < 8; i++) {
        final a = -math.pi / 2 + i * math.pi / 4 + math.pi / 8;
        final pt = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      return path..close();
    }

    // the thickness of the coin: a soft shadow under it
    canvas.drawPath(
      outline(r * 0.96).shift(Offset(0, r * 0.06)),
      Paint()..color = const Color(0x33000000),
    );

    // rim
    canvas.drawPath(
      outline(r * 0.98),
      Paint()
        ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.rim, p.edge])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // platinum wears a second, finer rim
    if (code == 'platinum') {
      canvas.drawPath(
        outline(r * 0.88),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.05
          ..color = Colors.white.withValues(alpha: 0.8),
      );
    }

    // face
    final faceRadius = r * (code == 'platinum' ? 0.8 : 0.78);
    canvas.drawPath(
      outline(faceRadius),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.0,
          colors: [p.faceLight, p.faceDark],
        ).createShader(Rect.fromCircle(center: c, radius: faceRadius)),
    );

    // facets of a gem
    if (gem) {
      final facet = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = r * 0.035
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < 4; i++) {
        final a = -math.pi / 2 + i * math.pi / 4 + math.pi / 8;
        canvas.drawLine(
          Offset(c.dx + faceRadius * math.cos(a), c.dy + faceRadius * math.sin(a)),
          Offset(c.dx - faceRadius * math.cos(a), c.dy - faceRadius * math.sin(a)),
          facet,
        );
      }
    }

    // elite: a ring of small studs around the face
    if (code == 'elite') {
      final stud = Paint()..color = p.ink.withValues(alpha: 0.9);
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6;
        canvas.drawCircle(Offset(c.dx + r * 0.66 * math.cos(a), c.dy + r * 0.66 * math.sin(a)), r * 0.035, stud);
      }
    }

    // specular highlight
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: faceRadius * 0.82),
      math.pi * 1.05,
      math.pi * 0.42,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.07
        ..color = Colors.white.withValues(alpha: code == 'elite' || code == 'royal' ? 0.22 : 0.55),
    );

    // royal: a small crown above the name
    var textCenterY = c.dy;
    if (code == 'royal') {
      final crown = Path()
        ..moveTo(c.dx - r * 0.28, c.dy - r * 0.2)
        ..lineTo(c.dx - r * 0.3, c.dy - r * 0.52)
        ..lineTo(c.dx - r * 0.12, c.dy - r * 0.38)
        ..lineTo(c.dx, c.dy - r * 0.58)
        ..lineTo(c.dx + r * 0.12, c.dy - r * 0.38)
        ..lineTo(c.dx + r * 0.3, c.dy - r * 0.52)
        ..lineTo(c.dx + r * 0.28, c.dy - r * 0.2)
        ..close();
      canvas.drawPath(crown, Paint()..color = p.ink);
      textCenterY = c.dy + r * 0.18;
    }

    // the name on the coin
    final fontSize = r * (code == 'royal' ? 0.54 : code == 'elite' ? 0.58 : 0.68);
    final text = TextPainter(
      text: TextSpan(
        text: 'BIM',
        style: TextStyle(
          color: p.ink,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: fontSize * 0.04,
          height: 1,
          shadows: code == 'elite' || code == 'royal'
              ? null
              : [Shadow(color: Colors.white.withValues(alpha: 0.6), offset: Offset(0, r * 0.03))],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(c.dx - text.width / 2, textCenterY - text.height / 2));
  }

  @override
  bool shouldRepaint(covariant BimCoinPainter old) => old.code != code || old.fontFamily != fontFamily;
}
