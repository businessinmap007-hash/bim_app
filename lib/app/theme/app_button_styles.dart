import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The buy-button pair — «شراء مباشر» (gold slab) and «أضف للسلة» (outlined) — the
/// canvas's bottom actions: 14 / bold, 14 vertical padding. The SHAPE (radius 12) comes
/// from the filled / outlined button themes in [AppTheme]; only what is specific to
/// these two lives here, so every cart-facing button is defined once and looks the
/// same on every screen.
class AppButtonStyles {
  const AppButtonStyles._();

  static const _label = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  /// The gold slab with navy ink — gold on the dark background AND on the light one,
  /// like the produce menu's buy button it replaces.
  static final ButtonStyle buy = FilledButton.styleFrom(
    backgroundColor: AppColors.accentGold,
    foregroundColor: AppColors.primaryNavy,
    textStyle: _label,
    padding: _padding,
  );

  /// A small button for a secondary action beside a title («متابعة»): the theme's full-size slab is
  /// meant for the page's primary action, not for a row of icons.
  static const ButtonStyle small = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(0, 34)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14, vertical: 4)),
    textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  /// The outlined partner: a 1.5 ring and text in the interactive colour — navy on
  /// light, gold on dark (the canvas's gold ring would vanish on the cream background).
  static ButtonStyle buyOutline(BuildContext context) {
    final colour = Theme.of(context).colorScheme.primary;
    return OutlinedButton.styleFrom(
      foregroundColor: colour,
      side: BorderSide(color: colour, width: 1.5),
      textStyle: _label,
      padding: _padding,
    );
  }
}
