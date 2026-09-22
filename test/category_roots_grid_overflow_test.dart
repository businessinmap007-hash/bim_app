import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/categories/application/categories_providers.dart';
import 'package:bim_app/features/categories/presentation/widgets/category_roots_grid.dart';
import 'package:bim_app/l10n/app_localizations.dart';

void main() {
  /// This is exactly how `IconRowCategoriesLayout` hosts it — a fixed 96px
  /// strip, the very first thing rendered on the Categories tab. The error
  /// state used to be a full-size icon+message+button column sized for a
  /// whole screen, which overflowed this strip the moment the first
  /// post-login request lost the race and came back an error.
  Widget hostedAtRowHeight(Widget child) => ProviderScope(
    overrides: [
      categoryRootsProvider.overrideWith((ref) async => throw Exception('network error')),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SizedBox(height: 96, child: child),
      ),
    ),
  );

  testWidgets('an error fits the fixed row height with no overflow, and offers a retry', (tester) async {
    await tester.pumpWidget(hostedAtRowHeight(const CategoryRootsGrid()));
    await tester.pumpAndSettle();

    // No RenderFlex overflow (or any other) exception was thrown while laying
    // this out — this is what would have failed before the fix.
    expect(tester.takeException(), isNull);

    expect(find.text('Something went wrong, please try again.'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('tapping retry re-fetches the roots', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRootsProvider.overrideWith((ref) async {
            calls++;
            throw Exception('still down');
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: SizedBox(height: 96, child: CategoryRootsGrid())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(calls, 1);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });
}
