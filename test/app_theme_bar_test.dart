import 'package:bim_app/app/theme/app_colors.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:bim_app/shared/widgets/app_bar_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// «اعلى الصفحة اللون الداكن والخط ابيض» and «زر نشط باللون الداكن والنص ذهبى … والوضع الداكن للعكس» — المالك، 2026-10-08.
void main() {
  test('the top of the page is dark navy with white ink in light, and stays dark in dark', () {
    final light = AppTheme.light().appBarTheme;
    final dark = AppTheme.dark().appBarTheme;

    expect(light.backgroundColor, AppColors.primaryNavy);
    expect(light.foregroundColor, Colors.white);
    expect(dark.backgroundColor, AppColors.darkBackground);
    expect(dark.foregroundColor, Colors.white);
  });

  test('the active control is navy with gold ink in light and the reverse in dark', () {
    final light = AppTheme.light().colorScheme;
    final dark = AppTheme.dark().colorScheme;

    expect(light.primary, AppColors.primaryNavy);
    expect(light.onPrimary, AppColors.accentGold);
    expect(dark.primary, AppColors.accentGold);
    expect(dark.onPrimary, AppColors.primaryNavy);
  });

  testWidgets('the chosen segment of a toggle follows the same rule', (tester) async {
    for (final (theme, fill, ink) in [
      (AppTheme.light(), AppColors.primaryNavy, AppColors.accentGold),
      (AppTheme.dark(), AppColors.accentGold, AppColors.primaryNavy),
    ]) {
      final style = theme.segmentedButtonTheme.style!;

      expect(style.backgroundColor!.resolve({WidgetState.selected}), fill);
      expect(style.foregroundColor!.resolve({WidgetState.selected}), ink);
    }
  });

  testWidgets('tabs on the dark top are gold and white, never navy on navy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('t'),
              bottom: const AppBarTabBar(tabs: [Tab(text: 'أ'), Tab(text: 'ب')]),
            ),
            body: const SizedBox(),
          ),
        ),
      ),
    );

    final bar = tester.widget<TabBar>(find.byType(TabBar));
    expect(bar.tabs.length, 2);
    final themed = Theme.of(tester.element(find.byType(TabBar))).tabBarTheme;
    expect(themed.labelColor, AppColors.accentGold);
    expect(themed.unselectedLabelColor, Colors.white.withValues(alpha: 0.7));
  });
}
