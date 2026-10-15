import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The platform's own mark for a guarantee level: a struck metal coin with «BIM» raised on its face, like a sculpted
/// relief — a reeded edge, a bevelled rim, a ring of beads and the letters standing out with depth and a highlight.
/// Bronze, silver and gold coins; platinum cooler and brighter; diamond cut as a gem; elite in night blue and gold;
/// royal in purple under a crown.
///
/// Drawn, not an image: it stays sharp at any size and needs no asset per level. Small sizes drop the fine detail
/// (reeding, beads) so a coin at list size stays a clean disc with its letters.
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

class _Metal {
  /// the bright and the deep tone of the metal, and its shadow
  final Color light;
  final Color base;
  final Color deep;
  final Color shade;

  /// the letters: face top, face bottom
  final Color letterTop;
  final Color letterBottom;

  const _Metal({
    required this.light,
    required this.base,
    required this.deep,
    required this.shade,
    required this.letterTop,
    required this.letterBottom,
  });
}

const Map<String, _Metal> _metals = {
  'bronze': _Metal(light: Color(0xFFF3B98A), base: Color(0xFFCD7F32), deep: Color(0xFF8A4F1D), shade: Color(0xFF4E2A0B), letterTop: Color(0xFFFFD9B0), letterBottom: Color(0xFFB8692A)),
  'silver': _Metal(light: Color(0xFFFFFFFF), base: Color(0xFFC3C8D0), deep: Color(0xFF7F8794), shade: Color(0xFF3F4652), letterTop: Color(0xFFFFFFFF), letterBottom: Color(0xFFA9B0BB)),
  'gold': _Metal(light: Color(0xFFFFF1A8), base: Color(0xFFF2C230), deep: Color(0xFFB07F00), shade: Color(0xFF6B4A00), letterTop: Color(0xFFFFF6C2), letterBottom: Color(0xFFDDA514)),
  'platinum': _Metal(light: Color(0xFFFFFFFF), base: Color(0xFFD5E4EB), deep: Color(0xFF7E9CAA), shade: Color(0xFF3A5361), letterTop: Color(0xFFFFFFFF), letterBottom: Color(0xFFB4CAD4)),
  'diamond': _Metal(light: Color(0xFFEFFCFF), base: Color(0xFF7FD6F2), deep: Color(0xFF2A8DB3), shade: Color(0xFF0C4A66), letterTop: Color(0xFFFFFFFF), letterBottom: Color(0xFF63C3E3)),
  'elite': _Metal(light: Color(0xFFFFE9A6), base: Color(0xFFD4A84B), deep: Color(0xFF8C6A1F), shade: Color(0xFF4A3608), letterTop: Color(0xFFFFF0B8), letterBottom: Color(0xFFD9AC3F)),
  'royal': _Metal(light: Color(0xFFFFE9A6), base: Color(0xFFD4A84B), deep: Color(0xFF8C6A1F), shade: Color(0xFF4A3608), letterTop: Color(0xFFFFF0B8), letterBottom: Color(0xFFD9AC3F)),
};

/// The field (inside the rim) of the dark-faced levels.
const Map<String, List<Color>> _fields = {
  'elite': [Color(0xFF4F5890), Color(0xFF1A2043)],
  'royal': [Color(0xFFA25AD0), Color(0xFF4F1C73)],
};

const _Metal _fallbackMetal = _Metal(
  light: Color(0xFFF3F4F6),
  base: Color(0xFFB8BDC6),
  deep: Color(0xFF6B7280),
  shade: Color(0xFF374151),
  letterTop: Color(0xFFFFFFFF),
  letterBottom: Color(0xFF9CA3AF),
);

class BimCoinPainter extends CustomPainter {
  final String code;
  final String? fontFamily;

  const BimCoinPainter(this.code, {this.fontFamily});

