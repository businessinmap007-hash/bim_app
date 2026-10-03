import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The canvas's primary button as the app's FilledButton theme: flat, 12-radius,
/// 16/24 padding, 16 bold — colours follow light/dark (navy/white, gold/navy).
void main() {
  Future<void> pump(WidgetTester tester, ThemeData theme) => tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: Center(child: FilledButton(onPressed: () {}, child: const Text('حفظ')))),
        ),
      );

  for (final (name, theme, fill, ink) in [
    ('light', AppTheme.light(), AppColors.primaryNavy, Colors.white),
    ('dark', AppTheme.dark(), AppColors.accentGold, AppColors.primaryNavy),
  ]) {
    testWidgets('FilledButton follows the canvas spec in $name', (tester) async {
      await pump(tester, theme);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style ?? const ButtonStyle();
      expect(style.shape, isNull, reason: 'shape comes from the theme, not the call site');

      final resolved = theme.filledButtonTheme.style!;
      final shape = resolved.shape!.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
      expect(resolved.padding!.resolve({}), const EdgeInsets.symmetric(horizontal: 24, vertical: 16));
      expect(resolved.textStyle!.resolve({})!.fontSize, 16);
      expect(resolved.textStyle!.resolve({})!.fontWeight, FontWeight.w700);
      expect(resolved.elevation!.resolve({}), 0);

      // Colours come from the scheme: the canvas gold/navy in dark, navy/white in light.
      expect(theme.colorScheme.primary, fill);
      expect(theme.colorScheme.onPrimary, ink);

      // A 16-pad button is ≥ 52 tall, like the canvas.
      expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(52));
    });
  }

  testWidgets('FilledButton.tonal keeps its tonal colours (the theme sets none)', (tester) async {
    final theme = AppTheme.light();
    expect(theme.filledButtonTheme.style!.backgroundColor, isNull);
    expect(theme.filledButtonTheme.style!.foregroundColor, isNull);
  });

  testWidgets('the elevated button follows the same light / dark colours (never navy on a dark card)', (tester) async {
    final light = AppTheme.light().elevatedButtonTheme.style!;
    final dark = AppTheme.dark().elevatedButtonTheme.style!;

    expect(light.backgroundColor!.resolve({}), AppColors.primaryNavy);
    expect(light.foregroundColor!.resolve({}), Colors.white);
    expect(dark.backgroundColor!.resolve({}), AppColors.accentGold);
    expect(dark.foregroundColor!.resolve({}), AppColors.primaryNavy);
  });
}
