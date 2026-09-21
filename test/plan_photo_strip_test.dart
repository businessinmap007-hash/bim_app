import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/training/data/models/training_plan.dart';
import 'package:bim_app/features/training/presentation/widgets/plan_photo_strip.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: child),
);

List<PlanImage> _images(int n) => [
  for (var i = 1; i <= n; i++) PlanImage(id: i, url: 'http://localhost/plan-photos/$i?signature=x'),
];

void main() {
  testWidgets('shows the add tile and the privacy note', (tester) async {
    await tester.pumpWidget(_app(PlanPhotoStrip(images: const [], onAdd: (_) async {}, onRemove: (_) async {})));

    expect(find.text('Add photo'), findsOneWidget);
    expect(find.text('Photos are visible only to you and your client.'), findsOneWidget);
  });

  testWidgets('the add tile disappears at the server limit', (tester) async {
    await tester.pumpWidget(
      _app(PlanPhotoStrip(images: _images(PlanPhotoStrip.maxPhotos), onAdd: (_) async {}, onRemove: (_) async {})),
    );

    expect(find.text('Add photo'), findsNothing);
    expect(find.byIcon(Icons.close), findsNWidgets(PlanPhotoStrip.maxPhotos));
  });

  testWidgets('deleting a photo asks first, then reports its id', (tester) async {
    final removed = <int>[];
    await tester.pumpWidget(
      _app(
        PlanPhotoStrip(
          images: _images(2),
          onAdd: (_) async {},
          onRemove: (id) async => removed.add(id),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    expect(removed, isEmpty, reason: 'nothing is deleted before the user confirms');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(removed, isEmpty);

    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(removed, [2]);
  });
}
