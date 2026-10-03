import 'package:bim_app/features/business/data/models/menu_item_summary.dart';
import 'package:bim_app/features/business/presentation/widgets/menu_item_grid_card.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// «الكارت طويل جدا قصره بحيث الصفحة تاخد كارتين ونص» — the customer's grid cell is the
/// photo (1.8 wide) plus exactly the text the card lays out. The worst content must fit
/// that cell (no overflow), and the cell must be well under the old 1/0.62-wide one.
void main() {
  const long = 'غرفة نوم — ألترا كلاسيك — زان — أبلاكاش — لون جوزي غامق مع تفاصيل كثيرة جدا';

  MenuItemSummary item({bool stepper = false}) => MenuItemSummary(
        id: 1,
        name: 'اسم منتج طويل جدا يتجاوز سطرا واحدا بالتأكيد',
        description: '',
        offeringLabel: long,
        imageUrls: const [],
        basePrice: 40000,
        saleUnitLabel: stepper ? 'كيلو' : null,
        availableQuantity: 6,
        variants: const [],
        extras: const [],
        brandName: 'ماركة طويلة الاسم',
        cardSummary: long,
      );

  for (final width in [140.0, 184.0, 260.0]) {
    for (final stepper in [false, true]) {
      testWidgets('the worst card fits its cell at width $width${stepper ? ' with the stepper' : ''}', (tester) async {
        final extent = MenuItemGridCard.extentFor(
          width,
          imageAspect: 1.8,
          detailLines: 2,
          hasBrand: true,
          hasStepper: stepper,
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  height: extent,
                  child: MenuItemGridCard(
                    item: item(stepper: stepper),
                    imageAspect: 1.8,
                    onDirectAdd: stepper ? (_) async {} : null,
                  ),
                ),
              ),
            ),
          ),
        );

        // Only a BOTTOM overflow says the cell is too short. A sideways one is the test
        // font (every glyph a full em wide), not the real Cairo — ignored here.
        final error = tester.takeException()?.toString() ?? '';
        expect(error.contains('bottom'), isFalse, reason: error);
      });
    }
  }

  test('the cell is much shorter than the old 1 / 0.62 one', () {
    const width = 184.0;
    final old = width / 0.62 + 24 + 2 * 34;
    final now = MenuItemGridCard.extentFor(width, imageAspect: 1.8, caption: true, detailLines: 2);

    expect(now, lessThan(old * 0.92));
  });
}
