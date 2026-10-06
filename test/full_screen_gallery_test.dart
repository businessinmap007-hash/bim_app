import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/l10n/app_localizations.dart';
import 'package:bim_app/shared/widgets/full_screen_gallery.dart';
import 'package:bim_app/shared/widgets/photo_source_badge.dart';

/// «في العارض تظهر أيضًا علامة الجاليري أو الكاميرا، والعرض 80% من ارتفاع الشاشة و20% مقسمة أعلى وأسفل» — المالك، 2026-10-06.
void main() {
  Widget app(Widget home) => MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: home,
  );

  testWidgets('the viewer says where each photo came from and swaps it with the page', (tester) async {
    await tester.pumpWidget(
      app(
        const FullScreenGallery(
          urls: ['https://example.test/a.png', 'https://example.test/b.png'],
          sources: ['camera', 'upload'],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.byType(PhotoSourceBadge), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(600, 0), 2000);
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
  });

  testWidgets('the photo takes eight tenths of the height, a tenth above and a tenth below', (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(const FullScreenGallery(urls: ['https://example.test/a.png', 'https://example.test/b.png'])));
    await tester.pump();

    final page = tester.getSize(find.byType(PageView)).height;
    final safe = tester.getSize(find.byType(SafeArea)).height;

    expect(page / safe, closeTo(0.8, 0.001));
  });

  testWidgets('a single photo has no counter and no thumbnail strip, and no badge when the source is unknown', (tester) async {
    await tester.pumpWidget(app(const FullScreenGallery(urls: ['https://example.test/a.png'])));
    await tester.pump();

    expect(find.textContaining('/'), findsNothing);
    expect(find.byType(PhotoSourceBadge), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });
}
