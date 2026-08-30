import 'package:flutter/material.dart';

/// The app's explicit type scale — every size/weight in the app comes from
/// here, not from Material's own defaults or a one-off `TextStyle` on a
/// screen. Keeps every "title", "body", "caption" the same size everywhere.
///
/// `onColor` is applied per-brightness by [AppTextStyles.themed]; these
/// factories only fix size/weight/height.
class AppTextStyles {
  const AppTextStyles._();

  static const _family = 'Cairo';

  static const displayLarge = TextStyle(
    fontFamily: _family,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const headlineLarge = TextStyle(
    fontFamily: _family,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const headlineMedium = TextStyle(
    fontFamily: _family,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const titleLarge = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static const titleMedium = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const titleSmall = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const bodyLarge = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const labelLarge = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const labelMedium = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const labelSmall = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Builds a full [TextTheme] with every slot colored for the given
  /// brightness's default text color — individual widgets still override
  /// color when they need a specific token (error, accent, etc.).
  static TextTheme themed(Color color) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: color),
      headlineLarge: headlineLarge.copyWith(color: color),
      headlineMedium: headlineMedium.copyWith(color: color),
      titleLarge: titleLarge.copyWith(color: color),
      titleMedium: titleMedium.copyWith(color: color),
      titleSmall: titleSmall.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      bodySmall: bodySmall.copyWith(color: color),
      labelLarge: labelLarge.copyWith(color: color),
      labelMedium: labelMedium.copyWith(color: color),
      labelSmall: labelSmall.copyWith(color: color),
    );
  }
}