  @override
  void paint(Canvas canvas, Size size) {
    final m = _metals[code] ?? _fallbackMetal;
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final gem = code == 'diamond';
    final fine = r >= 16; // reeding and beads only when they can be seen

    Path outline(double radius) {
      if (!gem) return Path()..addOval(Rect.fromCircle(center: c, radius: radius));
      final path = Path();
      for (var i = 0; i < 8; i++) {
        final a = -math.pi / 2 + i * math.pi / 4 + math.pi / 8;
        final pt = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      return path..close();
    }

    final bounds = Rect.fromCircle(center: c, radius: r);

    // the coin stands off the page: a soft shadow under it
    canvas.drawPath(
      outline(r * 0.94).shift(Offset(0, r * 0.07)),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06),
    );

    // the edge: the thickness of the coin, lit from the top-left
    canvas.drawPath(
      outline(r * 0.99),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(c.dx - r, c.dy - r),
          Offset(c.dx + r, c.dy + r),
          [m.light, m.deep, m.shade],
          [0.0, 0.55, 1.0],
        ),
    );

    // the reeded edge: fine radial ticks around the rim
    if (fine && !gem) {
      final tick = Paint()
        ..strokeWidth = math.max(r * 0.028, 0.5)
        ..strokeCap = StrokeCap.butt;
      const ticks = 72;
      for (var i = 0; i < ticks; i++) {
        final a = i * 2 * math.pi / ticks;
        final lit = math.cos(a + math.pi * 0.75) > 0; // the side facing the light
        tick.color = (lit ? Colors.white : m.shade).withValues(alpha: lit ? 0.5 : 0.45);
        canvas.drawLine(
          Offset(c.dx + r * 0.915 * math.cos(a), c.dy + r * 0.915 * math.sin(a)),
          Offset(c.dx + r * 0.985 * math.cos(a), c.dy + r * 0.985 * math.sin(a)),
          tick,
        );
      }
    }

