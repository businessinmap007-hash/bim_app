import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/business_menu/presentation/widgets/product_watermark_choice.dart';
import 'package:bim_app/features/settings/application/watermark_settings_controller.dart';
import 'package:bim_app/features/settings/data/watermark_settings.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «إمكانية إضافة العلامة المائية كاختيار عند رفع صور المنتجات» — المالك، 2026-10-06.
void main() {
  test('the product switch defaults on and survives a save/load', () {
    expect(const WatermarkSettings().onProducts, isTrue);
    expect(WatermarkSettings.fromJson(const {}).onProducts, isTrue);

    final off = const WatermarkSettings(useMobile: true).copyWith(onProducts: false);
    expect(WatermarkSettings.fromJson(off.toJson()).onProducts, isFalse);
    expect(WatermarkSettings.fromJson(off.toJson()).useMobile, isTrue);
  });

  Widget app(List<Override> overrides) => ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: const Scaffold(body: ProductWatermarkChoice()),
    ),
  );

  testWidgets('with no watermark text set up it says so and offers the settings instead of a switch', (tester) async {
    await tester.pumpWidget(app([watermarkTextProvider.overrideWithValue(null)]));

    expect(find.byType(Switch), findsNothing);
    expect(find.text('تفعيلها من الإعدادات'), findsOneWidget);
  });

  testWidgets('with a watermark text the switch shows what is stamped and flips the saved choice', (tester) async {
    await tester.pumpWidget(app([watermarkTextProvider.overrideWithValue('0100 • فهيم')]));

    expect(find.byType(Switch), findsOneWidget);
    expect(find.textContaining('0100 • فهيم'), findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(find.byType(ProductWatermarkChoice)));
    expect(container.read(watermarkSettingsControllerProvider).onProducts, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(container.read(watermarkSettingsControllerProvider).onProducts, isFalse);
    expect(find.text('تُضاف الصور كما هي بلا علامة'), findsOneWidget);
  });
}
