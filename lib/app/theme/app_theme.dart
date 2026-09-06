import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Registered in pubspec.yaml's `fonts:` section from a bundled asset — see
/// the note there for why this isn't google_fonts.
const _fontFamily = 'Cairo';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    // Navy is the brand's "ink" color — great contrast on the light cream
    // background, nearly invisible on the dark one. Every default-M3-themed
    // widget that derives its color from colorScheme.primary (TextButton,
    // etc.) inherited that navy in dark mode too, which is how "نسيت كلمة
    // المرور؟" ended up unreadable against the dark background. Gold reads
    // well on both, so it takes over as the interactive/primary color in
    // dark mode; explicit widget themes below (ElevatedButton) are
    // unaffected since they hardcode their own colors already.
    final interactive = isDark ? AppColors.accentGold : AppColors.primaryNavy;
    final onInteractive = isDark ? AppColors.primaryNavy : Colors.white;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: interactive,
      onPrimary: onInteractive,
      secondary: AppColors.accentGold,
      onSecondary: AppColors.primaryNavy,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? Colors.white : AppColors.primaryNavy,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      fontFamily: _fontFamily,
      textTheme: AppTextStyles.themed(
        isDark ? Colors.white : AppColors.primaryNavy,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        foregroundColor: isDark ? Colors.white : AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.titleMedium,
          elevation: 3,
          shadowColor: AppColors.primaryNavy.withValues(alpha: 0.35),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.accentGold
              : AppColors.primaryNavy,
          side: BorderSide(
            color: isDark ? AppColors.accentGold : AppColors.primaryNavy,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.accentGold
              : AppColors.primaryNavy,
        ),
      ),
      // No cardTheme before this meant every `Card()` in the app fell back
      // to Material 3's un-branded default — a faint 1dp shadow plus a
      // purple-ish `surfaceTint` overlay that has nothing to do with the
      // navy/gold brand. One themed default here reaches every existing
      // `Card` in the codebase without touching those files individually.
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: AppColors.primaryNavy.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        color: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.accentGold : AppColors.primaryNavy,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