    // the rim: a raised ring — bright on the lit side, dark on the other
    final rimOuter = r * 0.9;
    final rimInner = r * 0.8;
    final rim = Path.combine(PathOperation.difference, outline(rimOuter), outline(rimInner));
    canvas.drawPath(
      rim,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(c.dx - r * 0.7, c.dy - r * 0.7),
          Offset(c.dx + r * 0.7, c.dy + r * 0.7),
          [m.light, m.base, m.deep],
          [0.0, 0.45, 1.0],
        ),
    );
    // its two bevel edges
    canvas.drawPath(
      outline(rimOuter),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(r * 0.03, 0.6)
        ..shader = ui.Gradient.linear(
          Offset(c.dx - r, c.dy - r),
          Offset(c.dx + r, c.dy + r),
          [Colors.white.withValues(alpha: 0.85), m.shade.withValues(alpha: 0.7)],
        ),
    );
    canvas.drawPath(
      outline(rimInner),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(r * 0.03, 0.6)
        ..shader = ui.Gradient.linear(
          Offset(c.dx - r, c.dy - r),
          Offset(c.dx + r, c.dy + r),
          [m.shade.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0.8)],
        ),
    );

    // the field: slightly sunk inside the rim
    final fieldRadius = r * 0.78;
    final field = _fields[code];
    canvas.drawPath(
      outline(fieldRadius),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(c.dx - r * 0.25, c.dy - r * 0.3),
          r * 1.15,
          // a field darker than the letters, so the raised letters read at once
          field ?? [Color.lerp(m.base, m.light, 0.25)!, m.base, m.deep],
          field == null ? const [0.0, 0.5, 1.0] : const [0.0, 1.0],
        ),
    );

    // a ring of beads, as on a struck coin
    if (fine && !gem) {
      const beads = 36;
      final beadR = math.max(r * 0.022, 0.5);
      for (var i = 0; i < beads; i++) {
        final a = i * 2 * math.pi / beads;
        final p = Offset(c.dx + r * 0.7 * math.cos(a), c.dy + r * 0.7 * math.sin(a));
        canvas.drawCircle(p.translate(beadR * 0.35, beadR * 0.45), beadR, Paint()..color = m.shade.withValues(alpha: 0.55));
        canvas.drawCircle(p, beadR, Paint()..color = code == 'elite' || code == 'royal' ? m.base : m.light);
      }
    }

    // the facets of a gem
    if (gem) {
      final facet = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = math.max(r * 0.03, 0.5)
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < 4; i++) {
        final a = -math.pi / 2 + i * math.pi / 4 + math.pi / 8;
        canvas.drawLine(
          Offset(c.dx + fieldRadius * math.cos(a), c.dy + fieldRadius * math.sin(a)),
          Offset(c.dx - fieldRadius * math.cos(a), c.dy - fieldRadius * math.sin(a)),
          facet,
        );
      }
    }

    // royal: a crown, raised like the letters, above them
    var textCenterY = c.dy;
    if (code == 'royal') {
      final crown = Path()
        ..moveTo(c.dx - r * 0.26, c.dy - r * 0.2)
        ..lineTo(c.dx - r * 0.3, c.dy - r * 0.5)
        ..lineTo(c.dx - r * 0.12, c.dy - r * 0.36)
        ..lineTo(c.dx, c.dy - r * 0.56)
        ..lineTo(c.dx + r * 0.12, c.dy - r * 0.36)
        ..lineTo(c.dx + r * 0.3, c.dy - r * 0.5)
        ..lineTo(c.dx + r * 0.26, c.dy - r * 0.2)
        ..close();
      canvas.drawPath(crown.shift(Offset(r * 0.03, r * 0.04)), Paint()..color = m.shade.withValues(alpha: 0.8));
      canvas.drawPath(
        crown,
        Paint()
          ..shader = ui.Gradient.linear(Offset(c.dx, c.dy - r * 0.56), Offset(c.dx, c.dy - r * 0.2), [m.letterTop, m.letterBottom]),
      );
      textCenterY = c.dy + r * 0.18;
    }

    // «BIM» raised from the field: depth below it, then the lit face with its metal gradient, then a highlight
    final fontSize = r * (code == 'royal' ? 0.5 : 0.62);
    TextPainter layer(Paint paint) => TextPainter(
      text: TextSpan(
        text: 'BIM',
        style: TextStyle(
          foreground: paint,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: fontSize * 0.06,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final probe = layer(Paint());
    final origin = Offset(c.dx - probe.width / 2, textCenterY - probe.height / 2);
    final depth = math.max(r * 0.045, 0.7);

    // a soft contact shadow on the field
    layer(Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, depth * 1.4))
        .paint(canvas, origin.translate(depth * 1.1, depth * 1.5));

    // At a small size the light letters melt into a light field: they go dark and engraved there (a bright lip
    // below them), so the name stays readable beside a line of text.
    final darkLetters = !fine && code != 'elite' && code != 'royal';

    if (darkLetters) {
      layer(Paint()..color = Colors.white.withValues(alpha: 0.85)).paint(canvas, origin.translate(depth * 0.7, depth * 0.9));
      layer(Paint()
        ..shader = ui.Gradient.linear(origin, origin.translate(0, probe.height), [m.deep, m.shade]))
          .paint(canvas, origin);
    } else {
      // the sides of the letters: stacked copies stepping away from the light
      final steps = fine ? 4 : 2;
      for (var i = steps; i >= 1; i--) {
        layer(Paint()..color = Color.lerp(m.deep, m.shade, i / steps)!)
            .paint(canvas, origin.translate(depth * i / steps * 0.8, depth * i / steps));
      }

      // the lit face
      layer(Paint()
        ..shader = ui.Gradient.linear(
          origin,
          origin.translate(probe.width * 0.35, probe.height),
          [m.letterTop, m.letterBottom],
        ))
          .paint(canvas, origin);
    }

    // a thin bright edge on the side that faces the light
    if (fine) {
      layer(Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(r * 0.016, 0.4)
        ..color = Colors.white.withValues(alpha: 0.65))
          .paint(canvas, origin.translate(-depth * 0.2, -depth * 0.25));
    }

    // a sheen across the whole coin, clipped to it
    canvas.save();
    canvas.clipPath(outline(rimOuter));
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(c.dx - r, c.dy - r),
          Offset(c.dx + r * 0.2, c.dy + r * 0.2),
          [Colors.white.withValues(alpha: code == 'elite' || code == 'royal' ? 0.18 : 0.34), Colors.white.withValues(alpha: 0.0)],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BimCoinPainter old) => old.code != code || old.fontFamily != fontFamily;
}
