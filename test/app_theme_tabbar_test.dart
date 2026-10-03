import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/app/theme/app_theme.dart';

/// The rule under a tab strip is the canvas hairline in both themes — never the colour
/// scheme's full-strength outline (a bright white line across the dark screens).
void main() {
  test('the tab strip divider is the hairline, not the full-strength outline', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      expect(theme.tabBarTheme.dividerColor, theme.dividerColor);
      expect(theme.tabBarTheme.dividerColor, isNot(theme.colorScheme.outlineVariant));
    }
  });
}
