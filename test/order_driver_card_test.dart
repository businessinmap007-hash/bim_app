import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/orders/data/models/placed_order.dart';
import 'package:bim_app/features/orders/presentation/widgets/order_driver_card.dart';
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
  test('an order carries its assigned driver, and none before assignment', () {
    final withDriver = PlacedOrder.fromJson({
      'id': 1,
      'delivery_driver': {'id': 4, 'name': 'Ali', 'phone': '0100', 'vehicle_label': 'Motorbike'},
    });
    expect(withDriver.driver?.name, 'Ali');
    expect(withDriver.driver?.vehicleLabel, 'Motorbike');
    expect(PlacedOrder.fromJson({'id': 2, 'delivery_driver': null}).driver, isNull);
    expect(PlacedOrder.fromJson({'id': 3}).driver, isNull);
  });

  testWidgets('the driver card shows name, vehicle and a call button', (tester) async {
    await tester.pumpWidget(_wrap(const OrderDriverCard(driver: OrderDriver(name: 'Ali', phone: '0100', vehicleLabel: 'Motorbike'))));
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('Your delivery driver · Motorbike'), findsOneWidget);
    expect(find.byTooltip('Call the driver'), findsOneWidget);
  });

  testWidgets('no phone means no call button', (tester) async {
    await tester.pumpWidget(_wrap(const OrderDriverCard(driver: OrderDriver(name: 'Ali'))));
    expect(find.byIcon(Icons.call_outlined), findsNothing);
  });
}
