import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/media/presentation/screens/image_cropper_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:bim_app/shared/widgets/crop_grid.dart';
import 'package:bim_app/shared/widgets/profile_cover_header.dart';

/// «اضف تعديل صورة الغلاف لتناسب ابعاد الغلاف فى القص وضبط مركز الصورة» — المالك، 2026-10-06.
void main() {
  // a real 1x1 PNG — the cropper decodes what it is given
  final png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

  Widget app(Widget home) => MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: home,
  );

  testWidgets('the cover crop frames exactly the cover shape, with the guide grid and a centre button', (tester) async {
    await tester.pumpWidget(app(ImageCropperScreen(imageBytes: png, fixedAspect: kCoverAspect, title: 'ضبط صورة الغلاف')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    expect(find.text('ضبط صورة الغلاف'), findsOneWidget);
    expect(find.byType(CropGrid), findsOneWidget);
    expect(find.text('توسيط الصورة'), findsOneWidget);
    // no free choice of shape for a cover
    expect(find.byType(ChoiceChip), findsNothing);

    final frame = tester.getSize(find.byType(AspectRatio).first);
    expect(frame.width / frame.height, closeTo(kCoverAspect, 0.01));
  });

  testWidgets('a normal photo crop keeps its aspect chips and has no grid', (tester) async {
    await tester.pumpWidget(app(ImageCropperScreen(imageBytes: png)));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    expect(find.byType(ChoiceChip), findsWidgets);
    expect(find.byType(CropGrid), findsNothing);
  });

  testWidgets('the profile header draws the cover in the cover shape', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(const Scaffold(body: SingleChildScrollView(child: ProfileCoverHeader(coverImageUrl: null, avatarImageUrl: null, title: 'x')))));

    // the placeholder cover is sized by the same shape
    final cover = tester.getSize(find.descendant(of: find.byType(ProfileCoverHeader), matching: find.byType(DecoratedBox)).first);
    expect(cover.width, 500);
    expect(cover.width / cover.height, closeTo(kCoverAspect, 0.01));
  });
}
