import 'package:bim_app/features/business/data/models/menu_item_summary.dart';
import 'package:bim_app/features/business_menu/data/models/menu_item_image.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:bim_app/shared/widgets/cropped_network_image.dart';
import 'package:bim_app/shared/widgets/photo_source_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// «الصور المرفوعة تظهر على الكارت وعليها علامة الكاميرا/الجاليري، واختيار أى صورة وأى جزء منها» — المالك، 2026-10-06.
void main() {
  test('a crop is read from the server and defaults to the whole photo', () {
    expect(PhotoCrop.fromJson(null), PhotoCrop.whole);
    expect(PhotoCrop.fromJson({'x': 0.3, 'y': 0.7, 'zoom': 2.5}), const PhotoCrop(x: 0.3, y: 0.7, zoom: 2.5));
    expect(PhotoCrop.whole.isDefault, isTrue);
    expect(const PhotoCrop(zoom: 2).isDefault, isFalse);
  });

  test('an item image carries its source, cover flag and crop', () {
    final image = MenuItemImage.fromJson({
      'id': 4,
      'image': 'https://example.test/a.png',
      'source': 'camera',
      'is_cover': true,
      'crop': {'x': 0.2, 'y': 0.4, 'zoom': 3},
    });

    expect(image.isFromCamera, isTrue);
    expect(image.isCover, isTrue);
    expect(image.crop.zoom, 3);
  });

  MenuItemSummary summary() => MenuItemSummary.fromJson({
    'id': 1,
    'name': 'صنف',
    'base_price': 10,
    'image': 'https://example.test/second.png',
    'images': [
      {'id': 1, 'image': 'https://example.test/first.png', 'source': 'upload', 'is_cover': false, 'crop': {'x': 0.5, 'y': 0.5, 'zoom': 1}},
      {'id': 2, 'image': 'https://example.test/second.png', 'source': 'camera', 'is_cover': true, 'crop': {'x': 0.25, 'y': 0.75, 'zoom': 2}},
    ],
  });

  test('the card draws the chosen photo, its crop and its camera/gallery source', () {
    final item = summary();

    expect(item.cardPhoto?.id, 2);
    expect(item.cardCrop, const PhotoCrop(x: 0.25, y: 0.75, zoom: 2));
    expect(item.cardSource, 'camera');
  });

  test('the detail pager reads the crop and source of any photo by url', () {
    final item = summary();

    expect(item.sourceOf('https://example.test/first.png'), 'upload');
    expect(item.cropOf('https://example.test/first.png'), PhotoCrop.whole);
    expect(item.sourceOf('https://example.test/unknown.png'), isNull);
  });

  testWidgets('the badge says camera or gallery; the cropped image zooms only when asked', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        home: const Scaffold(
          body: Column(
            children: [
              PhotoSourceBadge(source: 'camera'),
              PhotoSourceBadge(source: 'upload'),
              SizedBox(width: 100, height: 100, child: CroppedNetworkImage(url: 'https://example.test/a.png')),
              SizedBox(width: 100, height: 100, child: CroppedNetworkImage(url: 'https://example.test/a.png', crop: PhotoCrop(zoom: 2))),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
    // only the zoomed one is wrapped in a scale transform inside a clip
    expect(find.descendant(of: find.byType(CroppedNetworkImage), matching: find.byType(Transform)), findsWidgets);
    expect(find.descendant(of: find.byType(ClipRect), matching: find.byType(Transform)), findsOneWidget);
  });

  testWidgets('zooming puts the chosen point in the middle of the box (clamped to the photo edges)', (tester) async {
    Future<Offset> where(PhotoCrop crop, Offset point) async {
      await tester.pumpWidget(
        MaterialApp(home: Center(child: SizedBox(width: 100, height: 100, child: CroppedNetworkImage(url: 'https://example.test/a.png', crop: crop)))),
      );
      final matrix = tester.widget<Transform>(find.descendant(of: find.byType(ClipRect), matching: find.byType(Transform))).transform;
      return MatrixUtils.transformPoint(matrix, point);
    }

    // the point (40, 60) of the box lands at the centre
    final centred = await where(const PhotoCrop(x: 0.4, y: 0.6, zoom: 2), const Offset(40, 60));
    expect(centred.dx, closeTo(50, 0.001));
    expect(centred.dy, closeTo(50, 0.001));

    // a point near the edge cannot be centred without showing blank: the window stops at the photo's edge
    final edge = await where(const PhotoCrop(x: 0.05, y: 0.5, zoom: 2), const Offset(0, 50));
    expect(edge.dx, closeTo(0, 0.001));
  });
}
