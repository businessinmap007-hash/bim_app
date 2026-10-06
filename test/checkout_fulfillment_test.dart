import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/addresses/application/addresses_providers.dart';
import 'package:bim_app/features/addresses/data/addresses_api.dart';
import 'package:bim_app/features/addresses/data/models/address.dart';
import 'package:bim_app/features/business/application/business_page_providers.dart';
import 'package:bim_app/features/business/data/business_page_api.dart';
import 'package:bim_app/features/business/data/models/business_profile.dart';
import 'package:bim_app/features/cart/data/models/cart_models.dart';
import 'package:bim_app/features/cart/presentation/screens/checkout_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:bim_app/shared/widgets/scrolling_chip_row.dart';

/// «طرق الاستلام عند إتمام الطلب» — checkout offers exactly what the store ticked in its profile, as it stands now;
/// a store that has not answered cannot be ordered from; and choices wider than the screen scroll sideways.
class _FakePageApi implements BusinessPageApi {
  List<Map<String, dynamic>> methods;
  int reads = 0;
  _FakePageApi(this.methods);

  @override
  Future<BusinessProfile> profile(int businessId) async {
    reads++;
    return BusinessProfile.fromJson({
      'id': businessId,
      'name': 'Shop',
      'fulfillment': {'methods': methods, 'dine_in': false},
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressesApi implements AddressesApi {
  @override
  Future<List<Address>> list() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _method(int id, String ar, String type) => {
  'id': id,
  'name_ar': ar,
  'name_en': ar,
  'type': type,
};

Cart _cart() => Cart.fromJson({
  'id': 1,
  'status': 'cart',
  'business': {'id': 7, 'name': 'Shop'},
  'fulfillment_type': 'delivery',
  'items': <dynamic>[],
  'items_count': 0,
  'bill': <String, dynamic>{},
  'total': 0,
  'delivery_fee': 0,
  'discount': 0,
  'final_total': 0,
});

Widget _app(Widget home, _FakePageApi api) => ProviderScope(
  overrides: [
    businessPageApiProvider.overrideWithValue(api),
    addressesApiProvider.overrideWithValue(_FakeAddressesApi()),
  ],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  ),
);

void main() {
  testWidgets(
    'checkout offers every method the store ticked, and reads them again when it opens',
    (tester) async {
      final api = _FakePageApi([
        _method(108, 'توصيل طلبات', 'delivery'),
        _method(134, 'تسليم أرض المصنع', 'pickup'),
        _method(322, 'شحن', 'delivery'),
      ]);
      await tester.pumpWidget(_app(CheckoutScreen(cart: _cart()), api));
      await tester.pumpAndSettle();

      expect(find.text('توصيل طلبات'), findsOneWidget);
      expect(find.text('تسليم أرض المصنع'), findsOneWidget);
      expect(find.text('شحن'), findsOneWidget);
      expect(
        api.reads,
        greaterThanOrEqualTo(2),
        reason:
            'a copy cached earlier is not trusted: the page is read again on opening',
      );
    },
  );

  testWidgets(
    'a store that has not said how it delivers cannot be ordered from',
    (tester) async {
      await tester.pumpWidget(
        _app(CheckoutScreen(cart: _cart()), _FakePageApi(const [])),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'لم يحدد هذا المتجر طريقة التسليم والاستلام بعد، فلا يمكنك إتمام طلب منه الآن.',
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final button = tester.widget<FilledButton>(
        find.byType(FilledButton).last,
      );
      expect(button.onPressed, isNull, reason: 'the order button is off');
    },
  );

  testWidgets(
    'more choices than the width allows scroll sideways instead of wrapping',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingChipRow(
              children: [
                for (var i = 0; i < 10; i++) Chip(label: Text('خيار رقم $i')),
              ],
            ),
          ),
        ),
      );

      final tops = {
        for (final e in tester.elementList(find.byType(Chip)))
          tester.getTopLeft(find.byWidget(e.widget)).dy,
      };
      expect(tops, hasLength(1), reason: 'one line — nothing wraps');
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(
        scroll.position.maxScrollExtent,
        greaterThan(0),
        reason: 'wider than the screen: it scrolls',
      );
    },
  );
}
