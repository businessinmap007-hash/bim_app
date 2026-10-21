import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/business/data/models/menu_item_summary.dart';
import 'package:bim_app/features/promotions/data/models/promotion.dart';
import 'package:bim_app/features/promotions/application/promotions_providers.dart';
import 'package:bim_app/features/promotions/presentation/screens/promotion_form_screen.dart';
import 'package:bim_app/features/promotions/presentation/widgets/offer_widgets.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
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

void main() {
  test('a promotion reads its rule, targets and covered items', () {
    final p = Promotion.fromJson({
      'id': 4,
      'kind': 'n_for_price_of',
      'params': {'n': 3, 'pay': 1},
      'audience': 'new_customers',
      'max_uses': 50,
      'used_count': 5,
      'remaining_uses': 45,
      'is_active': true,
      'is_running': true,
      'targets': [
        {'type': 'menu_section', 'id': 7, 'name': 'Shirts'},
      ],
      'items': [
        {'type': 'menu_item', 'id': 9, 'name': 'Blue shirt', 'price': 100, 'price_after': null},
      ],
    });

    expect(p.forNewCustomers, isTrue);
    expect(p.param('n'), 3);
    expect(p.targets.single.name, 'Shirts');
    expect(p.items.single.priceAfter, isNull);
    expect(p.remainingUses, 45);
  });

  test('a menu row carries the best offer on it', () {
    final row = MenuItemSummary.fromJson({
      'id': 1,
      'name': 'Shirt',
      'base_price': 100,
      'offer': {'promotion_id': 3, 'kind': 'percent', 'params': {'value': 25}, 'price_after': 75},
    });

    expect(row.offer!.priceAfter, 75);
    expect(row.offer!.param('value'), 25);
    expect(MenuItemSummary.fromJson({'id': 2, 'name': 'Plain', 'base_price': 10}).offer, isNull);
  });

  testWidgets('the price shows struck with the new price and a badge; a bundle rule shows the badge only', (tester) async {
    await tester.pumpWidget(_wrap(const PriceWithOffer(label: '100', offer: ItemOffer(promotionId: 1, kind: 'percent', params: {'value': 25}, priceAfter: 75))));
    expect(find.text('75'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('25% off'), findsOneWidget);

    await tester.pumpWidget(_wrap(const PriceWithOffer(label: '100', offer: ItemOffer(promotionId: 2, kind: 'n_for_price_of', params: {'n': 3, 'pay': 1}))));
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Buy 1, get 3'), findsOneWidget);

    await tester.pumpWidget(_wrap(const PriceWithOffer(label: '100')));
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('«Buy … get …» is one way: the merchant types the two numbers and reads the sentence', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [promotionCatalogProvider.overrideWith((ref) async => const PromotionCatalog())],
        child: _wrap(const PromotionFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy … get …'));
    await tester.pumpAndSettle();
    expect(find.text('You pay for 2 and take 3; 1 are free'), findsOneWidget);

    await tester.tap(find.text('Buy 4, get 8'));
    await tester.pumpAndSettle();
    expect(find.text('You pay for 4 and take 8; 4 are free'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Get (pieces taken)'), '3');
    await tester.pumpAndSettle();
    expect(find.text('The second number must be larger than the first (up to 20 pieces).'), findsWidgets);
  });

  testWidgets('the kind of offer comes before the products, with a summary that follows the numbers', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [promotionCatalogProvider.overrideWith((ref) async => const PromotionCatalog())],
        child: _wrap(const PromotionFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('1. Kind of offer')).dy, lessThan(tester.getTopLeft(find.text('2. Choose the products')).dy));
    expect(find.text('Offer summary'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Discount %'), '25');
    await tester.pumpAndSettle();
    expect(find.text('25% off'), findsOneWidget);
    expect(find.text('Choose what the offer covers'), findsOneWidget);

    await tester.tap(find.text('All my products'));
    await tester.pumpAndSettle();
    expect(find.text('Covers all products'), findsOneWidget);
  });
}
