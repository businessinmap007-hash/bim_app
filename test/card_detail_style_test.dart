import 'package:bim_app/app/theme/app_text_styles.dart';
import 'package:bim_app/app/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// «كبر ووضح خط التفاصيل على الكارت» — the card's detail lines are 14, in the ink at 75%.
void main() {
  test('the card detail style is 14 and clearer than the old 12 hint grey, in both modes', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final style = AppTextStyles.cardDetail(theme);

      expect(style.fontSize, 14);
      expect(style.color, theme.colorScheme.onSurface.withValues(alpha: 0.75));
      expect(style.fontSize!, greaterThan(AppTextStyles.bodySmall.fontSize!));
    }
  });
}
