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

  /// The fill behind a product photo's stand-in (the emoji / icon shown when an item has
  /// no picture) on a CARD whose top is that image — always a touch different from the
  /// card's own body so the photo area reads as its own block. Light: a soft tint of the
  /// ink (a little darker than the white body). Dark: the card surface two shades darker
  /// («مكان الصورة اقل درجتين») — the white tint it used to get made it a greyer, LIGHTER
  /// block than the navy body, the opposite of the light theme's relation.
  static Color photoPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      final surface = theme.cardTheme.color ?? theme.colorScheme.surface;
      return Color.lerp(surface, Colors.black, 0.22)!;
    }
    return theme.colorScheme.onSurface.withValues(alpha: 0.08);
  }

  /// The big hero card (the wallet balance): the brand navy on light; on dark that navy is
  /// the same as the page, so the card takes the lifted navy to stay a card.
  static Color heroSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryNavyLight : primaryNavy;

  /// The brand mark's badge background — a subtle navy-to-navy-light
  /// diagonal gradient instead of a flat fill, used behind the pin logo.
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, primaryNavyLight],
  );
}
