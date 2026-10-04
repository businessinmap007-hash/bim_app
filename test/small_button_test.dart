import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/app/theme/app_button_styles.dart';
import 'package:bim_app/app/theme/app_theme.dart';

/// «زر متابعة محتاج يصغر كتير» — the small style is a fraction of the theme's full-size slab.
void main() {
  testWidgets('the small button is much shorter than the theme slab', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Column(
            children: [
              FilledButton(key: const Key('full'), onPressed: () {}, child: const Text('x')),
              FilledButton(key: const Key('small'), style: AppButtonStyles.small, onPressed: () {}, child: const Text('x')),
            ],
          ),
        ),
      ),
    );

    final full = tester.getSize(find.byKey(const Key('full')));
    final small = tester.getSize(find.byKey(const Key('small')));

    expect(small.height, lessThanOrEqualTo(38));
    expect(small.height, lessThan(full.height * 0.8));
    expect(small.width, lessThan(full.width));
  });
}
