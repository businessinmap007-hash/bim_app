import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A product card's photo stand-in: a soft tint (a little darker than the body) in light, and
/// in dark the card's surface two shades DARKER — the same relation, never a lighter grey.
void main() {
  Future<Color> placeholder(WidgetTester tester, ThemeData theme) async {
    late Color colour;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            colour = AppColors.photoPlaceholder(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return colour;
  }

  testWidgets('dark: the surface two shades darker; light: the ink tint', (tester) async {
    final dark = await placeholder(tester, AppTheme.dark());
    expect(dark, Color.lerp(AppColors.darkSurface, Colors.black, 0.22));
    expect(dark.computeLuminance(), lessThan(AppColors.darkSurface.computeLuminance()), reason: 'darker than the card body, as light is');
    expect(await placeholder(tester, AppTheme.light()), AppColors.primaryNavy.withValues(alpha: 0.08));
  });
}
