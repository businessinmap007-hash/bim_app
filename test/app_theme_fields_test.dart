import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 5 of the theme: the canvas's text field, hairline divider and list row —
/// each in light and dark's own base colours.
void main() {
  for (final (name, theme, surface, ink, hairline, focus) in [
    ('light', AppTheme.light(), AppColors.lightSurface, AppColors.primaryNavy, AppColors.primaryNavy.withValues(alpha: 0.18), AppColors.primaryNavy),
    ('dark', AppTheme.dark(), AppColors.darkSurface, Colors.white, Colors.white.withValues(alpha: 0.14), AppColors.accentGold),
  ]) {
    test('the text field follows the canvas in $name', () {
      final t = theme.inputDecorationTheme;
      expect(t.filled, isTrue);
      expect(t.fillColor, surface);

      OutlineInputBorder border(InputBorder? b) => b! as OutlineInputBorder;
      expect(border(t.enabledBorder).borderRadius, BorderRadius.circular(10));
      expect(border(t.enabledBorder).borderSide.color, hairline);
      expect(border(t.enabledBorder).borderSide.width, 1);
      expect(border(t.focusedBorder).borderSide.color, focus);
      expect(border(t.focusedBorder).borderSide.width, 1.5);
      expect(border(t.errorBorder).borderSide.color, AppColors.error);
      expect(t.contentPadding, const EdgeInsets.symmetric(horizontal: 12, vertical: 12));
      expect(t.hintStyle!.color, ink.withValues(alpha: 0.4));
    });

    test('the divider is the canvas hairline and the list row its 15/600 title in $name', () {
      expect(theme.dividerTheme.color, ink.withValues(alpha: 0.08));
      expect(theme.dividerColor, hairline, reason: 'the legacy theme.dividerColor borders are the canvas hairline');
      expect(theme.dividerTheme.thickness, 1);

      final tile = theme.listTileTheme;
      expect(tile.titleTextStyle!.fontSize, 15);
      expect(tile.titleTextStyle!.fontWeight, FontWeight.w600);
      expect(tile.titleTextStyle!.color, ink);
      expect(tile.subtitleTextStyle!.fontSize, 12);
      expect(tile.subtitleTextStyle!.color, ink.withValues(alpha: 0.55));
      expect(tile.contentPadding, const EdgeInsets.symmetric(horizontal: 14));
      expect(tile.iconColor, theme.colorScheme.primary);
    });
  }

  testWidgets('a TextField and a ListTile render on the new themes without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Column(children: [
            Padding(padding: EdgeInsets.all(16), child: TextField(decoration: InputDecoration(labelText: 'الاسم'))),
            Divider(),
            ListTile(title: Text('عنوان'), subtitle: Text('وصف'), leading: Icon(Icons.person), trailing: Icon(Icons.chevron_right)),
          ]),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(TextField)).height, greaterThanOrEqualTo(48));
  });
}
