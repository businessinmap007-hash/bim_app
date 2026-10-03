import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A product card's photo stand-in: a soft tint in light, the card's OWN surface in dark
/// — so the dark card is one colour, not a grey top over a navy body.
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

  testWidgets('dark: the card surface; light: the ink tint', (tester) async {
    expect(await placeholder(tester, AppTheme.dark()), AppColors.darkSurface);
    expect(await placeholder(tester, AppTheme.light()), AppColors.primaryNavy.withValues(alpha: 0.08));
  });
}
