import 'package:flutter/material.dart';

/// Brand identity per business-in-map-roadmap.md §5: navy pin-map logo,
/// gold accent. Kept as a single source of truth so no screen hardcodes a
/// hex value directly.
class AppColors {
  const AppColors._();

  static const primaryNavy = Color(0xFF0B1F3A);
  static const primaryNavyLight = Color(0xFF16305A);
  static const accentGold = Color(0xFFD6A94A);

  static const success = Color(0xFF2E9E5B);
  static const error = Color(0xFFE0563D);
  static const warning = Color(0xFFE0A93D);

  static const lightBackground = Color(0xFFFAF9F6);
  static const lightSurface = Color(0xFFFFFFFF);

  // Not pure black — deliberate per the brand note (dark navy, not #000).
  static const darkBackground = Color(0xFF0A1526);
  static const darkSurface = Color(0xFF11213B);

  /// A soft, brand-tinted shadow (navy, not pure black) for anything drawn
  /// with a raw `Container`/`BoxDecoration` rather than `Card` — flat cards
  /// with a hairline border and no depth were the single biggest "looks
  /// unfinished" tell across the app, so this is the one place every such
  /// widget should reach for instead of inventing its own shadow value.
  static List<BoxShadow> softShadow({double opacity = 0.08}) => [
    BoxShadow(
      color: primaryNavy.withValues(alpha: opacity),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  /// The brand mark's badge background — a subtle navy-to-navy-light
  /// diagonal gradient instead of a flat fill, used behind the pin logo.
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, primaryNavyLight],
  );
}
