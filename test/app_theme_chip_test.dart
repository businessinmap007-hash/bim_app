import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The canvas's chips as the app's chip theme: a chosen chip is a solid gold pill with
/// bold navy text (no check mark); the rest take the surface colour, a hairline border
/// and muted text — light and dark each in their own base colours.
void main() {
  Future<void> pump(WidgetTester tester, ThemeData theme) => tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Row(children: [
              ChoiceChip(label: const Text('على'), selected: true, onSelected: (_) {}),
              ChoiceChip(label: const Text('اخر'), selected: false, onSelected: (_) {}),
            ]),
          ),
        ),
      );

  for (final (name, theme, surface, muted) in [
    ('light', AppTheme.light(), AppColors.lightSurface, AppColors.primaryNavy),
    ('dark', AppTheme.dark(), AppColors.darkSurface, Colors.white),
  ]) {
    testWidgets('chips follow the canvas in $name', (tester) async {
      await pump(tester, theme);

      final chips = tester.widgetList<RawChip>(find.byType(RawChip)).toList();
      final chosen = chips[0];
      final other = chips[1];

      expect(chosen.showCheckmark, isFalse, reason: 'the canvas marks the chosen chip by its fill alone');
      expect(theme.chipTheme.selectedColor, AppColors.accentGold);
      expect(theme.chipTheme.backgroundColor, surface);
      expect((theme.chipTheme.shape as RoundedRectangleBorder).borderRadius, BorderRadius.circular(18));
      expect(theme.chipTheme.padding, const EdgeInsets.symmetric(horizontal: 14, vertical: 9));

      final label = theme.chipTheme.labelStyle!;
      final colour = label.color! as WidgetStateColor;
      expect(colour.resolve({WidgetState.selected}), AppColors.primaryNavy);
      expect(colour.resolve({}), muted.withValues(alpha: 0.7));
      expect(label.fontSize, 15);
      expect(label.leadingDistribution, TextLeadingDistribution.even, reason: 'the label sits in the middle of the pill');
      expect(theme.chipTheme.secondaryLabelStyle!.fontWeight, FontWeight.w700);
      expect(chosen.selected, isTrue);
      expect(other.selected, isFalse);

      // The chosen chip has no border; the other one has the hairline.
      final side = theme.chipTheme.side! as WidgetStateBorderSide;
      expect(side.resolve({WidgetState.selected}), BorderSide.none);
      expect(side.resolve({})!.width, 1);
    });
  }
}
