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
}
