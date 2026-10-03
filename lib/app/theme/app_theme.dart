import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Registered in pubspec.yaml's `fonts:` section from a bundled asset — see
/// the note there for why this isn't google_fonts.
const _fontFamily = 'Cairo';

class AppTheme {
  const AppTheme._();

  static OutlineInputBorder _fieldBorder(Color colour, {double width = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: colour, width: width),
  );

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
    // The ink the muted / hairline tokens are drawn in, and the canvas's hairline itself.
    final muted = isDark ? Colors.white : AppColors.primaryNavy;
    final hairline = isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.primaryNavy.withValues(alpha: 0.18);
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.titleMedium,
          elevation: 3,
          shadowColor: AppColors.primaryNavy.withValues(alpha: 0.35),
        ),
      ),
      // The canvas's primary button («حفظ»، «شراء مباشر»): a flat 12-radius slab,
      // 16 vertical / 24 horizontal padding, Cairo 16 bold. The COLOURS are not set
      // here on purpose — they come from the colour scheme above, which already
      // follows light/dark (light: navy fill + white text, dark: gold fill + navy
      // text, exactly the canvas) and leaves FilledButton.tonal its own tonal colours.
      // A screen that needs the gold buy-button look keeps its own styleFrom.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          // The canvas slab is ~52+ tall whatever the font's own line height gives.
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      // The canvas's chips («المعالج»، «الرام»، أقسام المتجر): soft pills, 13 / 8×14, the
      // chosen one a solid gold slab with bold navy text, the rest the surface colour with a
      // hairline border and muted text — no check mark. Surface, border and muted text
      // follow light/dark (dark = the canvas's #11213B / white 14% / white 70%).
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedColor: AppColors.accentGold,
        disabledColor: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withValues(alpha: 0.5),
        surfaceTintColor: Colors.transparent,
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide.none
              : BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : AppColors.primaryNavy.withValues(alpha: 0.18),
                ),
        ),
        // The label COLOUR is the part that changes with the state, so it is a
        // WidgetStateColor inside a plain TextStyle (RawChip resolves the colour, not a
        // state-aware style). A ChoiceChip takes the bold secondaryLabelStyle when chosen.
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primaryNavy
                : (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.7),
          ),
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryNavy,
        ),
      ),
      // ── Phase 3: the surfaces and the small controls ──────────────────────────
      // The canvas draws no dialogs or sheets, so these take its tokens: the surface
      // colour (white / #11213B), the cards' 16 radius, Cairo type, and — the point of
      // the explicit themes — NO Material-3 surface tint (the purple-ish overlay the
      // card theme above already escapes).
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.primaryNavy.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.primaryNavy,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          height: 1.5,
          color: (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.85),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        modalBackgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        modalElevation: 8,
        shadowColor: AppColors.primaryNavy.withValues(alpha: 0.25),
        dragHandleColor: (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.25),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      // A floating pill in the brand's navy (dark: the lifted navy) with white text and a
      // gold action — readable on both backgrounds, never the grey Material default.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.primaryNavyLight : AppColors.primaryNavy,
        contentTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        actionTextColor: AppColors.accentGold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // The canvas's tick box: 6-radius, a 1.5 hairline when empty, solid GOLD with a navy
      // tick when ticked — in light and dark alike (the screens that already tick in gold
      // keep their look; navy ink on gold reads on both backgrounds).
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.2)
              : states.contains(WidgetState.selected)
              ? AppColors.accentGold
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(AppColors.primaryNavy),
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide.none
              : BorderSide(
                  width: 1.5,
                  color: (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.4),
                ),
        ),
      ),
      // The canvas's radio: a 1.5 muted ring, the chosen one in the interactive colour.
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.2)
              : states.contains(WidgetState.selected)
              ? interactive
              : (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? onInteractive
              : (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.55),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? interactive
              : (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.12),
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : (isDark ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.25),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      // The canvas's field: a surface-coloured box, 10 radius, a hairline border (dark:
      // white 14%, light: navy 18%), 12 × 12 inside; label / hint muted. Focus raises the
      // border to the interactive colour (navy light, gold dark) at 1.5.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: _fieldBorder(hairline),
        enabledBorder: _fieldBorder(hairline),
        disabledBorder: _fieldBorder(hairline.withValues(alpha: hairline.a * 0.5)),
        focusedBorder: _fieldBorder(interactive, width: 1.5),
        errorBorder: _fieldBorder(AppColors.error),
        focusedErrorBorder: _fieldBorder(AppColors.error, width: 1.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: TextStyle(fontFamily: _fontFamily, color: muted.withValues(alpha: 0.6)),
        floatingLabelStyle: TextStyle(fontFamily: _fontFamily, color: muted.withValues(alpha: 0.75)),
        hintStyle: TextStyle(fontFamily: _fontFamily, color: muted.withValues(alpha: 0.4)),
        helperStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12, color: muted.withValues(alpha: 0.55)),
        errorStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 12, color: AppColors.error),
        prefixIconColor: muted.withValues(alpha: 0.6),
        suffixIconColor: muted.withValues(alpha: 0.6),
      ),
      // The canvas's hairline between rows: navy 8% (dark: white 8%) — not the solid navy
      // line the colour scheme's outline would draw.
      dividerTheme: DividerThemeData(
        color: muted.withValues(alpha: 0.08),
        thickness: 1,
      ),
      // The canvas's row: title 15 / 600, subtitle 12 muted, 14 side padding, icons in the
      // interactive colour (navy light, gold dark).
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        iconColor: interactive,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: muted,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          color: muted.withValues(alpha: 0.55),
        ),
        leadingAndTrailingTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: muted,
        ),
      ),
    );
  }
}
