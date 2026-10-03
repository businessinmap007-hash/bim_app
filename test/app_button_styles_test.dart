import 'package:bim_app/app/theme/app_button_styles.dart';
import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The buy-button pair is defined once: gold slab + outlined partner, shape from the themes.
void main() {
  testWidgets('the buy pair: gold slab and a ring in the interactive colour, in light and dark', (tester) async {
    for (final (theme, ring) in [(AppTheme.light(), AppColors.primaryNavy), (AppTheme.dark(), AppColors.accentGold)]) {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context;
              return Scaffold(
                body: Row(children: [
                  OutlinedButton(onPressed: () {}, style: AppButtonStyles.buyOutline(context), child: const Text('أضف')),
                  FilledButton(onPressed: () {}, style: AppButtonStyles.buy, child: const Text('شراء')),
                ]),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle(); // MaterialApp animates between the two themes
      final buy = AppButtonStyles.buy;
      expect(buy.backgroundColor!.resolve({}), AppColors.accentGold);
      expect(buy.foregroundColor!.resolve({}), AppColors.primaryNavy);
      expect(buy.textStyle!.resolve({})!.fontSize, 14);
      expect(buy.textStyle!.resolve({})!.fontWeight, FontWeight.w700);
      expect(buy.shape, isNull, reason: 'the radius comes from the theme');

      final outline = AppButtonStyles.buyOutline(captured);
      expect(outline.side!.resolve({})!.width, 1.5);
      expect(outline.side!.resolve({})!.color, ring);
      expect(outline.shape, isNull);

      // Both render at least the canvas's 52.
      expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(52));
      expect(tester.getSize(find.byType(OutlinedButton)).height, greaterThanOrEqualTo(48));
    }
  });
}
