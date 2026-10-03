import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 3 of the theme: dialogs, bottom sheets, snack bars and the small controls
/// (checkbox, radio, switch) — surface and ink follow light/dark, no Material-3 tint.
void main() {
  for (final (name, theme, surface, ink, interactive, onInteractive) in [
    ('light', AppTheme.light(), AppColors.lightSurface, AppColors.primaryNavy, AppColors.primaryNavy, Colors.white),
    ('dark', AppTheme.dark(), AppColors.darkSurface, Colors.white, AppColors.accentGold, AppColors.primaryNavy),
  ]) {
    testWidgets('a dialog is drawn on the surface colour, 16 round, untinted in $name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(title: Text('عنوان'), content: Text('نص')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final dialog = tester.widget<Material>(find.descendant(of: find.byType(AlertDialog), matching: find.byType(Material)).first);
      expect(dialog.color, surface);
      expect(dialog.surfaceTintColor, Colors.transparent);
      expect((dialog.shape! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(16));
      expect(theme.dialogTheme.titleTextStyle!.fontWeight, FontWeight.w700);
      expect(theme.dialogTheme.titleTextStyle!.color, ink);
    });

    testWidgets('a bottom sheet is on the surface colour with a 20 top radius in $name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet<void>(context: context, builder: (_) => const SizedBox(height: 120, child: Text('sheet'))),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final sheet = tester.widget<Material>(find.descendant(of: find.byType(BottomSheet), matching: find.byType(Material)).first);
      expect(sheet.color, surface);
      expect(sheet.surfaceTintColor, Colors.transparent);
      expect((sheet.shape! as RoundedRectangleBorder).borderRadius, const BorderRadius.vertical(top: Radius.circular(20)));
    });

    test('snack bar, checkbox, radio and switch themes in $name', () {
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.snackBarTheme.actionTextColor, AppColors.accentGold);
      expect(theme.snackBarTheme.contentTextStyle!.color, Colors.white);

      final box = theme.checkboxTheme;
      expect((box.shape! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(6));
      expect(box.fillColor!.resolve({WidgetState.selected}), AppColors.accentGold);
      expect(box.fillColor!.resolve({}), Colors.transparent);
      expect(box.checkColor!.resolve({WidgetState.selected}), AppColors.primaryNavy);
      final side = box.side! as WidgetStateBorderSide;
      expect(side.resolve({})!.width, 1.5);
      expect(side.resolve({WidgetState.selected}), BorderSide.none);

      expect(theme.radioTheme.fillColor!.resolve({WidgetState.selected}), interactive);
      expect(theme.radioTheme.fillColor!.resolve({}), ink.withValues(alpha: 0.4));

      expect(theme.switchTheme.trackColor!.resolve({WidgetState.selected}), interactive);
      expect(theme.switchTheme.thumbColor!.resolve({WidgetState.selected}), onInteractive);
    });
  }
}
