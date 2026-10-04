import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/cart/presentation/widgets/weight_picker.dart';
import 'package:bim_app/features/orders/data/models/placed_order.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «كيلو وربع ونص لكل منتجات الأكل» — grams as chips (250 · 500 · 750), kilos as a stepper; a weighed
/// invoice line reads the fish and its cooking apart.
void main() {
  test('a quantity is written without the noise of a decimal it does not need', () {
    expect(formatQty(2), '2');
    expect(formatQty(2.0), '2');
    expect(formatQty(1.5), '1.5');
    expect(formatQty(0.25), '0.25');
  });

  Future<void> pump(WidgetTester tester, double value, ValueChanged<double> onChanged) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: WeightPicker(value: value, onChanged: onChanged)),
    ),
  );

  testWidgets('the grams chips add to the kilos and tapping the chosen grams again clears them', (tester) async {
    double picked = -1;
    await pump(tester, 1, (v) => picked = v);

    await tester.tap(find.text('500 جم'));
    expect(picked, 1.5);

    await pump(tester, 1.5, (v) => picked = v);
    await tester.tap(find.text('500 جم'));
    expect(picked, 1, reason: 'the chosen grams cleared');
  });

  testWidgets('the kilo stepper moves whole kilos and keeps the grams', (tester) async {
    double picked = -1;
    await pump(tester, 1.25, (v) => picked = v);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    expect(picked, 2.25);

    await pump(tester, 1.25, (v) => picked = v);
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    expect(picked, 0.25);
  });

  testWidgets('it never goes below a quarter of a kilo', (tester) async {
    double picked = -1;
    await pump(tester, 1, (v) => picked = v);

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    expect(picked, WeightPicker.minKg, reason: '0 kg and no grams is not an order');
  });

  test('a placed line reads the fish and each cooking method apart, for its own weight', () {
    final line = OrderLineItem.fromJson({
      'id': 1,
      'name': 'بورى',
      'qty': 1.5,
      'price': 420,
      'total_price': 630,
      'unit': 'كجم',
      'base_price': 320,
      'extras_detail': [
        {'name': 'مشوي', 'unit_price': 100, 'qty': 1, 'total': 150},
      ],
    });

    expect(line.qty, 1.5);
    expect(line.baseTotal, 480);
    expect(line.services.single.total, 150);
    expect(line.totalPrice, line.baseTotal + line.services.single.total);
  });
}
