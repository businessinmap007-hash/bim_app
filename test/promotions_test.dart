import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/business/data/models/menu_item_summary.dart';
import 'package:bim_app/features/promotions/data/models/promotion.dart';
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
    expect(find.text('Buy 3, pay the dearest'), findsOneWidget);

    await tester.pumpWidget(_wrap(const PriceWithOffer(label: '100')));
    expect(find.text('100'), findsOneWidget);
  });
}
